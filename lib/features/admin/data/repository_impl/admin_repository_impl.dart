import '../../domain/entities/admin_user.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/repositories/admin_repository.dart';
import '../remote/admin_api_client.dart';
import '../remote/admin_dtos.dart';

class AdminRepositoryImpl implements AdminRepository {
  AdminRepositoryImpl(this._apiClient);

  final AdminApiClient _apiClient;

  @override
  Future<AdminUserPage> getUsers({int page = 0, int size = 20}) async {
    final dto = await _apiClient.getUsers(page: page, size: size);
    return AdminUserPage(
      content: dto.content.map(_toDomain).toList(),
      page: dto.page,
      size: dto.size,
      totalElements: dto.totalElements,
      totalPages: dto.totalPages,
    );
  }

  @override
  Future<void> changeUserRole({required String userId, required UserRole role}) {
    return _apiClient.changeUserRole(userId: userId, role: role.wireValue);
  }

  @override
  Future<void> reloadSystemConfig() => _apiClient.reloadSystemConfig();

  AdminUser _toDomain(AdminUserResponseDto dto) {
    return AdminUser(
      id: dto.id,
      email: dto.email,
      role: UserRole.fromWire(dto.role),
      enabled: dto.enabled,
      suspendedAt: dto.suspendedAt,
      deletedAt: dto.deletedAt,
      createdAt: dto.createdAt,
    );
  }
}
