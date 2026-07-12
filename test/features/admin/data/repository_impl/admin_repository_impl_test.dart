import 'package:diabecare_mobile/features/admin/data/remote/admin_api_client.dart';
import 'package:diabecare_mobile/features/admin/data/remote/admin_dtos.dart';
import 'package:diabecare_mobile/features/admin/data/repository_impl/admin_repository_impl.dart';
import 'package:diabecare_mobile/features/admin/domain/entities/user_role.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAdminApiClient extends Mock implements AdminApiClient {}

void main() {
  late _MockAdminApiClient apiClient;
  late AdminRepositoryImpl repository;

  setUp(() {
    apiClient = _MockAdminApiClient();
    repository = AdminRepositoryImpl(apiClient);
  });

  test('getUsers mapea la página de usuarios y sus roles', () async {
    when(() => apiClient.getUsers(page: 0, size: 20)).thenAnswer(
      (_) async => AdminUserPageResponseDto(
        content: [
          AdminUserResponseDto(
            id: 'u1',
            email: 'ana@example.com',
            role: 'PATIENT',
            enabled: true,
            createdAt: DateTime(2026, 1, 1),
          ),
        ],
        page: 0,
        size: 20,
        totalElements: 1,
        totalPages: 1,
      ),
    );

    final result = await repository.getUsers();

    expect(result.content, hasLength(1));
    expect(result.content.first.role, UserRole.patient);
    expect(result.totalElements, 1);
  });

  test('changeUserRole traduce el UserRole de dominio al wireValue', () async {
    when(
      () => apiClient.changeUserRole(userId: any(named: 'userId'), role: any(named: 'role')),
    ).thenAnswer((_) async {});

    await repository.changeUserRole(userId: 'u1', role: UserRole.admin);

    verify(() => apiClient.changeUserRole(userId: 'u1', role: 'ADMIN')).called(1);
  });

  test('reloadSystemConfig delega directo al api client', () async {
    when(() => apiClient.reloadSystemConfig()).thenAnswer((_) async {});

    await repository.reloadSystemConfig();

    verify(() => apiClient.reloadSystemConfig()).called(1);
  });
}
