import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/product.dart';
import '../models/address.dart';
import '../models/order.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== PRODUCTS ====================
  
  /// Get all products as a stream (real-time updates)
  Stream<List<Product>> getProducts() {
    return _firestore
        .collection('products')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Get a single product by ID
  Future<Product?> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists && doc.data() != null) {
        return Product.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting product: $e');
      rethrow;
    }
  }

  /// Add a new product (admin only - use Firebase Console or Cloud Functions)
  Future<void> addProduct(Product product) async {
    try {
      await _firestore.collection('products').doc(product.id).set({
        'name': product.name,
        'category': product.category,
        'price': product.price,
        'image': product.image,
        'description': product.description,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    }
  }

  /// Update an existing product
  Future<void> updateProduct(String productId, Product product) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'name': product.name,
        'category': product.category,
        'price': product.price,
        'image': product.image,
        'description': product.description,
      });
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  /// Delete a product
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }

  // ==================== ADDRESSES ====================
  
  /// Get all addresses for a specific user
  Stream<List<Address>> getUserAddresses(String userId) {
    return _firestore
        .collection('addresses')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Address.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  /// Get a single address by ID
  Future<Address?> getAddressById(String addressId) async {
    try {
      final doc = await _firestore.collection('addresses').doc(addressId).get();
      if (doc.exists && doc.data() != null) {
        return Address.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting address: $e');
      rethrow;
    }
  }

  /// Add a new address for a user
  Future<String> addAddress(Address address) async {
    try {
      final docRef = await _firestore.collection('addresses').add({
        'userId': address.userId,
        'name': address.name,
        'phone': address.phone,
        'addressLine1': address.addressLine1,
        'addressLine2': address.addressLine2,
        'city': address.city,
        'state': address.state,
        'zipCode': address.zipCode,
        'isDefault': address.isDefault,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Error adding address: $e');
      rethrow;
    }
  }

  /// Update an existing address
  Future<void> updateAddress(String addressId, Address address) async {
    try {
      await _firestore.collection('addresses').doc(addressId).update({
        'name': address.name,
        'phone': address.phone,
        'addressLine1': address.addressLine1,
        'addressLine2': address.addressLine2,
        'city': address.city,
        'state': address.state,
        'zipCode': address.zipCode,
        'isDefault': address.isDefault,
      });
    } catch (e) {
      print('Error updating address: $e');
      rethrow;
    }
  }

  /// Delete an address
  Future<void> deleteAddress(String addressId) async {
    try {
      await _firestore.collection('addresses').doc(addressId).delete();
    } catch (e) {
      print('Error deleting address: $e');
      rethrow;
    }
  }

  /// Set a specific address as the default for a user
  Future<void> setDefaultAddress(String userId, String addressId) async {
    try {
      final batch = _firestore.batch();
      
      // Remove default from all user addresses
      final addresses = await _firestore
          .collection('addresses')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in addresses.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }

      // Set the new default address
      final addressRef = _firestore.collection('addresses').doc(addressId);
      batch.update(addressRef, {'isDefault': true});

      await batch.commit();
    } catch (e) {
      print('Error setting default address: $e');
      rethrow;
    }
  }

  /// Get the default address for a user
  Future<Address?> getDefaultAddress(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('addresses')
          .where('userId', isEqualTo: userId)
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        return Address.fromFirestore(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting default address: $e');
      rethrow;
    }
  }

  // ==================== ORDERS ====================
  
  /// Create a new order
  Future<String> createOrder(Order order) async {
    try {
      final docRef = await _firestore.collection('orders').add({
        'userId': order.userId,
        'productId': order.productId,
        'productName': order.productName,
        'productPrice': order.productPrice,
        'productImage': order.productImage,
        'quantity': order.quantity,
        'address': {
          'name': order.address['name'] ?? '',
          'phone': order.address['phone'] ?? '',
          'addressLine1': order.address['addressLine1'] ?? '',
          'addressLine2': order.address['addressLine2'] ?? '',
          'city': order.address['city'] ?? '',
          'state': order.address['state'] ?? '',
          'zipCode': order.address['zipCode'] ?? '',
        },
        'subtotal': order.subtotal,
        'deliveryFee': order.deliveryFee,
        'totalAmount': order.totalAmount,
        'status': order.status,
        'createdAt': FieldValue.serverTimestamp(),
        'estimatedDelivery': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 3)),
        ),
      });
      return docRef.id;
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  /// Get all orders for a specific user (NO COMPOSITE INDEX NEEDED)
  Stream<List<Order>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      // Get all orders and sort them in memory
      final orders = snapshot.docs.map((doc) {
        return Order.fromFirestore(doc.data(), doc.id);
      }).toList();
      
      // Sort by createdAt in memory (descending - newest first)
      orders.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      
      return orders;
    });
  }

  /// Get a single order by ID
  Future<Order?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists && doc.data() != null) {
        return Order.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting order: $e');
      rethrow;
    }
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
      });
    } catch (e) {
      print('Error updating order status: $e');
      rethrow;
    }
  }

  /// Get orders by status for a user (NO COMPOSITE INDEX NEEDED)
  Stream<List<Order>> getOrdersByStatus(String userId, String status) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
      // Get all orders matching the filters
      final orders = snapshot.docs.map((doc) {
        return Order.fromFirestore(doc.data(), doc.id);
      }).toList();
      
      // Sort by createdAt in memory (descending - newest first)
      orders.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      
      return orders;
    });
  }

  /// Cancel an order
  Future<void> cancelOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': 'cancelled',
      });
    } catch (e) {
      print('Error cancelling order: $e');
      rethrow;
    }
  }

  // ==================== BATCH OPERATIONS ====================
  
  /// Upload multiple products at once (for initial setup)
  Future<void> batchAddProducts(List<Product> products) async {
    try {
      final batch = _firestore.batch();
      
      for (var product in products) {
        final docRef = _firestore.collection('products').doc(product.id);
        batch.set(docRef, {
          'name': product.name,
          'category': product.category,
          'price': product.price,
          'image': product.image,
          'description': product.description,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
    } catch (e) {
      print('Error batch adding products: $e');
      rethrow;
    }
  }
}