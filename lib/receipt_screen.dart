import 'package:flutter/material.dart';

class ReceiptScreen extends StatelessWidget {
  final Map<String, dynamic> bill;

  ReceiptScreen({required this.bill});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receipt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Receipt for Bill ID: ${bill['bill_id']}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('Amount Paid: ${bill['bill_amount']}'),
            SizedBox(height: 8),
            Text('Due Date: ${bill['due_date']}'),
            SizedBox(height: 8),
            Text('Status: ${bill['status']}'),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
