import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class RegisterCustomerScreen extends StatefulWidget {
  final Future<Database> database;

  const RegisterCustomerScreen({Key? key, required this.database}) : super(key: key);

  @override
  _RegisterCustomerScreenState createState() => _RegisterCustomerScreenState();
}

class _RegisterCustomerScreenState extends State<RegisterCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _serviceType = 'Residential';

  Future<void> _registerCustomer() async {
    if (_formKey.currentState!.validate()) {
      final db = await widget.database;

      // Insert customer into the customers table
      int customerId = await db.insert(
        'customers',
        {
          'full_name': _fullNameController.text,
          'address': _addressController.text,
          'email': _emailController.text,
          'phone_number': _phoneNumberController.text,
          'service_type': _serviceType,
          'status': 'active',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert account into the accounts table
      await db.insert(
        'accounts',
        {
          'username': _usernameController.text,
          'password': _passwordController.text, // Note: In a real app, hash the password before storing it
          'role': 'customer',
          'user_id': customerId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Customer'),
      ),
      body: SingleChildScrollView(
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
              ElevatedButton(
                onPressed: _registerCustomer,
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}