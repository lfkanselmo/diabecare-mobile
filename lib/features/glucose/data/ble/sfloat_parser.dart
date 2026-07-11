import 'dart:math';
import 'dart:typed_data';

import '../../domain/entities/glucose_unit.dart';
import 'ble_glucose_measurement.dart';

/// Decodifica un SFLOAT de 16 bits (IEEE 11073-20601): 4 bits de exponente +
/// 12 bits de mantisa, ambos en complemento a 2 — port exacto de
/// `parseSfloat` en `ble-glucose-meter.service.ts`.
double parseSfloat(int raw) {
  var mantissa = raw & 0x0FFF;
  var exponent = (raw >> 12) & 0x0F;

  if (mantissa >= 0x0800) mantissa -= 0x1000;
  if (exponent >= 0x08) exponent -= 0x10;

  return mantissa * pow(10, exponent).toDouble();
}

/// Parsea la característica Glucose Measurement (0x2A18) según la
/// especificación del Bluetooth SIG — port exacto de
/// `parseGlucoseMeasurement` en `ble-glucose-meter.service.ts`. `bytes` es
/// el valor crudo notificado por la característica.
BleGlucoseMeasurement parseGlucoseMeasurement(List<int> bytes, String deviceName) {
  final data = ByteData.sublistView(Uint8List.fromList(bytes));

  final flags = data.getUint8(0);
  final timeOffsetPresent = (flags & 0x01) != 0;
  final glucosePresent = (flags & 0x02) != 0;
  final isMmol = (flags & 0x04) != 0;

  var offset = 1;
  offset += 2; // número de secuencia — se parsea implícitamente al avanzar el offset, valor descartado

  final year = data.getUint16(offset, Endian.little);
  offset += 2;
  final month = data.getUint8(offset);
  offset += 1;
  final day = data.getUint8(offset);
  offset += 1;
  final hour = data.getUint8(offset);
  offset += 1;
  final minute = data.getUint8(offset);
  offset += 1;
  final second = data.getUint8(offset);
  offset += 1;

  var measuredAt = DateTime(year, month, day, hour, minute, second);

  if (timeOffsetPresent) {
    final timeOffsetMinutes = data.getInt16(offset, Endian.little);
    offset += 2;
    measuredAt = measuredAt.add(Duration(minutes: timeOffsetMinutes));
  }

  if (!glucosePresent) {
    throw const FormatException('La medición del glucómetro no incluye un valor de glucosa');
  }

  final rawConcentration = data.getUint16(offset, Endian.little);
  final concentration = parseSfloat(rawConcentration);

  // El estándar reporta la concentración en kg/L o mol/L, nunca directamente
  // en mg/dL o mmol/L: kg/L -> mg/dL es *100000 (kg/L -> g/L *1000 -> mg/L
  // *1000 -> mg/dL /10); mol/L -> mmol/L es *1000 por definición del
  // prefijo "mili" (mismo cálculo que `ble-glucose-meter.service.ts`).
  final GlucoseUnit unit;
  final double value;
  if (isMmol) {
    unit = GlucoseUnit.mmolL;
    value = (concentration * 1000 * 10).round() / 10;
  } else {
    unit = GlucoseUnit.mgDl;
    value = (concentration * 100000).round().toDouble();
  }

  return BleGlucoseMeasurement(value: value, unit: unit, measuredAt: measuredAt, deviceName: deviceName);
}
