import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class EditStaffScreen extends StatefulWidget {
  final Map<String, dynamic>? staff;

  EditStaffScreen({required this.staff});

  @override
  _EditStaffScreenState createState() => _EditStaffScreenState();
}

class _EditStaffScreenState extends State<EditStaffScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _assignedRegionController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _showLoginDetails = false;

  @override
  void initState() {
    super.initState();
    _loadStaffDetails();
  }

  void _loadStaffDetails() {
    if (widget.staff != null) {
      _fullNameController.text = widget.staff!['full_name'];
      _roleController.text = widget.staff!['role'];
      _assignedRegionController.text = widget.staff!['assigned_region'];
      _loadLoginDetails();
    }
  }

  Future<void> _loadLoginDetails() async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'data.db'),
    );

    final List<Map<String, dynamic>> accounts = await db.query(
      'accounts',
      where: 'user_id = ? AND role = ?',
      whereArgs: [widget.staff!['staff_id'], 'staff'],
    );

    if (accounts.isNotEmpty) {
      _usernameController.text = accounts.first['username'];
      _passwordController.text = accounts.first['password'];
    }
  }

  Future<void> _editStaff(BuildContext context) async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'data.db'),
    );

    await db.update(
      'staff',
      {
        'full_name': _fullNameController.text,
        'role': _roleController.text,
        'assigned_region': _assignedRegionController.text,
      },
      where: 'staff_id = ?',
      whereArgs: [widget.staff!['staff_id']],
    );

    if (_showLoginDetails) {
      await db.update(
        'accounts',
        {
          'username': _usernameController.text,
          'password': _passwordController.text, // Note: In a real app, hash the password before storing it
        },
        where: 'user_id = ? AND role = ?',
        whereArgs: [widget.staff!['staff_id'], 'staff'],
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Staff'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Text(
                'Staff details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(labelText: 'Full Name'),
            ),
            TextField(
              controller: _roleController,
              decoration: InputDecoration(labelText: 'Role'),
            ),
            TextField(
              controller: _assignedRegionController,
              decoration: InputDecoration(labelText: 'Assigned Region'),
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
                onPressed: () => _editStaff(context),
                child: Text('Save changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}