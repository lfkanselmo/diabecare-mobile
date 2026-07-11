import 'cycle_symptom.dart';
import 'flow_intensity.dart';
import 'symptom_severity.dart';

/// `flowIntensityLabel`/`symptomLabel` vienen ya traducidos del backend
/// (`Accept-Language`, ver `language_interceptor.dart`) — no hace falta
/// una tabla de traducción del lado cliente para mostrarlos.
class CycleDaySymptomEntry {
  const CycleDaySymptomEntry({required this.symptom, required this.symptomLabel, required this.severity});

  final CycleSymptom symptom;
  final String symptomLabel;
  final SymptomSeverity severity;
}

class CycleDayEntry {
  const CycleDayEntry({
    required this.dayEntryId,
    required this.entryDate,
    required this.flowIntensity,
    required this.flowIntensityLabel,
    required this.symptoms,
    this.notes,
  });

  final String dayEntryId;
  final DateTime entryDate;
  final FlowIntensity flowIntensity;
  final String flowIntensityLabel;
  final String? notes;
  final List<CycleDaySymptomEntry> symptoms;
}
