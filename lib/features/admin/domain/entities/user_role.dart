/// Debe coincidir con los roles válidos de `ChangeUserRoleUseCaseImpl`
/// (`VALID_ROLES`) — ser cuidador no es un rol, es un vínculo aparte
/// (`caregiver_links`), por eso solo hay 2 valores acá.
enum UserRole {
  patient('PATIENT'),
  admin('ADMIN');

  const UserRole(this.wireValue);

  final String wireValue;

  static UserRole fromWire(String value) => values.firstWhere((e) => e.wireValue == value);
}
