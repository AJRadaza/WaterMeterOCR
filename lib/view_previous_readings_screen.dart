import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class ViewPreviousReadingsScreen extends StatefulWidget {
  final Future<Database> database;
  final int staffId;

  ViewPreviousReadingsScreen({required this.database, required this.staffId});

  @override
  _ViewPreviousReadingsScreenState createState() => _ViewPreviousReadingsScreenState();
}

class _ViewPreviousReadingsScreenState extends State<ViewPreviousReadingsScreen> {
  List<Map<String, dynamic>> _readings = [];

  @override
  void initState() {
    super.initState();
    _loadReadings();
  }

  Future<void> _loadReadings() async {
    final db = await widget.database;

    final List<Map<String, dynamic>> readings = await db.query(
      'meter_readings',
      where: 'staff_id = ?',
      whereArgs: [widget.staffId],
    );

    setState(() {
      _readings = readings;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Previous Readings'),
      ),
      body: ListView.builder(
        itemCount: _readings.length,
        itemBuilder: (context, index) {
          final reading = _readings[index];
          return ListTile(
            title: Text('Reading: ${reading['reading_value']}'),
            subtitle: Text('Date: ${reading['reading_date']}'),
          );
        },
      ),
    );
  }
}