import 'package:flutter/material.dart';
import 'services/api_service.dart';

class ApiTestView extends StatefulWidget {
  const ApiTestView({super.key});

  @override
  State<ApiTestView> createState() => _ApiTestViewState();
}

class _ApiTestViewState extends State<ApiTestView> {
  String _message = "Press the button to ping FastAPI";

  final ApiService _api = ApiService();

  void _getPing() async {
    final result = await _api.ping();
    setState((){
      _message = result;
    })
  }

  @override
  Widget build(Buildcontext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("FastAPI Connection Test")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_message, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _getPing,
              child: const Text("Ping FastAPI"),
            )
          ]
        )
      )
    )
  }
}