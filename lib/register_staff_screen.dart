import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class RegisterStaffScreen extends StatefulWidget {
  final Future<Database> database;

  const RegisterStaffScreen({Key? key, required this.database}) : super(key: key);

  @override
  _RegisterStaffScreenState createState() => _RegisterStaffScreenState();
}

class _RegisterStaffScreenState extends State<RegisterStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _assignedRegionController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _registerStaff(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      final db = await widget.database;

      // Insert staff into the staff table
      int staffId = await db.insert(
        'staff',
        {
          'full_name': _fullNameController.text,
          'role': _roleController.text,
          'assigned_region': _assignedRegionController.text,
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
          'role': 'staff',
          'user_id': staffId,
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
        title: Text('Register Staff'),
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
                controller: _roleController,
                decoration: InputDecoration(labelText: 'Role'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the role';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _assignedRegionController,
                decoration: InputDecoration(labelText: 'Assigned Region'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the assigned region';
                  }
                  return null;
                },
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
                onPressed: () => _registerStaff(context),
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}