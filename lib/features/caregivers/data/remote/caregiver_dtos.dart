// DTOs de red — mirror exacto de `CaregiverController`.

class CaregiverInviteResponseDto {
  CaregiverInviteResponseDto({required this.code, required this.expiresAt});

  factory CaregiverInviteResponseDto.fromJson(Map<String, dynamic> json) => CaregiverInviteResponseDto(
    code: json['code'] as String,
    expiresAt: DateTime.parse(json['expiresAt'] as String),
  );

  final String code;
  final DateTime expiresAt;
}

class CaregiverLinkResponseDto {
  CaregiverLinkResponseDto({
    required this.linkId,
    required this.caregiverUserId,
    required this.caregiverName,
    required this.caregiverEmail,
    required this.linkedAt,
  });

  factory CaregiverLinkResponseDto.fromJson(Map<String, dynamic> json) => CaregiverLinkResponseDto(
    linkId: json['linkId'] as String,
    caregiverUserId: json['caregiverUserId'] as String,
    caregiverName: json['caregiverName'] as String,
    caregiverEmail: json['caregiverEmail'] as String,
    linkedAt: DateTime.parse(json['linkedAt'] as String),
  );

  final String linkId;
  final String caregiverUserId;
  final String caregiverName;
  final String caregiverEmail;
  final DateTime linkedAt;
}

class RedeemCaregiverInviteResponseDto {
  RedeemCaregiverInviteResponseDto({required this.patientId, required this.patientFullName});

  factory RedeemCaregiverInviteResponseDto.fromJson(Map<String, dynamic> json) => RedeemCaregiverInviteResponseDto(
    patientId: json['patientId'] as String,
    patientFullName: json['patientFullName'] as String,
  );

  final String patientId;
  final String patientFullName;
}

class PatientAccessResponseDto {
  PatientAccessResponseDto({required this.patientId, required this.patientFullName, required this.linkedAt});

  factory PatientAccessResponseDto.fromJson(Map<String, dynamic> json) => PatientAccessResponseDto(
    patientId: json['patientId'] as String,
    patientFullName: json['patientFullName'] as String,
    linkedAt: DateTime.parse(json['linkedAt'] as String),
  );

  final String patientId;
  final String patientFullName;
  final DateTime linkedAt;
}
