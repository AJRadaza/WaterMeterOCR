import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class GenerateBillsScreen extends StatefulWidget {
  final Future<Database> database;

  GenerateBillsScreen({required this.database});

  @override
  _GenerateBillsScreenState createState() => _GenerateBillsScreenState();
}

class _GenerateBillsScreenState extends State<GenerateBillsScreen> {
  final TextEditingController _costController = TextEditingController();

  Future<void> _generateBills() async {
    final db = await widget.database;
    final double costPerM3 = double.tryParse(_costController.text) ?? 0;

    // Example bill generation logic
    final customers = await db.query('customers');
    for (var customer in customers) {
      final customerId = customer['customer_id'];
      final meters = await db.query(
        'water_meters',
        where: 'customer_id = ?',
        whereArgs: [customerId],
      );

      for (var meter in meters) {
        final meterId = meter['meter_id'];
        final latestReadings = await db.query(
          'meter_readings',
          where: 'meter_id = ?',
          whereArgs: [meterId],
          orderBy: 'reading_date DESC',
          limit: 2,
        );

        if (latestReadings.length == 2) {
          final latestReading = latestReadings[0];
          final previousReading = latestReadings[1];
          final readingId = latestReading['reading_id'];
          final latestReadingValue = latestReading['reading_value'];
          final previousReadingValue = previousReading['reading_value'];
          final usage = (latestReadingValue as num) - (previousReadingValue as num);
          final billAmount = usage * costPerM3; // Use cost per m³

          await db.insert('billing', {
            'customer_id': customerId,
            'reading_id': readingId,
            'bill_amount': billAmount,
            'bill_date': DateTime.now().toIso8601String(),
            'due_date': DateTime.now().add(Duration(days: 30)).toIso8601String(),
          });
        }
      }
    }

    // Show a message after generation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bills generated successfully')),
    );

    // Navigate back to the previous screen with a result
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate Bills'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _costController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cost per m³',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _generateBills,
              child: Text('Generate Bills'),
            ),
          ],
        ),
      ),
    );
  }
}