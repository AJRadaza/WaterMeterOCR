import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'view_bills_screen.dart';
import 'login_screen.dart';
import 'my_profile_screen.dart';
import 'view_water_meters_screen.dart';

class CustomerScreen extends StatefulWidget {
  final Future<Database> database;
  final int loggedInCustomerId;

  CustomerScreen({required this.database, required this.loggedInCustomerId});

  @override
  _CustomerScreenState createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  String customerName = '';
  String greetingMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchCustomerName();
    _setGreetingMessage();
  }

  Future<void> _fetchCustomerName() async {
    final db = await widget.database;
    final result = await db.query(
      'customers',
      where: 'customer_id = ?',
      whereArgs: [widget.loggedInCustomerId],
    );

    if (result.isNotEmpty) {
      setState(() {
        customerName = result.first['full_name'] as String;
      });
    }
  }

  void _setGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greetingMessage = 'Good Morning';
    } else if (hour < 17) {
      greetingMessage = 'Good Afternoon';
    } else if (hour < 20) {
      greetingMessage = 'Good Evening';
    } else {
      greetingMessage = 'Good Night';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Image.asset(
                  'assets/logo.png', // Make sure to add your logo image in the assets folder
                  height: 50,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WAMRA',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2, // Adjust line spacing here
                      ),
                    ),
                    Text(
                      'Customer Panel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1.2, // Adjust line spacing here
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              '$greetingMessage,',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2), // Adjust line spacing here
            ),
            Text(
              '$customerName ',
              style: TextStyle(fontSize: 18, height: 1.2), // Adjust line spacing here
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(
                  height: 100,
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyProfileScreen(
                            database: widget.database,
                            customerId: widget.loggedInCustomerId,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.person, size: 30),
                        SizedBox(height: 5),
                        Text(
                          'My Profile',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 100,
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewBillsScreen(
                            database: widget.database,
                            loggedInCustomerId: widget.loggedInCustomerId,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.receipt, size: 30),
                        SizedBox(height: 5),
                        Text(
                          'My Bills',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Center(
              child: SizedBox(
                height: 100,
                width: 150,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewWaterMetersScreen(
                          database: widget.database,
                          customerId: widget.loggedInCustomerId,
                        ),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.water, size: 30),
                      SizedBox(height: 5),
                      Text(
                        'My Water Meters',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: SizedBox(
                height: 100,
                width: 150,
                child: ElevatedButton(
                  onPressed: () {
                    // Logout and navigate to Login screen
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen(database: widget.database)),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.logout, size: 30),
                      SizedBox(height: 5),
                      Text(
                        'Logout',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: SizedBox(
                height: 100,
                child: 
                  Text(
                    'Customer ID: ${widget.loggedInCustomerId}',
                    style: TextStyle(fontSize: 18, height: 1.2, color: Colors.grey), // Adjust line spacing here
                    
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}