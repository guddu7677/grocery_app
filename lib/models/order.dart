class Order {
  final String? id;
  final String userId;
  final String productId;
  final String productName;
  final double productPrice;
  final String productImage;
  final int quantity;
  final Map<String, String> address;
  final double subtotal;
  final double deliveryFee;
  final double totalAmount;
  final String status;
  final DateTime? createdAt;
  final DateTime? estimatedDelivery;

  Order({
    this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productImage,
    required this.quantity,
    required this.address,
    required this.subtotal,
    required this.deliveryFee,
    required this.totalAmount,
    required this.status,
    this.createdAt,
    this.estimatedDelivery,
  });

  factory Order.fromFirestore(Map<String, dynamic> data, String id) {
    return Order(
      id: id,
      userId: data['userId'] ?? '',
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      productPrice: (data['productPrice'] ?? 0).toDouble(),
      productImage: data['productImage'] ?? '📦',
      quantity: data['quantity'] ?? 1,
      address: Map<String, String>.from(data['address'] ?? {}),
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      deliveryFee: (data['deliveryFee'] ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              data['createdAt'].millisecondsSinceEpoch)
          : null,
      estimatedDelivery: data['estimatedDelivery'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              data['estimatedDelivery'].millisecondsSinceEpoch)
          : null,
    );
  }
}