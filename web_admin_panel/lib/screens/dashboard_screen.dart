import 'package:flutter/material.dart';
import '../models/tenant.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Tenant>> _tenantsFuture;

  @override
  void initState() {
    super.initState();
    _loadTenants();
  }

  void _loadTenants() {
    setState(() {
      _tenantsFuture = _apiService.getTenants();
    });
  }

  Future<void> _logout() async {
    await _apiService.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _updateStatus(int id, String newStatus) async {
    try {
      await _apiService.updateTenantStatus(id, newStatus);
      _loadTenants();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estado actualizado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showAddTenantDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nuevo Gimnasio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Correo')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Teléfono')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              try {
                await _apiService.createTenant(
                  nameController.text,
                  emailController.text,
                  phoneController.text,
                );
                Navigator.pop(context);
                _loadTenants();
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
      appBar: AppBar(
        title: const Text('Panel de Control - Súper Administrador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar Sesión',
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTenantDialog,
        child: const Icon(Icons.add),
        tooltip: 'Añadir Gimnasio',
      ),
      body: FutureBuilder<List<Tenant>>(
        future: _tenantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay gimnasios registrados.'));
          }

          final tenants = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tenants.length,
            itemBuilder: (context, index) {
              final tenant = tenants[index];
              return Card(
                child: ListTile(
                  title: Text(tenant.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Estado: ${tenant.status} | Email: ${tenant.email ?? "N/A"}'),
                  trailing: DropdownButton<String>(
                    value: tenant.status,
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Activo')),
                      DropdownMenuItem(value: 'paused', child: Text('Pausado')),
                      DropdownMenuItem(value: 'inactive', child: Text('Inactivo')),
                    ],
                    onChanged: (newStatus) {
                      if (newStatus != null && newStatus != tenant.status) {
                        _updateStatus(tenant.id, newStatus);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
