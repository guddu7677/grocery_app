import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/product.dart';
import '../models/address.dart';
import '../models/order.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }
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
  Future<void> deleteAddress(String addressId) async {
    try {
      await _firestore.collection('addresses').doc(addressId).delete();
    } catch (e) {
      print('Error deleting address: $e');
      rethrow;
    }
  }
  Future<void> setDefaultAddress(String userId, String addressId) async {
    try {
      final batch = _firestore.batch();
      
      final addresses = await _firestore
          .collection('addresses')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in addresses.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }

      final addressRef = _firestore.collection('addresses').doc(addressId);
      batch.update(addressRef, {'isDefault': true});

      await batch.commit();
    } catch (e) {
      print('Error setting default address: $e');
      rethrow;
    }
  }

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

  Stream<List<Order>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs.map((doc) {
        return Order.fromFirestore(doc.data(), doc.id);
      }).toList();
      
      orders.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      
      return orders;
    });
  }

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
  Stream<List<Order>> getOrdersByStatus(String userId, String status) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs.map((doc) {
        return Order.fromFirestore(doc.data(), doc.id);
      }).toList();
      
            orders.sort((a, b) {
        if (a.createdAt == null && b.createdAt == null) return 0;
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      
      return orders;
    });
  }

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