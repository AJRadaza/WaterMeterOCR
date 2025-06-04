import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class EditWaterMeterScreen extends StatefulWidget {
  final Map<String, dynamic>? waterMeter;

  EditWaterMeterScreen({required this.waterMeter});

  @override
  _EditWaterMeterScreenState createState() => _EditWaterMeterScreenState();
}

class _EditWaterMeterScreenState extends State<EditWaterMeterScreen> {
  final TextEditingController _meterNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _customerIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _meterNumberController.text = widget.waterMeter!['meter_number'];
    _addressController.text = widget.waterMeter!['address'];
    _customerIdController.text = widget.waterMeter!['customer_id'].toString();
  }

  Future<void> _editWaterMeter(BuildContext context) async {
    final db = await openDatabase(
      join(await getDatabasesPath(), 'data.db'),
    );

    await db.update(
      'water_meters',
      {
        'meter_number': _meterNumberController.text,
        'address': _addressController.text,
        'customer_id': int.tryParse(_customerIdController.text) ?? 0,
        'installation_date': widget.waterMeter!['installation_date'],
        'status': widget.waterMeter!['status'],
      },
      where: 'meter_id = ?',
      whereArgs: [widget.waterMeter!['meter_id']],
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Water Meter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _meterNumberController,
              decoration: InputDecoration(labelText: 'Meter Number'),
            ),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            TextField(
              controller: _customerIdController,
              decoration: InputDecoration(labelText: 'Customer ID'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _editWaterMeter(context),
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}