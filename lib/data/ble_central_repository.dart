import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import '../core/ble_uuid.dart';

class BleCentralRepository {
  final FlutterReactiveBle _ble = FlutterReactiveBle();

  Stream<DiscoveredDevice> scan() {
    return _ble.scanForDevices(
      withServices: [BleUuids.serviceUuid],
      scanMode: ScanMode.lowLatency,
    );
  }

  Stream<ConnectionStateUpdate> connect(String deviceId) {
    return _ble.connectToDevice(
      id: deviceId,
      connectionTimeout: const Duration(seconds: 10),
    );
  }

  Future<void> write(String deviceId, List<int> data) async {
    final characteristic = QualifiedCharacteristic(
      serviceId: BleUuids.serviceUuid,
      characteristicId: BleUuids.characteristicUuid,
      deviceId: deviceId,
    );

    await _ble.writeCharacteristicWithResponse(characteristic, value: data);
  }

  Stream<List<int>> subscribe(String deviceId) {
    final characteristic = QualifiedCharacteristic(
      serviceId: BleUuids.serviceUuid,
      characteristicId: BleUuids.characteristicUuid,
      deviceId: deviceId,
    );

    return _ble.subscribeToCharacteristic(characteristic);
  }
}
