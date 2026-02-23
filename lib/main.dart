import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class BlePage extends StatelessWidget {
  const BlePage({super.key});

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
                  onPressed: () {
                    context.read<BleBloc>().add(StartScan());
                  },
                  child: const Text("Scan"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (state.deviceId != null) {
                      context.read<BleBloc>().add(SendData([42]));
                    }
                  },
                  child: const Text("Send 42"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    context.read<BleBloc>().add(DisconnectDevice());
                  },
                  child: const Text("Disconnect"),
                ),
                const SizedBox(height: 20),
                const Text("Logs:", style: TextStyle(color: Colors.white)),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    children: state.logs
                        .map(
                          (log) => Text(
                            log,
                            style: const TextStyle(color: Colors.green),
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
