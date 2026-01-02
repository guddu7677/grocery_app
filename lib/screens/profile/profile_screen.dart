// ==================== FILE 3: lib/screens/profile/profile_screen.dart ====================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
           SizedBox(height: 24),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.green,
              child: Text(
                user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
           SizedBox(height: 16),
            Text(
              user?.displayName ?? 'User',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
             SizedBox(height: 8),
            Text(
              user?.email ?? '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
             SizedBox(height: 32),
            _buildProfileOption(
              context,
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () {
                _showEditNameDialog(context, authProvider);
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.location_on_outlined,
              title: 'My Addresses',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text('My Addresses - Coming Soon')),
                );
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text('Notifications - Coming Soon')),
                );
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.payment_outlined,
              title: 'Payment Methods',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text('Payment Methods - Coming Soon')),
                );
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text('Help & Support - Coming Soon')),
                );
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text('Privacy Policy - Coming Soon')),
                );
              },
            ),
            _buildProfileOption(
              context,
              icon: Icons.info_outline,
              title: 'About',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Grocery App',
                  applicationVersion: '1.0.0',
                  applicationIcon: Icon(Icons.shopping_bag, size: 48, color: Colors.green),
                  children: [
                     SizedBox(height: 16),
                     Text('Your one-stop shop for fresh groceries delivered to your doorstep.'),
                  ],
                );
              },
            ),
           Divider(height: 32, thickness: 1),
            _buildProfileOption(
              context,
              icon: Icons.logout,
              title: 'Logout',
              textColor: Colors.red,
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Logout'),
                    content: Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  await authProvider.signOut();
                }
              },
            ),
           SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.grey[700]),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: textColor ?? Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  void _showEditNameDialog(BuildContext context, AuthProvider authProvider) {
    final TextEditingController nameController = TextEditingController(
      text: authProvider.currentUser?.displayName ?? '',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Name'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Display Name',
              hintText: 'Enter your name',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your name';
              }
              if (value.trim().length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final newName = nameController.text.trim();
                Navigator.of(ctx).pop();
                
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );

                try {
                  await authProvider.updateDisplayName(newName);
                  
                  if (context.mounted) {
                    Navigator.of(context).pop(); 
                    ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(
                        content: Text('Name updated successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.of(context).pop(); // Close loading dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error updating name: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
}