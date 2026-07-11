import 'dart:convert';

import 'package:diabecare_mobile/core/storage/app_database.dart';
import 'package:diabecare_mobile/core/sync/sync_status.dart';
import 'package:diabecare_mobile/features/auth/domain/entities/auth_session.dart';
import 'package:diabecare_mobile/features/auth/domain/entities/biological_sex.dart';
import 'package:diabecare_mobile/features/auth/domain/entities/diabetes_type.dart';
import 'package:diabecare_mobile/features/auth/domain/entities/patient.dart';
import 'package:diabecare_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:diabecare_mobile/features/nutrition/data/local/meal_dao.dart';
import 'package:diabecare_mobile/features/nutrition/data/remote/meal_api_client.dart';
import 'package:diabecare_mobile/features/nutrition/data/remote/meal_dtos.dart';
import 'package:diabecare_mobile/features/nutrition/data/repository_impl/meal_repository_impl.dart';
import 'package:diabecare_mobile/features/nutrition/domain/entities/meal_entry.dart';
import 'package:diabecare_mobile/features/nutrition/domain/entities/meal_item.dart';
import 'package:diabecare_mobile/features/nutrition/domain/entities/meal_type.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMealDao extends Mock implements MealDao {}

class _MockMealApiClient extends Mock implements MealApiClient {}

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockMealDao dao;
  late _MockMealApiClient apiClient;
  late _MockAuthRepository authRepository;
  late MealRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(const MealEntriesCompanion());
  });

  final database = AppDatabase(NativeDatabase.memory());

  final patient = Patient(
    patientId: 'patient-1',
    fullName: 'Ana',
    dateOfBirth: DateTime(1990, 1, 1),
    age: 35,
    diabetesType: DiabetesType.type1,
    diagnosisDate: DateTime(2010, 1, 1),
    heightCm: 165,
    targetGlucoseMin: 70,
    targetGlucoseMax: 180,
    activityLevel: 'MODERATE',
    preferredGlucoseUnit: 'MG_DL',
    biologicalSex: BiologicalSex.female,
  );

  setUp(() {
    dao = _MockMealDao();
    apiClient = _MockMealApiClient();
    authRepository = _MockAuthRepository();
    when(() => authRepository.loadSession()).thenAnswer(
      (_) async => AuthSession(accessToken: 'a', refreshToken: 'r', role: 'PATIENT', patient: patient),
    );
    repository = MealRepositoryImpl(
      dao: dao,
      apiClient: apiClient,
      authRepository: authRepository,
      database: database,
    );
  });

  final item = const MealItem(id: 'i1', foodName: 'Arroz', quantityGrams: 100, calories: 130, carbohydrates: 28.6);

  MealEntryRow row({required String id, required String syncStatus}) {
    return MealEntryRow(
      id: id,
      mealType: 'BREAKFAST',
      consumedAt: DateTime(2026, 1, 1),
      itemsJson: jsonEncode([item.toJson()]),
      syncStatus: syncStatus,
      localUpdatedAt: DateTime(2026, 1, 1),
    );
  }

  test('getPending mapea las filas pendientes a PendingChange', () async {
    when(() => dao.getPending()).thenAnswer((_) async => [row(id: 'm1', syncStatus: SyncStatus.pendingCreate.name)]);

    final pending = await repository.getPending();

    expect(pending, hasLength(1));
    expect(pending.first.id, 'm1');
    expect(pending.first.status, SyncStatus.pendingCreate);
    expect(pending.first.payload, isA<MealEntry>());
    expect(pending.first.payload.items, hasLength(1));
  });

  test('pushCreate registra en el backend con el ID del cliente y hace upsert de la respuesta', () async {
    when(
      () => apiClient.register(
        patientId: any(named: 'patientId'),
        mealType: any(named: 'mealType'),
        consumedAt: any(named: 'consumedAt'),
        items: any(named: 'items'),
        notes: any(named: 'notes'),
        mealId: any(named: 'mealId'),
      ),
    ).thenAnswer(
      (_) async => MealEntryResponseDto(
        mealId: 'm1',
        mealType: 'BREAKFAST',
        consumedAt: DateTime(2026, 1, 1),
        totalCalories: 130,
        totalCarbohydrates: 28.6,
        items: [
          MealItemResponseDto(
            mealItemId: 'i1',
            foodName: 'Arroz',
            quantityGrams: 100,
            calories: 130,
            carbohydrates: 28.6,
          ),
        ],
      ),
    );
    when(() => dao.upsert(any())).thenAnswer((_) async {});

    final meal = MealEntry(
      id: 'm1',
      mealType: MealType.breakfast,
      consumedAt: DateTime(2026, 1, 1),
      items: [item],
      syncStatus: SyncStatus.pendingCreate,
    );

    await repository.pushCreate(meal);

    verify(
      () => apiClient.register(
        patientId: 'patient-1',
        mealType: 'BREAKFAST',
        consumedAt: DateTime(2026, 1, 1),
        items: any(named: 'items'),
        notes: null,
        mealId: 'm1',
      ),
    ).called(1);
    verify(() => dao.upsert(any())).called(1);
  });

  test('pushUpdate lanza — no existe edición de comidas todavía', () {
    final meal = MealEntry(
      id: 'm1',
      mealType: MealType.breakfast,
      consumedAt: DateTime(2026, 1, 1),
      items: [item],
      syncStatus: SyncStatus.pendingUpdate,
    );

    expect(() => repository.pushUpdate(meal), throwsUnimplementedError);
  });

  test('pushDelete lanza — no existe borrado de comidas todavía', () {
    expect(() => repository.pushDelete('m1'), throwsUnimplementedError);
  });

  test('markSynced delega al dao', () async {
    when(() => dao.markSynced('m1', any())).thenAnswer((_) async {});

    await repository.markSynced('m1', DateTime(2026, 1, 1));

    verify(() => dao.markSynced('m1', DateTime(2026, 1, 1))).called(1);
  });
}
