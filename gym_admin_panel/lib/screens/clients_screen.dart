import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  _ClientsScreenState createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final _apiService = ApiService();
  late Future<List<Client>> _clientsFuture;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  void _loadClients() {
    setState(() {
      _clientsFuture = _apiService.getClients();
    });
  }

  void _showAddClientDialog() {
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final faceIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Cliente'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: firstNameController, decoration: const InputDecoration(labelText: 'Nombre')),
              TextField(controller: lastNameController, decoration: const InputDecoration(labelText: 'Apellido')),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Correo')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Teléfono')),
              TextField(controller: faceIdController, decoration: const InputDecoration(labelText: 'Face ID (Hik-Connect ID)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              try {
                await _apiService.createClient(
                  firstNameController.text,
                  lastNameController.text,
                  emailController.text,
                  phoneController.text,
                  faceIdController.text,
                );
                Navigator.pop(context);
                _loadClients();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Clientes')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddClientDialog,
        child: const Icon(Icons.add),
        tooltip: 'Añadir Cliente',
      ),
      body: FutureBuilder<List<Client>>(
        future: _clientsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          final clients = snapshot.data ?? [];
          return ListView.builder(
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text('${client.firstName} ${client.lastName}'),
                subtitle: Text(client.email ?? 'Sin email'),
              );
            },
          );
        },
      ),
    );
  }
}
