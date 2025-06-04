import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:camera/camera.dart';
import 'view_previous_readings_screen.dart';
import 'camera_screen.dart';
import 'login_screen.dart';
import 'package:intl/intl.dart';

class StaffScreen extends StatefulWidget {
  final Future<Database> database;
  final int staffId;

  StaffScreen({required this.database, required this.staffId});

  @override
  _StaffScreenState createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  String staffName = 'Staff';
  String greetingMessage = '';
  String assignedRegion = '';
  List<Map<String, dynamic>> _pendingRequests = [];
  int? _selectedRequestIndex;

  @override
  void initState() {
    super.initState();
    _fetchStaffName();
    _setGreetingMessage();
  }

  void _setGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greetingMessage = 'Good Morning';
    } else if (hour < 17) {
      greetingMessage = 'Good Afternoon';
    } else if (hour < 20) {
      greetingMessage = 'Good Evening';
    } else {
      greetingMessage = 'Good Night';
    }
  }

  Future<void> _fetchStaffName() async {
    final db = await widget.database;
    final result = await db.query(
      'staff',
      where: 'staff_id = ?',
      whereArgs: [widget.staffId],
    );

    if (result.isNotEmpty) {
      setState(() {
        staffName = result.first['full_name'] as String;
        assignedRegion = result.first['assigned_region'] as String;
        _loadPendingRequests();
      });
    }
  }

  Future<void> _loadPendingRequests() async {
    final db = await widget.database;
    final List<Map<String, dynamic>> requests = await db.rawQuery('''
      SELECT rr.*, wm.address, wm.meter_number
      FROM reading_requests rr
      JOIN water_meters wm ON rr.meter_id = wm.meter_id
      WHERE rr.status = ? AND wm.address LIKE ?
    ''', ['pending', '%$assignedRegion%']);

    setState(() {
      _pendingRequests = requests;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Image.asset(
                  'assets/logo.png', // Make sure to add your logo image in the assets folder
                  height: 50,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WAMRA',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2, // Adjust line spacing here
                      ),
                    ),
                    Text(
                      'Staff Panel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        height: 1.2, // Adjust line spacing here
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              '$greetingMessage, $staffName',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2), // Adjust line spacing here
            ),
            SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending Reading Requests:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    _pendingRequests.isEmpty
                        ? Center(
                            child: Text(
                              'Woohoo! No Pending Work!',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
                            ),
                          )
                        : Expanded(
                            child: ListView.builder(
                              itemCount: _pendingRequests.length,
                              itemBuilder: (context, index) {
                                final request = _pendingRequests[index];
                                final formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.parse(request['request_date']));
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedRequestIndex = index;
                                    });
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(vertical: 5.0),
                                    padding: const EdgeInsets.all(10.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: _selectedRequestIndex == index ? Colors.blue : Colors.grey,
                                      ),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: ListTile(
                                      title: Text('Meter Number: ${request['meter_number']}'),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('Request Date: $formattedDate'),
                                          Text('Address: ${request['address']}'),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                SizedBox(
                  height: 100,
                  width: 100,
                  child: ElevatedButton(
                    onPressed: _selectedRequestIndex == null
                        ? null
                        : () async {
                            final cameras = await availableCameras();
                            final firstCamera = cameras.first;
                            final selectedRequest = _pendingRequests[_selectedRequestIndex!];
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CameraScreen(
                                  camera: firstCamera,
                                  database: widget.database,
                                  staffId: widget.staffId,
                                  meterNumber: selectedRequest['meter_number'], // Pass the meter number\
                                ),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedRequestIndex == null ? Colors.grey : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.camera_alt, size: 30),
                        SizedBox(height: 5),
                        Flexible(
                          child: Text(
                            'Conduct Reading',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 100,
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ViewPreviousReadingsScreen(
                            database: widget.database,
                            staffId: widget.staffId,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.history, size: 30),
                        SizedBox(height: 5),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Previous',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Readings',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 100,
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () {
                      // Logout and navigate to Login screen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen(database: widget.database)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.logout, size: 30),
                        SizedBox(height: 5),
                        Flexible(
                          child: Text(
                            'Logout',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}