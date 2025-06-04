import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class ViewWaterMetersScreen extends StatefulWidget {
  final Future<Database> database;
  final int customerId;

  ViewWaterMetersScreen({required this.database, required this.customerId});

  @override
  _ViewWaterMetersScreenState createState() => _ViewWaterMetersScreenState();
}

class _ViewWaterMetersScreenState extends State<ViewWaterMetersScreen> {
  List<Map<String, dynamic>> _waterMeters = [];

  @override
  void initState() {
    super.initState();
    _loadWaterMeters();
  }

  Future<void> _loadWaterMeters() async {
    final db = await widget.database;

    final List<Map<String, dynamic>> waterMeters = await db.query(
      'water_meters',
      where: 'customer_id = ?',
      whereArgs: [widget.customerId],
    );

    setState(() {
      _waterMeters = waterMeters;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Water Meters'),
      ),
      body: ListView.builder(
        itemCount: _waterMeters.length,
        itemBuilder: (context, index) {
          final waterMeter = _waterMeters[index];
          return ListTile(
            title: Text('Meter Number: ${waterMeter['meter_number']}'),
            subtitle: Text('Address: ${waterMeter['address']}'),
          );
        },
      ),
    );
  }
}