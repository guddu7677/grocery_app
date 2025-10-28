// Run this script once to upload dummy products to Firestore
// You can create a button in your app to run this, or use Firebase Console

import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/dummy_products.dart';

class DataMigration {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadProductsToFirestore() async {
    try {
      print('Starting product upload to Firestore...');
      
      final batch = _firestore.batch();
      
      for (var product in dummyProducts) {
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
      print('✅ Successfully uploaded ${dummyProducts.length} products to Firestore!');
    } catch (e) {
      print('❌ Error uploading products: $e');
      throw e;
    }
  }

  // Check if products already exist
  Future<bool> productsExist() async {
    try {
      final snapshot = await _firestore.collection('products').limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking products: $e');
      return false;
    }
  }

  // Delete all products (use with caution!)
  Future<void> deleteAllProducts() async {
    try {
      print('Deleting all products...');
      final snapshot = await _firestore.collection('products').get();
      final batch = _firestore.batch();
      
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('✅ All products deleted');
    } catch (e) {
      print('❌ Error deleting products: $e');
      throw e;
    }
  }
}

// Usage example - Add this to a debug screen or button in your app:
/*
  ElevatedButton(
    onPressed: () async {
      final migration = DataMigration();
      
      // Check if products already exist
      final exists = await migration.productsExist();
      
      if (exists) {
        print('Products already exist in Firestore');
        // Optionally show dialog asking if user wants to re-upload
      } else {
        await migration.uploadProductsToFirestore();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Products uploaded successfully!')),
        );
      }
    },
    child: const Text('Upload Products to Firestore'),
  ),
*/