import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'generate_bills_screen.dart';

class ManageBillsScreen extends StatefulWidget {
  final Future<Database> database;

  ManageBillsScreen({required this.database});

  @override
  _ManageBillsScreenState createState() => _ManageBillsScreenState();
}

class _ManageBillsScreenState extends State<ManageBillsScreen> {
  List<Map<String, dynamic>> _bills = [];
  int? _selectedBillIndex;

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    final db = await widget.database;
    final List<Map<String, dynamic>> bills = await db.rawQuery('''
      SELECT b.*, c.full_name, c.address, mr.reading_value, mr.reading_date
      FROM billing b
      JOIN customers c ON b.customer_id = c.customer_id
      JOIN meter_readings mr ON b.reading_id = mr.reading_id
    ''');
    setState(() {
      _bills = bills;
    });
  }

  Future<void> _deleteBill(int billId) async {
    final db = await widget.database;
    await db.delete(
      'billing',
      where: 'bill_id = ?',
      whereArgs: [billId],
    );
    _loadBills();
  }

  Future<void> _editBill(int billId, double newAmount) async {
    final db = await widget.database;
    await db.update(
      'billing',
      {'bill_amount': newAmount},
      where: 'bill_id = ?',
      whereArgs: [billId],
    );
    _loadBills();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Bills'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _bills.length,
              itemBuilder: (context, index) {
                final bill = _bills[index];
                final dueDate = DateFormat('yyyy-MM-dd').parse(bill['due_date']);
                final formattedDueDate = DateFormat('MMMM dd, yyyy').format(dueDate);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedBillIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedBillIndex == index ? Colors.blue : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    child: ListTile(
                      title: Text('Bill Amount: ${bill['bill_amount']}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Customer Name: ${bill['full_name']}'),
                          Text('Due Date: $formattedDueDate'),
                          Text('Bill Status: ${bill['status']}'),
                        ],
                      ),
                      trailing: _selectedBillIndex == index
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    // Show edit dialog
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        final TextEditingController _controller = TextEditingController(
                                          text: bill['bill_amount'].toString(),
                                        );
                                        return AlertDialog(
                                          title: Text('Edit Bill'),
                                          content: TextField(
                                            controller: _controller,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(labelText: 'Bill Amount'),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                final newAmount = double.tryParse(_controller.text);
                                                if (newAmount != null) {
                                                  _editBill(bill['bill_id'], newAmount);
                                                  Navigator.of(context).pop();
                                                }
                                              },
                                              child: Text('Save'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteBill(bill['bill_id']);
                                  },
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GenerateBillsScreen(database: widget.database),
                  ),
                );
                if (result == true) {
                  _loadBills();
                }
              },
              child: Text('Generate Bills'),
            ),
          ),
        ],
      ),
    );
  }
}