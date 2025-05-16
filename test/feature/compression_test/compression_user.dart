import 'package:vexana/vexana.dart';

final class CompressionUser extends INetworkModel<CompressionUser> {
  const CompressionUser({
    required this.zip,
    required this.phone,
    required this.name,
    required this.email,
    required this.address,
    required this.city,
    required this.state,
  });

  final String name;
  final String email;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String zip;

  @override
  List<Object?> get props => [name, email, phone, address, city, state, zip];

  static final List<CompressionUser> dummyUserList = List.generate(
    10,
    (index) => CompressionUser(
      name: 'John Doe $index',
      email: 'john.doe@example.com',
      phone: '1234567890',
      address: '123 Main St',
      city: 'Anytown',
      state: 'CA',
      zip: '12345',
    ),
  );

  @override
  CompressionUser fromJson(Map<String, dynamic> json) {
    return CompressionUser(
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zip: json['zip'] as String,
    );
  }

  @override
  Map<String, dynamic>? toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'zip': zip,
    };
  }
}
