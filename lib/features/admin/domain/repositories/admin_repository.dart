import '../entities/admin_user.dart';
import '../entities/user_role.dart';

/// Dominio 100% online — solo accesible para usuarios con rol ADMIN (el
/// backend ya lo exige con `@PreAuthorize`, esto no es una segunda capa de
/// seguridad, solo el cliente de esos endpoints).
abstract interface class AdminRepository {
  Future<AdminUserPage> getUsers({int page = 0, int size = 20});

  Future<void> changeUserRole({required String userId, required UserRole role});

  Future<void> reloadSystemConfig();
}
