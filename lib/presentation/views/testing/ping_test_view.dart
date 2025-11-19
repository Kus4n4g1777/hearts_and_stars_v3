import 'package:flutter/material.dart';
import '../../../services/api_service.dart';

class PingTestView extends StatefulWidget {
  const PingTestView({super.key});

  @override
  State<PingTestView> createState() => _PingTestViewState();
}

class _PingTestViewState extends State<PingTestView> {
  String _message = "Press the button to ping FastAPI";
  final ApiService _api = ApiService();

  void _getPing() async {
    try {
      final result = await _api.ping();
      setState(() {
        _message = result;
      });
    } catch (e) {
      setState(() {
        _message = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FastAPI Connection Test")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_message, style: const TextStyle(fontSize: 20, color: Colors.white)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _getPing,
              child: const Text("Ping FastAPI"),
            )
          ],
        ),
      ),
    );
  }
}