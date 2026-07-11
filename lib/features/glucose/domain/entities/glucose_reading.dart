import '../../../../core/sync/sync_status.dart';
import 'glucose_status.dart';
import 'glucose_unit.dart';
import 'reading_type.dart';

/// `status`/`updatedAt` son nulos hasta que el servidor confirma la lectura
/// (offline-first: una lectura recién creada localmente todavía no tiene
/// clasificación clínica ni timestamp de servidor).
class GlucoseReading {
  const GlucoseReading({
    required this.id,
    required this.value,
    required this.unit,
    required this.readingType,
    required this.measuredAt,
    required this.syncStatus,
    this.status,
    this.notes,
    this.deviceSource,
    this.updatedAt,
  });

  final String id;
  final double value;
  final GlucoseUnit unit;
  final ReadingType readingType;
  final DateTime measuredAt;
  final SyncStatus syncStatus;
  final GlucoseStatus? status;
  final String? notes;
  final String? deviceSource;
  final DateTime? updatedAt;

  GlucoseReading copyWith({
    SyncStatus? syncStatus,
    GlucoseStatus? status,
    DateTime? updatedAt,
  }) {
    return GlucoseReading(
      id: id,
      value: value,
      unit: unit,
      readingType: readingType,
      measuredAt: measuredAt,
      syncStatus: syncStatus ?? this.syncStatus,
      status: status ?? this.status,
      notes: notes,
      deviceSource: deviceSource,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
