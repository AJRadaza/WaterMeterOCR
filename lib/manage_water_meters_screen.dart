import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'edit_water_meter_screen.dart';
import 'register_water_meter_screen.dart';

class ManageWaterMetersScreen extends StatefulWidget {
  final Future<Database> database;

  ManageWaterMetersScreen({required this.database});

  @override
  _ManageWaterMetersScreenState createState() => _ManageWaterMetersScreenState();
}

class _ManageWaterMetersScreenState extends State<ManageWaterMetersScreen> {
  List<Map<String, dynamic>> _waterMeters = [];
  Map<String, dynamic>? _selectedWaterMeter;

  @override
  void initState() {
    super.initState();
    _loadWaterMeters();
  }

  Future<void> _loadWaterMeters() async {
    final db = await widget.database;

    final List<Map<String, dynamic>> waterMeters = await db.query('water_meters');
    setState(() {
      _waterMeters = waterMeters;
    });
  }

  Future<void> _deleteWaterMeter(BuildContext context) async {
    final db = await widget.database;

    await db.delete(
      'water_meters',
      where: 'meter_id = ?',
      whereArgs: [_selectedWaterMeter!['meter_id']],
    );

    setState(() {
      _selectedWaterMeter = null;
    });

    _loadWaterMeters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Water Meters'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: _waterMeters.length,
                itemBuilder: (context, index) {
                  final waterMeter = _waterMeters[index];
                  return Container(
                    color: _selectedWaterMeter == waterMeter ? Colors.grey[300] : Colors.transparent,
                    child: ListTile(
                      title: Text('${waterMeter['meter_id']}: ${waterMeter['meter_number']}'),
                      subtitle: Text(waterMeter['address']),
                      onTap: () {
                        setState(() {
                          if (_selectedWaterMeter == waterMeter) {
                            _selectedWaterMeter = null;
                          } else {
                            _selectedWaterMeter = waterMeter;
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            if (_selectedWaterMeter != null) ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditWaterMeterScreen(waterMeter: _selectedWaterMeter)),
                  ).then((_) => _loadWaterMeters());
                },
                child: Text('Edit Water Meter'),
              ),
              ElevatedButton(
                onPressed: () => _deleteWaterMeter(context),
                child: Text('Delete Water Meter'),
              ),
            ],
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterWaterMeterScreen(database: widget.database)),
                ).then((_) => _loadWaterMeters());
              },
              child: Text('Register Water Meter'),
            ),
          ],
        ),
      ),
    );
  }
}