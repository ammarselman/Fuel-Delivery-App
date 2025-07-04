import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class GenerateReportsScreen extends StatefulWidget {
  const GenerateReportsScreen({super.key});

  @override
  _GenerateReportsScreenState createState() => _GenerateReportsScreenState();
}

class _GenerateReportsScreenState extends State<GenerateReportsScreen> {
  int totalOrders = 0;
  int acceptedOrders = 0;
  int rejectedOrders = 0;
  double totalQuantity = 0;
  int totalUsers = 0;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final ordersSnapshot =
        await FirebaseFirestore.instance.collection('orders').get();
    final usersSnapshot =
        await FirebaseFirestore.instance.collection('users').get();

    int accepted = 0;
    int rejected = 0;
    double quantity = 0;

    for (var doc in ordersSnapshot.docs) {
      final data = doc.data();
      final status = data['status'];
      if (status == 'accepted') accepted++;
      if (status == 'rejected') rejected++;
      quantity += (data['quantity'] as num).toDouble();
    }

    setState(() {
      totalOrders = ordersSnapshot.size;
      acceptedOrders = accepted;
      rejectedOrders = rejected;
      totalQuantity = quantity;
      totalUsers = usersSnapshot.size;
    });
  }

  Widget _buildTile(String label, dynamic value) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(value.toString(),
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reports')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildTile('Total Orders', totalOrders),
            _buildTile('Accepted Orders', acceptedOrders),
            _buildTile('Rejected Orders', rejectedOrders),
            _buildTile('Total Quantity Requested', totalQuantity),
            _buildTile('Total Users', totalUsers),
          ],
        ),
      ),
    );
  }
}
