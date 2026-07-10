import 'biological_sex.dart';
import 'diabetes_type.dart';

/// Datos del formulario de registro — mirror de `RegisterRequest` del backend.
/// `termsAccepted` debe ser `true` (el backend lo valida con `@AssertTrue`);
/// no existe campo de versión de política, el servidor la estampa (ver
/// `AuthController.CURRENT_TERMS_VERSION`).
class RegisterData {
  const RegisterData({
    required this.email,
    required this.password,
    required this.fullName,
    required this.dateOfBirth,
    required this.diabetesType,
    required this.diagnosisDate,
    required this.heightCm,
    required this.biologicalSex,
    required this.termsAccepted,
  });

  final String email;
  final String password;
  final String fullName;
  final DateTime dateOfBirth;
  final DiabetesType diabetesType;
  final DateTime diagnosisDate;
  final double heightCm;
  final BiologicalSex biologicalSex;
  final bool termsAccepted;
}
