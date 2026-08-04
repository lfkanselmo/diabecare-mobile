import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/storage/app_database.dart';
import '../../../../core/sync/sync_status.dart';
import '../../../../core/sync/syncable_repository.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/daily_summary.dart';
import '../../domain/entities/meal_entry.dart';
import '../../domain/entities/meal_item.dart';
import '../../domain/entities/meal_type.dart';
import '../../domain/repositories/meal_repository.dart';
import '../local/meal_dao.dart';
import '../remote/meal_api_client.dart';
import '../remote/meal_dtos.dart';

class MealRepositoryImpl implements MealRepository, SyncableRepository<MealEntry> {
  MealRepositoryImpl({
    required MealDao dao,
    required MealApiClient apiClient,
    required AuthRepository authRepository,
    required AppDatabase database,
    Uuid? uuid,
  }) : _dao = dao,
       _apiClient = apiClient,
       _authRepository = authRepository,
       _database = database,
       _uuid = uuid ?? const Uuid();

  final MealDao _dao;
  final MealApiClient _apiClient;
  final AuthRepository _authRepository;
  final AppDatabase _database;
  final Uuid _uuid;

  static const _resourceName = 'meals';

  @override
  String get resourceName => _resourceName;

  @override
  Stream<List<MealEntry>> watchMeals({required DateTime from, required DateTime to}) {
    return _dao.watchMeals(from: from, to: to).map((rows) => rows.map(_toDomain).toList());
  }

  @override
  Future<MealEntry> register({
    required MealType mealType,
    required DateTime consumedAt,
    required List<MealItem> items,
    String? notes,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final itemsWithIds = items.map((i) => i.id.isEmpty ? _withId(i) : i).toList();
    await _dao.upsert(
      MealEntriesCompanion.insert(
        id: id,
        mealType: mealType.wireValue,
        consumedAt: consumedAt,
        notes: Value(notes),
        itemsJson: jsonEncode(itemsWithIds.map((i) => i.toJson()).toList()),
        syncStatus: SyncStatus.pendingCreate.name,
        localUpdatedAt: now,
      ),
    );
    final row = await _dao.getById(id);
    return _toDomain(row!);
  }

  MealItem _withId(MealItem item) => MealItem(
    id: _uuid.v4(),
    foodName: item.foodName,
    quantityGrams: item.quantityGrams,
    calories: item.calories,
    carbohydrates: item.carbohydrates,
    proteins: item.proteins,
    fats: item.fats,
    foodCode: item.foodCode,
  );

  @override
  Future<DailySummary> getDailySummary(DateTime date) async {
    final patientId = await _requirePatientId();
    final dto = await _apiClient.getDailySummary(patientId: patientId, date: date);
    return DailySummary(
      date: dto.date,
      totalCalories: dto.totalCalories,
      totalCarbohydrates: dto.totalCarbohydrates,
      totalProteins: dto.totalProteins,
      totalFats: dto.totalFats,
      calorieGoal: dto.calorieGoal,
      goalReached: dto.goalReached,
    );
  }

  @override
  Future<void> pullChanges() async {
    final patientId = await _requirePatientId();
    final cursorRow = await (_database.select(
      _database.syncCursors,
    )..where((t) => t.resource.equals(_resourceName))).getSingleOrNull();

    final since = cursorRow?.lastSyncedAt;
    final remoteMeals = await _apiClient.sync(patientId: patientId, since: since);

    for (final dto in remoteMeals) {
      await _dao.upsert(_companionFromDto(dto, SyncStatus.synced));
    }

    await _database
        .into(_database.syncCursors)
        .insertOnConflictUpdate(SyncCursorsCompanion.insert(resource: _resourceName, lastSyncedAt: DateTime.now()));
  }

  @override
  Future<List<PendingChange<MealEntry>>> getPending() async {
    final rows = await _dao.getPending();
    return rows.map((row) {
      final status = SyncStatus.values.firstWhere((s) => s.name == row.syncStatus);
      return PendingChange<MealEntry>(id: row.id, status: status, payload: _toDomain(row));
    }).toList();
  }

  @override
  Future<void> pushCreate(MealEntry payload) async {
    final patientId = await _requirePatientId();
    final dto = await _apiClient.register(
      patientId: patientId,
      mealType: payload.mealType.wireValue,
      consumedAt: payload.consumedAt,
      notes: payload.notes,
      mealId: payload.id,
      items: payload.items
          .map(
            (i) => MealItemDto(
              foodName: i.foodName,
              quantityGrams: i.quantityGrams,
              calories: i.calories,
              carbohydrates: i.carbohydrates,
              proteins: i.proteins,
              fats: i.fats,
              foodCode: i.foodCode,
              mealItemId: i.id,
            ),
          )
          .toList(),
    );
    await _dao.upsert(_companionFromDto(dto, SyncStatus.pendingCreate));
  }

  @override
  Future<void> pushUpdate(MealEntry payload) {
    throw UnimplementedError('No existe edición de comidas todavía');
  }

  @override
  Future<void> pushDelete(String id) {
    throw UnimplementedError('No existe borrado de comidas todavía');
  }

  @override
  Future<void> markSynced(String id, DateTime serverUpdatedAt) => _dao.markSynced(id, serverUpdatedAt);

  @override
  Future<void> markSyncError(String id, String message) => _dao.markSyncError(id, message);

  Future<String> _requirePatientId() async {
    final session = await _authRepository.loadSession();
    final patientId = session?.patient?.patientId;
    if (patientId == null) {
      throw StateError('No hay un paciente asociado a la sesión actual');
    }
    return patientId;
  }

  MealEntriesCompanion _companionFromDto(MealEntryResponseDto dto, SyncStatus syncStatus) {
    return MealEntriesCompanion.insert(
      id: dto.mealId,
      mealType: dto.mealType,
      consumedAt: dto.consumedAt,
      notes: Value(dto.notes),
      itemsJson: jsonEncode(
        dto.items
            .map(
              (i) => MealItem(
                id: i.mealItemId,
                foodName: i.foodName,
                quantityGrams: i.quantityGrams,
                calories: i.calories,
                carbohydrates: i.carbohydrates,
                proteins: i.proteins,
                fats: i.fats,
              ).toJson(),
            )
            .toList(),
      ),
      totalCalories: Value(dto.totalCalories),
      totalCarbohydrates: Value(dto.totalCarbohydrates),
      totalProteins: Value(dto.totalProteins),
      totalFats: Value(dto.totalFats),
      syncStatus: syncStatus.name,
      localUpdatedAt: DateTime.now(),
      serverUpdatedAt: Value(dto.updatedAt),
    );
  }

  MealEntry _toDomain(MealEntryRow row) {
    final itemsList = (jsonDecode(row.itemsJson) as List<dynamic>)
        .map((e) => MealItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return MealEntry(
      id: row.id,
      mealType: MealType.fromWire(row.mealType),
      consumedAt: row.consumedAt,
      items: itemsList,
      syncStatus: SyncStatus.values.firstWhere((s) => s.name == row.syncStatus),
      notes: row.notes,
      totalCalories: row.totalCalories,
      totalCarbohydrates: row.totalCarbohydrates,
      totalProteins: row.totalProteins,
      totalFats: row.totalFats,
      updatedAt: row.serverUpdatedAt,
    );
  }
}
