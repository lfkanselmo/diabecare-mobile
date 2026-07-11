import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'ble_glucose_measurement.dart';
import 'sfloat_parser.dart';

/// Port directo de `ble-glucose-meter.service.ts` — mismo protocolo GATT
/// estándar (Glucose Service 0x1808, Glucose Measurement 0x2A18, Record
/// Access Control Point 0x2A52), sin conexión persistente: escanea, conecta,
/// lee la última medición y desconecta, todo dentro de una sola llamada.
class BleGlucoseMeterService {
  static final glucoseServiceUuid = Guid('00001808-0000-1000-8000-00805f9b34fb');
  static final _measurementCharUuid = Guid('00002a18-0000-1000-8000-00805f9b34fb');
  static final _racpCharUuid = Guid('00002a52-0000-1000-8000-00805f9b34fb');

  // Opcode 1 (Report Stored Records), operador 6 (Last record) — le pide al
  // glucómetro que envíe solo su última lectura.
  static final _racpReportLastRecord = [0x01, 0x06];
  static const _scanTimeout = Duration(seconds: 15);
  static const _notificationTimeout = Duration(seconds: 15);

  Future<bool> isSupported() => FlutterBluePlus.isSupported;

  Future<BleGlucoseMeasurement> readLatestMeasurement() async {
    if (!await isSupported()) {
      throw StateError('Este dispositivo no soporta Bluetooth de bajo consumo');
    }

    BluetoothDevice? device;
    try {
      device = await _pickDevice();
      await device.connect(timeout: const Duration(seconds: 10));

      final services = await device.discoverServices();
      final glucoseService = services.firstWhere(
        (s) => s.uuid == glucoseServiceUuid,
        orElse: () => throw StateError('El dispositivo no expone el servicio de glucosa'),
      );

      final measurementChar = glucoseService.characteristics.firstWhere(
        (c) => c.uuid == _measurementCharUuid,
      );
      final racpChar = glucoseService.characteristics.firstWhere((c) => c.uuid == _racpCharUuid);

      final measurementFuture = _waitForMeasurement(measurementChar, device.platformName);

      await measurementChar.setNotifyValue(true);
      await racpChar.write(_racpReportLastRecord, withoutResponse: false);

      return await measurementFuture;
    } finally {
      await device?.disconnect();
    }
  }

  Future<BluetoothDevice> _pickDevice() async {
    final completer = Completer<BluetoothDevice>();
    late final StreamSubscription<List<ScanResult>> subscription;

    subscription = FlutterBluePlus.scanResults.listen((results) {
      for (final result in results) {
        if (result.advertisementData.serviceUuids.contains(glucoseServiceUuid)) {
          if (!completer.isCompleted) completer.complete(result.device);
          subscription.cancel();
          FlutterBluePlus.stopScan();
          break;
        }
      }
    });

    await FlutterBluePlus.startScan(withServices: [glucoseServiceUuid], timeout: _scanTimeout);

    return completer.future.timeout(
      _scanTimeout + const Duration(seconds: 1),
      onTimeout: () {
        subscription.cancel();
        throw StateError('No se encontró ningún glucómetro cercano');
      },
    );
  }

  Future<BleGlucoseMeasurement> _waitForMeasurement(
    BluetoothCharacteristic characteristic,
    String deviceName,
  ) {
    final completer = Completer<BleGlucoseMeasurement>();
    late final StreamSubscription<List<int>> subscription;

    final timer = Timer(_notificationTimeout, () {
      if (!completer.isCompleted) {
        subscription.cancel();
        completer.completeError(StateError('El glucómetro no respondió a tiempo'));
      }
    });

    subscription = characteristic.onValueReceived.listen((value) {
      timer.cancel();
      subscription.cancel();
      try {
        completer.complete(parseGlucoseMeasurement(value, deviceName));
      } catch (e) {
        completer.completeError(e);
      }
    });

    return completer.future;
  }
}
