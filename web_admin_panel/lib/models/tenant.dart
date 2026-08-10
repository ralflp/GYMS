class Tenant {
  final int id;
  final String name;
  final String status;
  final String? email;
  final String? phone;

  Tenant({
    required this.id,
    required this.name,
    required this.status,
    this.email,
    this.phone,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      email: json['email'],
      phone: json['phone'],
    );
  }
}
