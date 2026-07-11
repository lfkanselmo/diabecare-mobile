class CaregiverLink {
  const CaregiverLink({
    required this.linkId,
    required this.caregiverUserId,
    required this.caregiverName,
    required this.caregiverEmail,
    required this.linkedAt,
  });

  final String linkId;
  final String caregiverUserId;
  final String caregiverName;
  final String caregiverEmail;
  final DateTime linkedAt;
}

/// Un paciente al que este usuario tiene acceso de solo lectura como cuidador.
class PatientAccess {
  const PatientAccess({required this.patientId, required this.patientFullName, required this.linkedAt});

  final String patientId;
  final String patientFullName;
  final DateTime linkedAt;
}

class RedeemCaregiverInviteResult {
  const RedeemCaregiverInviteResult({required this.patientId, required this.patientFullName});

  final String patientId;
  final String patientFullName;
}
