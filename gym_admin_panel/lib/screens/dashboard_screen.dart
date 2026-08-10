import 'package:flutter/material.dart';
import 'pos_screen.dart';
import 'clients_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Panel de Administración del Gimnasio')),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.point_of_sale, size: 40),
              label: const Text('Punto de Venta (POS)', style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(24)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PosScreen())),
            ),
            const SizedBox(width: 40),
            ElevatedButton.icon(
              icon: const Icon(Icons.people, size: 40),
              label: const Text('Clientes', style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(24)),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientsScreen())),
            ),
          ],
        ),
      ),
    );
  }
}
