import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'bloc/ble_bloc.dart';
import 'bloc/ble_event.dart';
import 'bloc/ble_state.dart';
import 'data/ble_central_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (_) => BleBloc(BleCentralRepository()),
        child: const BlePage(),
      ),
    );
  }
}

class BlePage extends StatefulWidget {
  const BlePage({super.key});

  @override
  State<BlePage> createState() => _BlePageState();
}

class _BlePageState extends State<BlePage> {
  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await Permission.location.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothAdvertise.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("BLE Tester"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<BleBloc, BleState>(
          builder: (context, state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Status: ${state.status.name}",
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final locationStatus = await Permission.location.status;
                    final bluetoothStatus =
                        await Permission.bluetoothScan.status;

                    if (!locationStatus.isGranted ||
                        !bluetoothStatus.isGranted) {
                      await _requestPermissions();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Permissions requested. Please try again.',
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    context.read<BleBloc>().add(StartScan());
                  },
                  child: const Text("Scan"),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Discovered Devices:",
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    itemCount: state.discoveredDevices.length,
                    itemBuilder: (context, index) {
                      final device = state.discoveredDevices[index];
                      return Card(
                        color: Colors.grey[800],
                        child: ListTile(
                          title: Text(
                            device.name.isEmpty
                                ? "Unknown Device"
                                : device.name,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            device.id,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: Text(
                            "${device.rssi} dBm",
                            style: const TextStyle(color: Colors.green),
                          ),
                          onTap: () {
                            context.read<BleBloc>().add(
                              ConnectToDevice(device.id),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (state.deviceId != null) {
                      context.read<BleBloc>().add(SendData([42]));
                    }
                  },
                  child: const Text("Send 42"),
                ),
                const SizedBox(height: 20),
                const Text("Logs:", style: TextStyle(color: Colors.white)),
                const SizedBox(height: 10),
                Expanded(
                  flex: 1,
                  child: ListView(
                    children: state.logs
                        .map(
                          (log) => Text(
                            log,
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
