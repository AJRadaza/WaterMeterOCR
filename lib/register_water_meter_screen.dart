import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class RegisterWaterMeterScreen extends StatefulWidget {
  final Future<Database> database;

  const RegisterWaterMeterScreen({Key? key, required this.database}) : super(key: key);

  @override
  _RegisterWaterMeterScreenState createState() => _RegisterWaterMeterScreenState();
}

class _RegisterWaterMeterScreenState extends State<RegisterWaterMeterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _meterNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _initialReadingController = TextEditingController();

  Future<void> _registerWaterMeter() async {
    if (_formKey.currentState!.validate()) {
      final db = await widget.database;

      // Insert water meter into the water_meters table
      int meterId = await db.insert(
        'water_meters',
        {
          'meter_number': _meterNumberController.text,
          'address': _addressController.text,
          'customer_id': int.tryParse(_customerIdController.text) ?? 0,
          'installation_date': DateTime.now().toIso8601String(),
          'status': 'active',
        },
      );

      // Insert initial reading into the meter_readings table
      await db.insert(
        'meter_readings',
        {
          'meter_id': meterId,
          'staff_id': null, // Assuming no staff is associated with the initial reading
          'reading_value': double.tryParse(_initialReadingController.text) ?? 0.0,
          'reading_date': DateTime.now().toIso8601String(),
        },
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register Water Meter'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _meterNumberController,
                decoration: InputDecoration(labelText: 'Meter Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the meter number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the address';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _customerIdController,
                decoration: InputDecoration(labelText: 'Customer ID'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the customer ID';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _initialReadingController,
                decoration: InputDecoration(labelText: 'Initial Meter Reading'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the initial meter reading';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _registerWaterMeter,
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}