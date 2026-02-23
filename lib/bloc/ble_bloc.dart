import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/ble_central_repository.dart';
import 'ble_event.dart';
import 'ble_state.dart';

class BleBloc extends Bloc<BleEvent, BleState> {
  final BleCentralRepository repository;

  StreamSubscription? _scanSub;
  StreamSubscription? _connectionSub;
  StreamSubscription? _dataSub;

  String? _connectedDevice;
  int _retryCount = 0;
  bool _manualDisconnect = false;

  BleBloc(this.repository) : super(const BleState()) {
    on<StartScan>(_onScan);
    on<ConnectToDevice>(_onConnect);
    on<DisconnectDevice>(_onDisconnect);
    on<SendData>(_onSendData);
  }

  void _log(String message, Emitter<BleState> emit) {
    final updated = List<String>.from(state.logs)..add(message);
    emit(state.copyWith(logs: updated));
  }

  void _onScan(StartScan event, Emitter<BleState> emit) {
    emit(state.copyWith(status: BleStatus.scanning));
    _log("Scanning started...", emit);

    _scanSub?.cancel();
    _scanSub = repository.scan().listen(
      (device) {
        _log("Found: ${device.name} - ${device.id}", emit);
      },
      onError: (error) {
        _log("Scan error: $error", emit);
        emit(state.copyWith(status: BleStatus.error));
      },
    );
  }

  void _onConnect(ConnectToDevice event, Emitter<BleState> emit) {
    _manualDisconnect = false;
    _connectedDevice = event.deviceId;

    emit(state.copyWith(status: BleStatus.connecting));
    _log("Connecting...", emit);

    _connectionSub?.cancel();
    _connectionSub = repository.connect(event.deviceId).listen((update) {
      if (update.connectionState.name == "connected") {
        emit(
          state.copyWith(status: BleStatus.connected, deviceId: event.deviceId),
        );
        _retryCount = 0;
        _log("Connected ✅", emit);

        _listenToData(emit);
      } else if (update.connectionState.name == "disconnected") {
        emit(state.copyWith(status: BleStatus.disconnected));
        _log("Disconnected ❌", emit);

        if (!_manualDisconnect) {
          _attemptReconnect(emit);
        }
      }
    });
  }

  void _listenToData(Emitter<BleState> emit) {
    if (_connectedDevice == null) return;

    _dataSub?.cancel();
    _dataSub = repository.subscribe(_connectedDevice!).listen((data) {
      _log("Received: $data", emit);
    });
  }

  void _attemptReconnect(Emitter<BleState> emit) async {
    if (_connectedDevice == null) return;

    _retryCount++;
    final delay = min(pow(2, _retryCount).toInt(), 10);

    _log("Reconnecting in $delay sec...", emit);
    await Future.delayed(Duration(seconds: delay));

    add(ConnectToDevice(_connectedDevice!));
  }

  void _onSendData(SendData event, Emitter<BleState> emit) async {
    if (_connectedDevice == null) return;

    await repository.write(_connectedDevice!, event.data);
    _log("Sent: ${event.data}", emit);
  }

  void _onDisconnect(DisconnectDevice event, Emitter<BleState> emit) {
    _manualDisconnect = true;
    _connectionSub?.cancel();
    emit(state.copyWith(status: BleStatus.disconnected));
    _log("Manual disconnect", emit);
  }

  @override
  Future<void> close() {
    _scanSub?.cancel();
    _connectionSub?.cancel();
    _dataSub?.cancel();
    return super.close();
  }
}
