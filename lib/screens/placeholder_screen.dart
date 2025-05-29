import 'package:flutter/material.dart';

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parkit'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Pantallas en desarrollo. ¡Próximamente!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}