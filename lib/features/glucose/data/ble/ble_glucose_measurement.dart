import '../../domain/entities/glucose_unit.dart';

/// Resultado de leer la característica Glucose Measurement (0x2A18) de un
/// glucómetro BLE — mirror de `BleGlucoseMeasurement` de `diabecare-web`.
class BleGlucoseMeasurement {
  const BleGlucoseMeasurement({
    required this.value,
    required this.unit,
    required this.measuredAt,
    required this.deviceName,
  });

  final double value;
  final GlucoseUnit unit;
  final DateTime measuredAt;
  final String deviceName;
}
