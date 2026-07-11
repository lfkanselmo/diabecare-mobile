import 'package:diabecare_mobile/features/glucose/data/ble/sfloat_parser.dart';
import 'package:diabecare_mobile/features/glucose/domain/entities/glucose_unit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseSfloat', () {
    test('0xC00C -> 12 * 10^-4 = 0.0012', () {
      expect(parseSfloat(0xC00C), closeTo(0.0012, 1e-9));
    });

    test('0xC037 -> 55 * 10^-4 = 0.0055', () {
      expect(parseSfloat(0xC037), closeTo(0.0055, 1e-9));
    });
  });

  group('parseGlucoseMeasurement', () {
    test('flags=0x02 (glucosa presente, unidad kg/L) -> mg/dL', () {
      // seq=1, fecha 2026-01-15 08:30:00, SFLOAT 0xC00C = 0.0012 kg/L -> 120 mg/dL
      final bytes = [
        0x02, // flags
        0x01, 0x00, // seq
        0xEA, 0x07, // year 2026 LE
        1, 15, 8, 30, 0, // month day hour minute second
        0x0C, 0xC0, // SFLOAT concentration LE
      ];

      final measurement = parseGlucoseMeasurement(bytes, 'Meter-A');

      expect(measurement.unit, GlucoseUnit.mgDl);
      expect(measurement.value, 120.0);
      expect(measurement.measuredAt, DateTime(2026, 1, 15, 8, 30, 0));
      expect(measurement.deviceName, 'Meter-A');
    });

    test('flags=0x07 (offset presente, glucosa presente, unidad mol/L) -> mmol/L con offset', () {
      // seq=2, fecha base 2026-03-10 14:00:00, offset -30 min, SFLOAT 0xC037 = 0.0055 mol/L -> 5.5 mmol/L
      final bytes = [
        0x07, // flags
        0x02, 0x00, // seq
        0xEA, 0x07, // year 2026 LE
        3, 10, 14, 0, 0, // month day hour minute second
        0xE2, 0xFF, // offset -30 min (int16 LE)
        0x37, 0xC0, // SFLOAT concentration LE
      ];

      final measurement = parseGlucoseMeasurement(bytes, 'Meter-B');

      expect(measurement.unit, GlucoseUnit.mmolL);
      expect(measurement.value, 5.5);
      expect(measurement.measuredAt, DateTime(2026, 3, 10, 13, 30, 0));
    });

    test('flags=0x00 (glucosa ausente) lanza FormatException', () {
      final bytes = [
        0x00, // flags: ningún bit presente
        0x00, 0x00, // seq
        0xEA, 0x07, // year 2026 LE
        1, 1, 0, 0, 0, // month day hour minute second
      ];

      expect(() => parseGlucoseMeasurement(bytes, 'Meter-C'), throwsFormatException);
    });
  });
}
