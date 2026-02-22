import 'package:equatable/equatable.dart';

enum BleStatus { idle, scanning, connecting, connected, disconnected, error }

class BleState extends Equatable {
  final BleStatus status;
  final String? deviceId;
  final List<String> logs;

  const BleState({
    this.status = BleStatus.idle,
    this.deviceId,
    this.logs = const [],
  });

  BleState copyWith({BleStatus? status, String? deviceId, List<String>? logs}) {
    return BleState(
      status: status ?? this.status,
      deviceId: deviceId ?? this.deviceId,
      logs: logs ?? this.logs,
    );
  }

  @override
  List<Object?> get props => [status, deviceId, logs];
}
