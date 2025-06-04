import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:sqflite/sqflite.dart';
import 'staff_screen.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;
  final Future<Database> database;
  final int staffId;
  final String meterNumber;
  final Function onReadingSaved; // Add callback function

  DisplayPictureScreen({
    required this.imagePath,
    required this.database,
    required this.staffId,
    required this.meterNumber,
    required this.onReadingSaved, // Add callback function
  });

  @override
  _DisplayPictureScreenState createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _meterNumberController = TextEditingController(); // Changed from _customerIdController

  @override
  void initState() {
    super.initState();
    _meterNumberController.text = widget.meterNumber; // Set the meter number
    _extractText(); // Extract text as soon as the screen gets up
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    _meterNumberController.dispose(); // Changed from _customerIdController
    super.dispose();
  }

  Future<void> _extractText() async {
    final inputImage = InputImage.fromFilePath(widget.imagePath);
    final textDetector = GoogleMlKit.vision.textRecognizer();
    final RecognizedText recognisedText = await textDetector.processImage(inputImage);
    await textDetector.close();

    String extractedText = recognisedText.text;

    // Process the extracted text
    String processedText = extractedText
        .replaceAll(RegExp(r'\D+'), '') // Remove non-digit characters
        .replaceAll(' ', '')           // Remove spaces
        .replaceFirst(RegExp(r'^0+'), ''); // Remove leading zeroes

    // Add a decimal point after the third character from the right
    if (processedText.length > 3) {
      processedText = '${processedText.substring(0, processedText.length - 3)}.${processedText.substring(processedText.length - 3)}';
    }

    setState(() {
      _textEditingController.text = processedText;
    });
  }

  Future<void> saveReading(double readingValue) async {
    final db = await widget.database;

    // Get the meter_id using the meterNumber
    final List<Map<String, dynamic>> meterResult = await db.query(
      'water_meters',
      where: 'meter_number = ?',
      whereArgs: [widget.meterNumber],
    );

    if (meterResult.isNotEmpty) {
      final int meterId = meterResult.first['meter_id'];

      // Insert the reading into the meter_readings table
      await db.insert('meter_readings', {
        'meter_id': meterId,
        'staff_id': widget.staffId,
        'reading_value': readingValue,
        'reading_date': DateTime.now().toIso8601String(),
      });

      // Update the status of the pending requests associated with the meter_id to "completed"
      await db.update(
        'reading_requests',
        {'status': 'completed'},
        where: 'meter_id = ? AND status = ?',
        whereArgs: [meterId, 'pending'],
      );

      // Call the callback function to reload pending requests
      widget.onReadingSaved();

      // Show a snackbar message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reading saved successfully!')),
      );

      // Navigate back to the StaffScreen and reload pending requests
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => StaffScreen(
            database: widget.database,
            staffId: widget.staffId,
          ),
        ),
        (Route<dynamic> route) => false,
      );
    } else {
      // Handle the case where the meterNumber is not found
      print('Meter number not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display Picture')),
      body: Column(
        children: <Widget>[
          Image.file(File(widget.imagePath)),
          TextField(
            controller: _textEditingController,
            decoration: InputDecoration(labelText: 'Extracted Reading'),
          ),
          TextField(
            controller: _meterNumberController,
            decoration: InputDecoration(labelText: 'Meter Number'),
          ),
          ElevatedButton(
            onPressed: () {
              final readingValue = double.tryParse(_textEditingController.text);
              if (readingValue != null) {
                saveReading(readingValue);
              } else {
                // Handle invalid reading value
                print('Invalid reading value');
              }
            },
            child: Text('Save Reading'),
          ),
        ],
      ),
    );
  }
}