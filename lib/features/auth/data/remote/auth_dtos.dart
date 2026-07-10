import '../../domain/entities/register_data.dart';

/// DTOs de red — mirror exacto de los DTOs de `diabecare-api` (nombres de
/// campo tal cual, incluido `heightCm` como string numérico en el registro).

class RegisterRequestDto {
  RegisterRequestDto(RegisterData data)
    : email = data.email,
      password = data.password,
      fullName = data.fullName,
      dateOfBirth = _isoDate(data.dateOfBirth),
      diabetesType = data.diabetesType.wireValue,
      diagnosisDate = _isoDate(data.diagnosisDate),
      heightCm = data.heightCm.toString(),
      biologicalSex = data.biologicalSex.wireValue,
      termsAccepted = data.termsAccepted;

  final String email;
  final String password;
  final String fullName;
  final String dateOfBirth;
  final String diabetesType;
  final String diagnosisDate;
  final String heightCm;
  final String biologicalSex;
  final bool termsAccepted;

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'fullName': fullName,
    'dateOfBirth': dateOfBirth,
    'diabetesType': diabetesType,
    'diagnosisDate': diagnosisDate,
    'heightCm': heightCm,
    'biologicalSex': biologicalSex,
    'termsAccepted': termsAccepted,
  };

  static String _isoDate(DateTime date) => date.toIso8601String().split('T').first;
}

class AuthResponseDto {
  AuthResponseDto({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.refreshToken,
    required this.refreshExpiresIn,
    required this.patientJson,
    required this.role,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) => AuthResponseDto(
    accessToken: json['accessToken'] as String,
    tokenType: json['tokenType'] as String,
    expiresIn: json['expiresIn'] as int,
    refreshToken: json['refreshToken'] as String,
    refreshExpiresIn: json['refreshExpiresIn'] as int,
    patientJson: json['patient'] as Map<String, dynamic>?,
    role: json['role'] as String,
  );

  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final String refreshToken;
  final int refreshExpiresIn;
  final Map<String, dynamic>? patientJson;
  final String role;
}

class RefreshTokenResponseDto {
  RefreshTokenResponseDto({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.refreshToken,
    required this.refreshExpiresIn,
  });

  factory RefreshTokenResponseDto.fromJson(Map<String, dynamic> json) => RefreshTokenResponseDto(
    accessToken: json['accessToken'] as String,
    tokenType: json['tokenType'] as String,
    expiresIn: json['expiresIn'] as int,
    refreshToken: json['refreshToken'] as String,
    refreshExpiresIn: json['refreshExpiresIn'] as int,
  );

  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final String refreshToken;
  final int refreshExpiresIn;
}
