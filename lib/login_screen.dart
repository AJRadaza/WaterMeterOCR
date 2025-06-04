import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'customer_screen.dart';
import 'staff_screen.dart';
import 'admin_screen.dart';

class LoginScreen extends StatefulWidget {
  final Future<Database> database;

  const LoginScreen({Key? key, required this.database}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = '';

  Future<void> _login() async {
    final db = await widget.database;
    final username = _usernameController.text;
    final password = _passwordController.text;

    // Query the accounts table
    final List<Map<String, dynamic>> result = await db.query(
      'accounts',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (result.isNotEmpty) {
      final role = result.first['role'];
      int customerId = 0;
      int staffId = 0;

      // Get customer_id for 'customer' role from accounts table
      if (role == 'customer') {
        final userId = result.first['user_id'];  // Get the user_id (which should be the customer_id)
        final customerQuery = await db.query(
          'customers',
          where: 'customer_id = ?',
          whereArgs: [userId],
        );
        if (customerQuery.isNotEmpty) {
          customerId = customerQuery.first['customer_id'] as int;  // Get customer_id from customers table
        }
      } else if (role == 'staff') {
        staffId = result.first['user_id'];  // Get the user_id (which should be the staff_id)
      }

      setState(() {
        _message = 'Login successful!';
      });

      // Navigate based on user role
      if (role == 'customer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerScreen(
              database: widget.database,
              loggedInCustomerId: customerId,  // Pass customer_id to CustomerScreen
            ),
          ),
        );
      } else if (role == 'staff') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => StaffScreen(
              database: widget.database,
              staffId: staffId,  // Pass staff_id to StaffScreen
            ),
          ),
        );
      } else if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminScreen(
              database: widget.database,
            ),
          ),
        );
      }
    } else {
      setState(() {
        _message = 'Invalid username or password';
      });
    }
  }
    
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Remove the title from the AppBar
        title: null,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Add a logo and title
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/logo.png', // Make sure to add your logo image in the assets folder
                    height: 200,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'WAMRA',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 0),
                  Text(
                    'Water Meter Reading App',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                ],
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
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
            SizedBox(height: 20),
            Text(
              _message,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
