import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class MyProfileScreen extends StatefulWidget {
  final Future<Database> database;
  final int customerId;

  MyProfileScreen({required this.database, required this.customerId});

  @override
  _MyProfileScreenState createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
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

  void _loadCustomerDetails() async {
    final db = await widget.database;
    final result = await db.query(
      'customers',
      where: 'customer_id = ?',
      whereArgs: [widget.customerId],
    );

    if (result.isNotEmpty) {
      setState(() {
        _fullNameController.text = result.first['full_name'] as String;
        _addressController.text = result.first['address'] as String;
        _emailController.text = result.first['email'] as String;
        _phoneNumberController.text = result.first['phone_number'] as String;
        _serviceType = result.first['service_type'] as String;
      });
      _loadLoginDetails();
    }
  }

  Future<void> _loadLoginDetails() async {
    final db = await widget.database;

    final List<Map<String, dynamic>> accounts = await db.query(
      'accounts',
      where: 'user_id = ? AND role = ?',
      whereArgs: [widget.customerId, 'customer'],
    );

    if (accounts.isNotEmpty) {
      setState(() {
        _usernameController.text = accounts.first['username'];
        _passwordController.text = accounts.first['password'];
      });
    }
  }

  Future<void> _editCustomer(BuildContext context) async {
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
      whereArgs: [widget.customerId],
    );

    if (_showLoginDetails) {
      await db.update(
        'accounts',
        {
          'username': _usernameController.text,
          'password': _passwordController.text, // Note: In a real app, hash the password before storing it
        },
        where: 'user_id = ? AND role = ?',
        whereArgs: [widget.customerId, 'customer'],
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Text(
                'Customer details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _phoneNumberController,
              decoration: InputDecoration(labelText: 'Phone Number'),
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
            Center(
              child: ElevatedButton(
                onPressed: () => setState(() {
                  _showLoginDetails = !_showLoginDetails;
                }),
                child: Text(_showLoginDetails ? 'Hide Login Details' : 'Edit Login Details'),
              ),
            ),
            if (_showLoginDetails) ...[
              Center(
                child: Text(
                  'Login details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              SizedBox(height: 20),
            ],
            Center(
              child: ElevatedButton(
                onPressed: () => _editCustomer(context),
                child: Text('Save changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}