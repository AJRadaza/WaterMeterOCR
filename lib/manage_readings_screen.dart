import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'edit_reading_screen.dart';
import 'create_reading_request_screen.dart';

class ManageReadingsScreen extends StatefulWidget {
  final Future<Database> database;

  ManageReadingsScreen({required this.database});

  @override
  _ManageReadingsScreenState createState() => _ManageReadingsScreenState();
}

class _ManageReadingsScreenState extends State<ManageReadingsScreen> {
  List<Map<String, dynamic>> _readings = [];
  Map<String, dynamic>? _selectedReading;

  @override
  void initState() {
    super.initState();
    _loadReadings();
  }

  Future<void> _loadReadings() async {
    final db = await widget.database;

    final List<Map<String, dynamic>> readings = await db.query('meter_readings');
    setState(() {
      _readings = readings;
    });
  }

  Future<void> _deleteReading(BuildContext context) async {
    final db = await widget.database;

    await db.delete(
      'meter_readings',
      where: 'reading_id = ?',
      whereArgs: [_selectedReading!['reading_id']],
    );

    setState(() {
      _selectedReading = null;
    });

    _loadReadings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Readings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: _readings.length,
                itemBuilder: (context, index) {
                  final reading = _readings[index];
                  return Container(
                    color: _selectedReading == reading ? Colors.grey[300] : Colors.transparent,
                    child: ListTile(
                      title: Text('Reading ID: ${reading['reading_id']}'),
                      subtitle: Text('Meter ID: ${reading['meter_id']}'),
                      onTap: () {
                        setState(() {
                          if (_selectedReading == reading) {
                            _selectedReading = null;
                          } else {
                            _selectedReading = reading;
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            if (_selectedReading != null) ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditReadingScreen(reading: _selectedReading)),
                  ).then((_) => _loadReadings());
                },
                child: Text('Edit Reading'),
              ),
              ElevatedButton(
                onPressed: () => _deleteReading(context),
                child: Text('Delete Reading'),
              ),
            ],
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateReadingRequestScreen(database: widget.database)),
                );
              },
              child: Text('Create Reading Request'),
            ),
          ],
        ),
      ),
    );
  }
}