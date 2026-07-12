import 'user_role.dart';

class AdminUser {
  const AdminUser({
    required this.id,
    required this.email,
    required this.role,
    required this.enabled,
    required this.createdAt,
    this.suspendedAt,
    this.deletedAt,
  });

  final String id;
  final String email;
  final UserRole role;
  final bool enabled;
  final DateTime? suspendedAt;
  final DateTime? deletedAt;
  final DateTime createdAt;
}

/// Página de usuarios — mirror de `PageResponse<AdminUserResponse>` del
/// backend. No se generaliza a un `Page<T>` compartido porque esta es,
/// por ahora, la única pantalla que consume un endpoint paginado.
class AdminUserPage {
  const AdminUserPage({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  final List<AdminUser> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
}
