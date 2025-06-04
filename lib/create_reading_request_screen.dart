import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class CreateReadingRequestScreen extends StatefulWidget {
  final Future<Database> database;

  CreateReadingRequestScreen({required this.database});

  @override
  _CreateReadingRequestScreenState createState() => _CreateReadingRequestScreenState();
}

class _CreateReadingRequestScreenState extends State<CreateReadingRequestScreen> {
  String _requestType = 'Area';
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _meterNumberController = TextEditingController();

  Future<void> _createReadingRequest() async {
    final db = await widget.database;

    if (_requestType == 'Area') {
      final List<Map<String, dynamic>> meters = await db.query(
        'water_meters',
        where: 'address LIKE ?',
        whereArgs: ['%${_areaController.text}%'],
      );

      for (var meter in meters) {
        await db.insert(
          'reading_requests',
          {
            'meter_id': meter['meter_id'],
            'status': 'pending',
            'request_date': DateTime.now().toIso8601String(),
          },
        );
      }
    } else if (_requestType == 'Individual meter') {
      final List<Map<String, dynamic>> meters = await db.query(
        'water_meters',
        where: 'meter_number = ?',
        whereArgs: [_meterNumberController.text],
      );

      if (meters.isNotEmpty) {
        await db.insert(
          'reading_requests',
          {
            'meter_id': meters.first['meter_id'],
            'status': 'pending',
            'request_date': DateTime.now().toIso8601String(),
          },
        );
      }
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Reading Request'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            ListTile(
              title: const Text('Area'),
              leading: Radio<String>(
                value: 'Area',
                groupValue: _requestType,
                onChanged: (String? value) {
                  setState(() {
                    _requestType = value!;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Individual meter'),
              leading: Radio<String>(
                value: 'Individual meter',
                groupValue: _requestType,
                onChanged: (String? value) {
                  setState(() {
                    _requestType = value!;
                  });
                },
              ),
            ),
            if (_requestType == 'Area')
              TextField(
                controller: _areaController,
                decoration: InputDecoration(labelText: 'Area'),
              ),
            if (_requestType == 'Individual meter')
              TextField(
                controller: _meterNumberController,
                decoration: InputDecoration(labelText: 'Meter Number'),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createReadingRequest,
              child: Text('Create Request'),
            ),
          ],
        ),
      ),
    );
  }
}