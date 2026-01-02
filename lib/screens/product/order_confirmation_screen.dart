import 'package:flutter/material.dart';
import 'package:grocery_app/service/firestore_service.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final Product product;
  final Map<String, String> address;

   OrderConfirmationScreen({
    Key? key,
    required this.product,
    required this.address,
  }) : super(key: key);

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  final _firestoreService = FirestoreService();
  bool _isOrderPlaced = false;
  bool _hasError = false;
  String? _orderId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _placeOrder();
  }

  Future<void> _placeOrder() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.currentUser;
      
      if (user == null) {
        throw Exception('User not authenticated. Please login again.');
      }

      const double deliveryFee = 5.0;
      final double subtotal = widget.product.price;
      final double totalAmount = subtotal + deliveryFee;

      final order = Order(
        userId: user.uid,
        productId: widget.product.id,
        productName: widget.product.name,
        productPrice: widget.product.price,
        productImage: widget.product.image,
        quantity: 1,
        address: widget.address,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        totalAmount: totalAmount,
        status: 'confirmed',
        createdAt: DateTime.now(),
        estimatedDelivery: DateTime.now().add(const Duration(days: 3)),
      );

      final orderId = await _firestoreService.createOrder(order);

      if (!mounted) return;

      setState(() {
        _isOrderPlaced = true;
        _orderId = orderId;
        _hasError = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to place order: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _placeOrder,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Order Failed'),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 80,
                ),
                 SizedBox(height: 24),
                 Text(
                  'Order Placement Failed',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                 SizedBox(height: 16),
                Text(
                  _errorMessage ?? 'An unexpected error occurred',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                 SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _hasError = false;
                    });
                    _placeOrder();
                  },
                  icon:  Icon(Icons.refresh),
                  label:  Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    padding:  EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
                 SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isOrderPlaced) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Processing Order'),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 24),
              Text(
                'Placing your order...',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Please wait',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    const double deliveryFee = 5.0;
    final double subtotal = widget.product.price;
    final double totalAmount = subtotal + deliveryFee;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order Confirmation'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
             SizedBox(height: 16),
            
             Text(
              'Order Confirmed!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
             SizedBox(height: 8),
            
            if (_orderId != null)
              Text(
                'Order ID: ${_orderId!.substring(0, 8).toUpperCase()}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
             SizedBox(height: 4),
            Text(
              'Your order has been placed successfully',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
             SizedBox(height: 32),
            
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      'Order Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                     SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            widget.product.image,
                            style: TextStyle(fontSize: 40),
                          ),
                        ),
                         SizedBox(width: 16),
                        
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                               SizedBox(height: 4),
                              Text(
                                widget.product.category,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                               SizedBox(height: 8),
                              Text(
                                '₹${widget.product.price.toStringAsFixed(2)}',
                                style:  TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
             SizedBox(height: 16),
            
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Row(
                      children: [
                        Icon(Icons.location_on, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Delivery Address',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                     SizedBox(height: 12),
                    Text(
                      widget.address['name'] ?? '',
                      style:  TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                     SizedBox(height: 4),
                    Text(
                      widget.address['phone'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                     SizedBox(height: 8),
                    Text(
                      widget.address['addressLine1'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    if (widget.address['addressLine2']?.isNotEmpty ?? false) ...[
                       SizedBox(height: 4),
                      Text(
                        widget.address['addressLine2']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                     SizedBox(height: 4),
                    Text(
                      '${widget.address['city']}, ${widget.address['state']} ${widget.address['zipCode']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
             SizedBox(height: 16),
            
            Card(
              color: Colors.blue[50],
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text(
                          'Subtotal:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '₹${subtotal.toStringAsFixed(2)}',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                     SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text(
                          'Delivery Fee:',
                          style: TextStyle(fontSize: 16),
                        ),
                        Text(
                          '₹${deliveryFee.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                     Divider(height: 24, thickness: 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₹${totalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
             SizedBox(height: 24),
            
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber[800]),
                   SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your order will be delivered in 2-3 business days',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.amber[900],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
             SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                padding:  EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:  Text(
                'Continue Shopping',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
             SizedBox(height: 12),
            
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                
                Future.delayed( Duration(milliseconds: 500), () {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(
                        content: Text('Go to "Orders" tab to track your order'),
                        duration: Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                });
              },
              icon:  Icon(Icons.receipt_long),
              label:  Text(
                'View My Orders',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
             SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}