import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'edit_customer_screen.dart';
import 'register_customer_screen.dart';

class ManageCustomersScreen extends StatefulWidget {
  final Future<Database> database;

  ManageCustomersScreen({required this.database});

  @override
  _ManageCustomersScreenState createState() => _ManageCustomersScreenState();
}

class _ManageCustomersScreenState extends State<ManageCustomersScreen> {
  List<Map<String, dynamic>> _customers = [];
  Map<String, dynamic>? _selectedCustomer;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    final db = await widget.database;

    final List<Map<String, dynamic>> customers = await db.query('customers');
    setState(() {
      _customers = customers;
    });
  }

  Future<void> _deleteCustomer(BuildContext context) async {
    final db = await widget.database;

    await db.delete(
      'customers',
      where: 'customer_id = ?',
      whereArgs: [_selectedCustomer!['customer_id']],
    );

    setState(() {
      _selectedCustomer = null;
    });

    _loadCustomers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Customers'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: _customers.length,
                itemBuilder: (context, index) {
                  final customer = _customers[index];
                  return Container(
                    color: _selectedCustomer == customer ? Colors.grey[300] : Colors.transparent,
                    child: ListTile(
                      title: Text('${customer['customer_id']}: ${customer['full_name']}'),
                      subtitle: Text(customer['address']),
                      onTap: () {
                        setState(() {
                          if (_selectedCustomer == customer) {
                            _selectedCustomer = null;
                          } else {
                            _selectedCustomer = customer;
                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            if (_selectedCustomer != null) ...[
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditCustomerScreen(
                      customer: _selectedCustomer, 
                      database: widget.database,
                    )),
                  ).then((_) => _loadCustomers());
                },
                child: Text('Edit Customer'),
              ),
              ElevatedButton(
                onPressed: () => _deleteCustomer(context),
                child: Text('Delete Customer'),
              ),
            ],
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegisterCustomerScreen(database: widget.database)),
                ).then((_) => _loadCustomers());
              },
              child: Text('Register Customer'),
            ),
          ],
        ),
      ),
    );
  }
}