import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class EditReadingScreen extends StatefulWidget {
  final Map<String, dynamic>? reading;

  EditReadingScreen({required this.reading});

  @override
  _EditReadingScreenState createState() => _EditReadingScreenState();
}

class _EditReadingScreenState extends State<EditReadingScreen> {
  final TextEditingController _readingValueController = TextEditingController();
  final TextEditingController _readingDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadReadingDetails();
  }

  void _loadReadingDetails() {
    if (widget.reading != null) {
      _readingValueController.text = widget.reading!['reading_value'].toString();
      _readingDateController.text = widget.reading!['reading_date'];
    }
  }

  Future<void> _editReading(BuildContext context) async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'data.db'),
    );

    await db.update(
      'meter_readings',
      {
        'reading_value': double.parse(_readingValueController.text),
        'reading_date': _readingDateController.text,
      },
      where: 'reading_id = ?',
      whereArgs: [widget.reading!['reading_id']],
    );

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _readingValueController.dispose();
    _readingDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Reading'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Text(
                'Reading details',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            TextField(
              controller: _readingValueController,
              decoration: InputDecoration(labelText: 'Reading Value'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _readingDateController,
              decoration: InputDecoration(labelText: 'Reading Date'),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () => _editReading(context),
                child: Text('Save changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}