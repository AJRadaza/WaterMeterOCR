import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'manage_customers_screen.dart';
import 'manage_staffs_screen.dart';
import 'manage_readings_screen.dart';
import 'manage_bills_screen.dart';
import 'login_screen.dart';
import 'manage_water_meters_screen.dart';

class AdminScreen extends StatefulWidget {
  final Future<Database> database;

  AdminScreen({required this.database});

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String adminName = 'Admin'; // You can fetch the admin name if needed
  String greetingMessage = '';

  @override
  void initState() {
    super.initState();
    _setGreetingMessage();
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
      body: SingleChildScrollView(
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
                Text(
                  'WAMRA',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              '$greetingMessage,',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              '$adminName ',
              style: TextStyle(fontSize: 18),
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
                        MaterialPageRoute(builder: (context) => ManageCustomersScreen(database: widget.database)),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.people, size: 30),
                        SizedBox(height: 5),
                        Text(
                          'Manage Customers',
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
                        MaterialPageRoute(builder: (context) => ManageWaterMetersScreen(database: widget.database)),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.water, size: 30),
                        SizedBox(height: 5),
                        Text(
                          'Manage Water Meters',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
                        MaterialPageRoute(builder: (context) => ManageReadingsScreen(database: widget.database)),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.receipt, size: 30),
                        SizedBox(height: 5),
                        Text(
                          'Manage Readings',
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
                        MaterialPageRoute(builder: (context) => ManageBillsScreen(database: widget.database)),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.attach_money, size: 30),
                        SizedBox(height: 5),
                        Text(
                          'Manage Bills',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: SizedBox(
                height: 100,
                width: 150,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ManageStaffsScreen(database: widget.database)),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.person, size: 30),
                      SizedBox(height: 5),
                      Text(
                        'Manage Staffs',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
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
          ],
        ),
      ),
    );
  }
}