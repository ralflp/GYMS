import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  _PosScreenState createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final _apiService = ApiService();
  List<Product> _products = [];
  List<Membership> _memberships = [];
  Client? _selectedClient;
  List<Client> _clients = [];
  final List<Map<String, dynamic>> _cart = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final clients = await _apiService.getClients();
    final products = await _apiService.getProducts();
    final memberships = await _apiService.getMemberships();
    setState(() {
      _clients = clients;
      _products = products;
      _memberships = memberships;
    });
  }

  void _addToCart(String type, dynamic item) {
    setState(() {
      final existingIndex = _cart.indexWhere((i) => i['id'] == item.id && i['type'] == type);
      if (existingIndex >= 0) {
        _cart[existingIndex]['quantity'] += 1;
      } else {
        _cart.add({
          'type': type,
          'id': item.id,
          'name': item.name,
          'price': item.price,
          'quantity': 1,
        });
      }
    });
  }

  double get _total => _cart.fold(0.0, (sum, item) => sum + (item['price'] * item['quantity']));

  Future<void> _processSale() async {
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccione un cliente')));
      return;
    }
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El carrito está vacío')));
      return;
    }

    try {
      await _apiService.processSale(_selectedClient!.id, _cart, _total);
      setState(() {
        _cart.clear();
        _selectedClient = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Venta procesada exitosamente')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Punto de Venta')),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      const ListTile(title: Text('Membresías', style: TextStyle(fontWeight: FontWeight.bold))),
                      ..._memberships.map((m) => ListTile(
                        title: Text(m.name),
                        trailing: Text('\$ ${m.price}'),
                        onTap: () => _addToCart('membership', m),
                      )),
                      const Divider(),
                      const ListTile(title: Text('Productos', style: TextStyle(fontWeight: FontWeight.bold))),
                      ..._products.map((p) => ListTile(
                        title: Text('${p.name} (Stock: ${p.stock})'),
                        trailing: Text('\$ ${p.price}'),
                        onTap: () => _addToCart('product', p),
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButton<Client>(
                    hint: const Text('Seleccionar Cliente'),
                    value: _selectedClient,
                    isExpanded: true,
                    items: _clients.map((c) => DropdownMenuItem(
                      value: c,
                      child: Text('${c.firstName} ${c.lastName}'),
                    )).toList(),
                    onChanged: (c) => setState(() => _selectedClient = c),
                  ),
                  const SizedBox(height: 16),
                  const Text('Carrito', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _cart.length,
                      itemBuilder: (context, index) {
                        final item = _cart[index];
                        return ListTile(
                          title: Text(item['name']),
                          subtitle: Text('Cant: ${item['quantity']} - Tipo: ${item['type']}'),
                          trailing: Text('\$ ${item['price']}'),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Text('Total: \$ $_total', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _processSale,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: const Text('COBRAR', style: TextStyle(fontSize: 20)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
