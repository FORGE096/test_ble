import 'dart:async';
import 'package:flutter_ble_peripheral/flutter_ble_peripheral.dart';
import '../core/ble_uuid.dart';

class BlePeripheralRepository {
  final FlutterBlePeripheral _peripheral = FlutterBlePeripheral();

  Future<void> startAdvertising() async {
    final advertiseData = AdvertiseData(
      serviceUuid: BleUuids.serviceUuid.toString(),
      includeDeviceName: true,
    );

    await _peripheral.start(advertiseData: advertiseData);
  }

  Future<void> stopAdvertising() async {
    await _peripheral.stop();
  }
}
