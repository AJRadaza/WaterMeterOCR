import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = openDatabase(
    join(await getDatabasesPath(), 'data.db'),
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS customers (
            customer_id INTEGER PRIMARY KEY AUTOINCREMENT,
            full_name TEXT NOT NULL,
            address TEXT NOT NULL,
            email TEXT UNIQUE,
            phone_number TEXT UNIQUE,
            service_type TEXT CHECK(service_type IN ('Residential', 'Commercial')),
            status TEXT DEFAULT 'active'
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS staff (
            staff_id INTEGER PRIMARY KEY AUTOINCREMENT,
            full_name TEXT NOT NULL,
            role TEXT,
            assigned_region TEXT,
            status TEXT DEFAULT 'active'
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS water_meters (
            meter_id INTEGER PRIMARY KEY AUTOINCREMENT,
            customer_id INTEGER,
            meter_number TEXT UNIQUE,
            installation_date TEXT,
            address TEXT NOT NULL,
            status TEXT DEFAULT 'active',
            FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS meter_readings (
            reading_id INTEGER PRIMARY KEY AUTOINCREMENT,
            meter_id INTEGER,
            staff_id INTEGER,
            reading_value REAL,
            reading_date TEXT,
            FOREIGN KEY (meter_id) REFERENCES water_meters (meter_id),
            FOREIGN KEY (staff_id) REFERENCES staff (staff_id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS reading_requests (
            request_id INTEGER PRIMARY KEY AUTOINCREMENT,
            meter_id INTEGER,
            status TEXT DEFAULT 'pending',
            request_date TEXT,
            FOREIGN KEY (meter_id) REFERENCES water_meters (meter_id)
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS accounts (
            account_id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT,
            role TEXT,
            user_id INTEGER
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS billing (
            bill_id INTEGER PRIMARY KEY AUTOINCREMENT,
            customer_id INTEGER,
            reading_id INTEGER,
            bill_amount REAL,
            bill_date DATETIME,
            status TEXT DEFAULT 'unpaid',
            due_date DATE,
            FOREIGN KEY (customer_id) REFERENCES customers (customer_id),
            FOREIGN KEY (reading_id) REFERENCES meter_readings (reading_id)
        )
      ''');

      // Insert default admin account
      await db.insert('accounts', {
        'username': 'admin',
        'password': 'admin', // Consider hashing passwords in production
        'role': 'admin',
        'user_id': null,
      });
    },
    version: 1,
  );

  runApp(MyApp(database: database));
}

class MyApp extends StatelessWidget {
  final Future<Database> database;

  MyApp({required this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove the debug banner
      title: 'WAMRA',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(database: database),
    );
  }
}