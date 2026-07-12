// DTOs de red — mirror exacto de `AdminController`.

class AdminUserResponseDto {
  AdminUserResponseDto({
    required this.id,
    required this.email,
    required this.role,
    required this.enabled,
    required this.createdAt,
    this.suspendedAt,
    this.deletedAt,
  });

  factory AdminUserResponseDto.fromJson(Map<String, dynamic> json) => AdminUserResponseDto(
    id: json['id'] as String,
    email: json['email'] as String,
    role: json['role'] as String,
    enabled: json['enabled'] as bool,
    suspendedAt: json['suspendedAt'] == null ? null : DateTime.parse(json['suspendedAt'] as String),
    deletedAt: json['deletedAt'] == null ? null : DateTime.parse(json['deletedAt'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  final String id;
  final String email;
  final String role;
  final bool enabled;
  final DateTime? suspendedAt;
  final DateTime? deletedAt;
  final DateTime createdAt;
}

class AdminUserPageResponseDto {
  AdminUserPageResponseDto({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  factory AdminUserPageResponseDto.fromJson(Map<String, dynamic> json) => AdminUserPageResponseDto(
    content: (json['content'] as List<dynamic>)
        .map((e) => AdminUserResponseDto.fromJson(e as Map<String, dynamic>))
        .toList(),
    page: json['page'] as int,
    size: json['size'] as int,
    totalElements: json['totalElements'] as int,
    totalPages: json['totalPages'] as int,
  );

  final List<AdminUserResponseDto> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
}
