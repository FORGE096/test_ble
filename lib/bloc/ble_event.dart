import 'package:equatable/equatable.dart';

abstract class BleEvent extends Equatable {
  const BleEvent();

  @override
  List<Object?> get props => [];
}

class StartScan extends BleEvent {}

class ConnectToDevice extends BleEvent {
  final String deviceId;

  const ConnectToDevice(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

class DisconnectDevice extends BleEvent {}

class SendData extends BleEvent {
  final List<int> data;

  const SendData(this.data);

  @override
  List<Object?> get props => [data];
}
