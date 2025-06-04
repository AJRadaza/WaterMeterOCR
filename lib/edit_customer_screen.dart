import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class EditCustomerScreen extends StatefulWidget {
  final Future<Database> database;
  final Map<String, dynamic>? customer;

  const EditCustomerScreen({Key? key, required this.database, required this.customer}) : super(key: key);

  @override
  _EditCustomerScreenState createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _serviceType = 'Residential';
  bool _showLoginDetails = false;

  @override
  void initState() {
    super.initState();
    _loadCustomerDetails();
  }

  void _loadCustomerDetails() {
    if (widget.customer != null) {
      _fullNameController.text = widget.customer!['full_name'];
      _addressController.text = widget.customer!['address'];
      _emailController.text = widget.customer!['email'];
      _phoneNumberController.text = widget.customer!['phone_number'];
      _serviceType = widget.customer!['service_type'];
      _loadLoginDetails();
    }
  }

  Future<void> _loadLoginDetails() async {
    final db = await widget.database;

    final List<Map<String, dynamic>> accounts = await db.query(
      'accounts',
      where: 'user_id = ? AND role = ?',
      whereArgs: [widget.customer!['customer_id'], 'customer'],
    );

    if (accounts.isNotEmpty) {
      _usernameController.text = accounts.first['username'];
      _passwordController.text = accounts.first['password'];
    }
  }

  Future<void> _editCustomer() async {
    if (_formKey.currentState!.validate()) {
      final db = await widget.database;

      await db.update(
        'customers',
        {
          'full_name': _fullNameController.text,
          'address': _addressController.text,
          'email': _emailController.text,
          'phone_number': _phoneNumberController.text,
          'service_type': _serviceType,
        },
        where: 'customer_id = ?',
        whereArgs: [widget.customer!['customer_id']],
      );

      if (_showLoginDetails) {
        await db.update(
          'accounts',
          {
            'username': _usernameController.text,
            'password': _passwordController.text, // Note: In a real app, hash the password before storing it
          },
          where: 'user_id = ? AND role = ?',
          whereArgs: [widget.customer!['customer_id'], 'customer'],
        );
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Customer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the full name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the phone number';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _serviceType,
                items: <String>['Residential', 'Commercial']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _serviceType = newValue!;
                  });
                },
                decoration: InputDecoration(labelText: 'Service Type'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => setState(() {
                  _showLoginDetails = !_showLoginDetails;
                }),
                child: Text(_showLoginDetails ? 'Hide Login Details' : 'Edit Login Details'),
              ),
              if (_showLoginDetails) ...[
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the username';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
              ],
              ElevatedButton(
                onPressed: _editCustomer,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}