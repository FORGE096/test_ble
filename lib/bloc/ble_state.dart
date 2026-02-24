import 'package:equatable/equatable.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

enum AppBleStatus { idle, scanning, connecting, connected, disconnected, error }

class BleState extends Equatable {
  final AppBleStatus status;
  final String? deviceId;
  final List<String> logs;
  final List<DiscoveredDevice> discoveredDevices;

  const BleState({
    this.status = AppBleStatus.idle,
    this.deviceId,
    this.logs = const [],
    this.discoveredDevices = const [],
  });

  BleState copyWith({
    AppBleStatus? status,
    String? deviceId,
    List<String>? logs,
    List<DiscoveredDevice>? discoveredDevices,
  }) {
    return BleState(
      status: status ?? this.status,
      deviceId: deviceId ?? this.deviceId,
      logs: logs ?? this.logs,
      discoveredDevices: discoveredDevices ?? this.discoveredDevices,
    );
  }

  @override
  List<Object?> get props => [status, deviceId, logs, discoveredDevices];
}
