import 'package:flutter/material.dart';
import 'package:grocery_app/service/firestore_service.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../models/address.dart';
import '../../providers/auth_provider.dart';
import 'order_confirmation_screen.dart';

class AddressInputScreen extends StatefulWidget {
  final Product product;

  const AddressInputScreen({super.key, required this.product});

  @override
  State<AddressInputScreen> createState() => _AddressInputScreenState();
}

class _AddressInputScreenState extends State<AddressInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _firestoreService = FirestoreService();
  
  bool _isLoading = false;
  bool _saveAddress = false;
  Address? _selectedAddress;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  void _loadAddress(Address address) {
    setState(() {
      _selectedAddress = address;
      _nameController.text = address.name;
      _phoneController.text = address.phone;
      _addressLine1Controller.text = address.addressLine1;
      _addressLine2Controller.text = address.addressLine2;
      _cityController.text = address.city;
      _stateController.text = address.state;
      _zipCodeController.text = address.zipCode;
    });
  }

  void _submitAddress() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
        
        if (user == null) {
          throw Exception('User not authenticated');
        }

        final addressData = {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'addressLine1': _addressLine1Controller.text.trim(),
          'addressLine2': _addressLine2Controller.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          'zipCode': _zipCodeController.text.trim(),
        };

        if (_saveAddress && _selectedAddress == null) {
          final newAddress = Address(
            userId: user.uid,
            name: addressData['name']!,
            phone: addressData['phone']!,
            addressLine1: addressData['addressLine1']!,
            addressLine2: addressData['addressLine2']!,
            city: addressData['city']!,
            state: addressData['state']!,
            zipCode: addressData['zipCode']!,
          );
          
          await _firestoreService.addAddress(newAddress);
        }

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderConfirmationScreen(
              product: widget.product,
              address: addressData,
            ),
          ),
        );
      } catch (e) {
        setState(() => _isLoading = false);
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      appBar: AppBar(
        title:  Text('Delivery Address'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding:  EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.product.image,
                        style: TextStyle(fontSize: 30),
                      ),
                    ),
                     SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.product.name,
                            style:  TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                           SizedBox(height: 4),
                          Text(
                            '\$${widget.product.price.toStringAsFixed(2)}',
                            style:  TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
             SizedBox(height: 16),
            
            if (user != null)
              StreamBuilder<List<Address>>(
                stream: _firestoreService.getUserAddresses(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saved Addresses',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                         SizedBox(height: 8),
                        ...snapshot.data!.map((address) {
                          final isSelected = _selectedAddress?.id == address.id;
                          return Card(
                            color: isSelected ? Colors.blue[50] : null,
                            margin: EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Icon(
                                isSelected
                                    ? Icons.check_circle
                                    : Icons.location_on_outlined,
                                color: isSelected ? Colors.blue : null,
                              ),
                              title: Text(address.name),
                              subtitle: Text(
                                '${address.addressLine1}\n${address.city}, ${address.state}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: address.isDefault
                                  ? Chip(
                                      label: Text(
                                        'Default',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      backgroundColor: Colors.green[100],
                                    )
                                  : null,
                              onTap: () => _loadAddress(address),
                            ),
                          );
                        }).toList(),
                         Divider(height: 32),
                         Text(
                          'Or Enter New Address',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                       SizedBox(height: 16),
                      ],
                    );
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter Delivery Address',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  );
                },
              ),
            
            TextFormField(
              controller: _nameController,
              decoration:InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
           SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration:InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                if (value.trim().length < 10) {
                  return 'Please enter a valid phone number';
                }
                return null;
              },
            ),
             SizedBox(height: 16),
            TextFormField(
              controller: _addressLine1Controller,
              decoration:  InputDecoration(
                labelText: 'Address Line 1',
                prefixIcon: Icon(Icons.home),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
             SizedBox(height: 16),
            TextFormField(
              controller: _addressLine2Controller,
              decoration:  InputDecoration(
                labelText: 'Address Line 2 (Optional)',
                prefixIcon: Icon(Icons.home_outlined),
                border: OutlineInputBorder(),
              ),
            ),
           SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'City',
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                 SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    decoration: InputDecoration(
                      labelText: 'State',
                      prefixIcon: Icon(Icons.map),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
             SizedBox(height: 16),
            TextFormField(
              controller: _zipCodeController,
              decoration: InputDecoration(
                labelText: 'ZIP Code',
                prefixIcon: Icon(Icons.pin_drop),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter ZIP code';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            CheckboxListTile(
              title:Text('Save this address for future orders'),
              value: _saveAddress,
              onChanged: _selectedAddress == null
                  ? (value) {
                      setState(() => _saveAddress = value ?? false);
                    }
                  : null,
              controlAffinity: ListTileControlAffinity.leading,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitAddress,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Proceed to Payment',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}