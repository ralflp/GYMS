class Product {
  final int id;
  final String name;
  final double price;
  final int stock;

  Product({required this.id, required this.name, required this.price, required this.stock});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: double.parse(json['price'].toString()),
      stock: json['stock'],
    );
  }
}

class Membership {
  final int id;
  final String name;
  final double price;
  final int durationDays;

  Membership({required this.id, required this.name, required this.price, required this.durationDays});

  factory Membership.fromJson(Map<String, dynamic> json) {
    return Membership(
      id: json['id'],
      name: json['name'],
      price: double.parse(json['price'].toString()),
      durationDays: json['duration_days'],
    );
  }
}

class Client {
  final int id;
  final String firstName;
  final String lastName;
  final String? email;

  Client({required this.id, required this.firstName, required this.lastName, this.email});

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
    );
  }
}
