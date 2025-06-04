import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'edit_staff_screen.dart';
import 'register_staff_screen.dart';

class ManageStaffsScreen extends StatefulWidget {
  final Future<Database> database;

  ManageStaffsScreen({required this.database});

  @override
  _ManageStaffsScreenState createState() => _ManageStaffsScreenState();
}

class _ManageStaffsScreenState extends State<ManageStaffsScreen> {
  List<Map<String, dynamic>> _staffs = [];
  Map<String, dynamic>? _selectedStaff;

  @override
  void initState() {
    super.initState();
    _loadStaffs();
  }

  Future<void> _loadStaffs() async {
    final db = await widget.database;

    final List<Map<String, dynamic>> staffs = await db.query('staff');
    setState(() {
      _staffs = staffs;
    });
  }

  Future<void> _deleteStaff(BuildContext context) async {
    final db = await widget.database;

    await db.delete(
      'staff',
      where: 'staff_id = ?',
      whereArgs: [_selectedStaff!['staff_id']],
    );

    setState(() {
      _selectedStaff = null;
    });

    _loadStaffs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Staffs'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: _staffs.length,
                itemBuilder: (context, index) {
                  final staff = _staffs[index];
                  return Container(
                    color: _selectedStaff == staff ? Colors.grey[300] : Colors.transparent,
                    child: ListTile(
                      title: Text('${staff['staff_id']}: ${staff['full_name']}'),
                      subtitle: Text(staff['role']),
                      onTap: () {
                        setState(() {
                          if (_selectedStaff == staff) {
                            _selectedStaff = null;
                          } else {
                            _selectedStaff = staff;
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            if (_selectedStaff != null) ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditStaffScreen(staff: _selectedStaff)),
                  ).then((_) => _loadStaffs());
                },
                child: Text('Edit Staff'),
              ),
              ElevatedButton(
                onPressed: () => _deleteStaff(context),
                child: Text('Delete Staff'),
              ),
            ],
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterStaffScreen(database: widget.database)),
                ).then((_) => _loadStaffs());
              },
              child: Text('Register Staff'),
            ),
          ],
        ),
      ),
    );
  }
}