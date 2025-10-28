class Address {
  final String? id;
  final String userId;
  final String name;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String zipCode;
  final bool isDefault;

  Address({
    this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.addressLine1,
    this.addressLine2 = '',
    required this.city,
    required this.state,
    required this.zipCode,
    this.isDefault = false,
  });

  factory Address.fromFirestore(Map<String, dynamic> data, String id) {
    return Address(
      id: id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      addressLine1: data['addressLine1'] ?? '',
      addressLine2: data['addressLine2'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      zipCode: data['zipCode'] ?? '',
      isDefault: data['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'isDefault': isDefault,
    };
  }
}