import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'receipt_screen.dart';

class ViewBillsScreen extends StatefulWidget {
  final Future<Database> database;
  final int loggedInCustomerId;  // Add logged-in customer ID

  ViewBillsScreen({required this.database, required this.loggedInCustomerId});

  @override
  _ViewBillsScreenState createState() => _ViewBillsScreenState();
}

class _ViewBillsScreenState extends State<ViewBillsScreen> {
  List<Map<String, dynamic>> _bills = [];

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    try {
      final db = await widget.database;

      // Query bills for the logged-in customer
      final List<Map<String, dynamic>> bills = await db.query(
        'billing',
        where: 'customer_id = ?',
        whereArgs: [widget.loggedInCustomerId],
      );

      setState(() {
        _bills = bills;
      });
    } catch (e) {
      print('Error loading bills: $e');
    }
  }

  Future<void> _payBillAndViewReceipt(BuildContext context, Map<String, dynamic> bill) async {
    try {
      final db = await widget.database;

      // Update the bill status to 'paid'.
      await db.update(
        'billing',
        {'status': 'paid'},
        where: 'bill_id = ?',
        whereArgs: [bill['bill_id']],
      );

      // Reload bills to reflect the changes.
      _loadBills();

      // Navigate to the ReceiptScreen with the updated bill.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptScreen(bill: {
            ...bill,
            'status': 'paid',
          }),
        ),
      );
    } catch (e) {
      print('Error updating bill status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Bills'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _bills.isEmpty
                  ? Center(child: Text('No bills found'))
                  : ListView.builder(
                      itemCount: _bills.length,
                      itemBuilder: (context, index) {
                        final bill = _bills[index];
                        return ListTile(
                          title: Text('Bill ID: ${bill['bill_id']}'),
                          subtitle: Text('Amount: ${bill['bill_amount']} - Due Date: ${bill['due_date']}'),
                          trailing: bill['status'] == 'paid'
                              ? Icon(Icons.check_circle, color: Colors.green)
                              : ElevatedButton(
                                  onPressed: () => _payBillAndViewReceipt(context, bill),
                                  child: Text('Pay'),
                                ),
                          onTap: () => _payBillAndViewReceipt(context, bill),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
