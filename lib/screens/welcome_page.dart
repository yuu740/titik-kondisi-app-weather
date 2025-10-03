import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  final VoidCallback onStart;

  const WelcomePage({super.key, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud, size: 100, color: Colors.blue),
          const SizedBox(height: 20),
          const Text(
            'TitikKondisi',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Prakiraan cuaca akurat dengan info langit malam terkini.',
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onStart,
            child: const Text('Mulai eksplorasi'),
          ),
        ],
      ),
    );
  }
}
