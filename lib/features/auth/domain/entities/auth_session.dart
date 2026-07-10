import 'patient.dart';

/// Sesión autenticada actual. `patient` puede ser null si el usuario nunca
/// llegó a tener un perfil de paciente asociado (mismo caso que ya contempla
/// el backend en `PurgeAccountDataPort`).
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
    this.patient,
  });

  final String accessToken;
  final String refreshToken;
  final String role;
  final Patient? patient;

  bool get isAdmin => role == 'ADMIN';

  AuthSession copyWith({String? accessToken, String? refreshToken}) {
    return AuthSession(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      role: role,
      patient: patient,
    );
  }
}
