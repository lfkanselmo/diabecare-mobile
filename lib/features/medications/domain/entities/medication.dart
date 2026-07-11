import '../../../../core/sync/sync_status.dart';
import 'dose_unit.dart';
import 'medication_frequency.dart';
import 'medication_type.dart';

class Medication {
  const Medication({
    required this.id,
    required this.name,
    required this.type,
    required this.dose,
    required this.doseUnit,
    required this.frequency,
    required this.active,
    required this.syncStatus,
    this.startDate,
    this.notes,
    this.updatedAt,
  });

  final String id;
  final String name;
  final MedicationType type;
  final double dose;
  final DoseUnit doseUnit;
  final MedicationFrequency frequency;
  final DateTime? startDate;
  final bool active;
  final String? notes;
  final SyncStatus syncStatus;
  final DateTime? updatedAt;

  Medication copyWith({bool? active, SyncStatus? syncStatus}) {
    return Medication(
      id: id,
      name: name,
      type: type,
      dose: dose,
      doseUnit: doseUnit,
      frequency: frequency,
      startDate: startDate,
      active: active ?? this.active,
      notes: notes,
      syncStatus: syncStatus ?? this.syncStatus,
      updatedAt: updatedAt,
    );
  }
}
