import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DriverAssignedOrdersScreen extends StatefulWidget {
  const DriverAssignedOrdersScreen({super.key});

  @override
  State<DriverAssignedOrdersScreen> createState() =>
      _DriverAssignedOrdersScreenState();
}

class _DriverAssignedOrdersScreenState
    extends State<DriverAssignedOrdersScreen> {
  final _auth = FirebaseAuth.instance;
  String? _driverId;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      _driverId = user.uid;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_driverId == null) {
      return const Scaffold(
        body: Center(child: Text('Driver not logged in')),
      );
    }

    final ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .where('assignedTo', isEqualTo: _driverId)
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('My Assigned Orders'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // الخلفية
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/truck.jpg'), // ضع صورة مناسبة هنا
                fit: BoxFit.cover,
              ),
            ),
          ),
          // الضباب
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          // الطلبات
          SafeArea(
            child: StreamBuilder<QuerySnapshot>(
              stream: ordersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No assigned orders yet.',
                        style: TextStyle(color: Colors.white)),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final quantity = data['quantity'];
                    final fuelType = data['fuelType'];
                    final status = data['status'];
                    final time = (data['createdAt'] as Timestamp?)?.toDate();

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.local_gas_station,
                                      color: Colors.lightBlueAccent),
                                  const SizedBox(width: 8),
                                  Text('Fuel: $fuelType - $quantity L',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('Status: $status',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14)),
                              if (time != null)
                                Text('Created: ${time.toLocal()}',
                                    style: const TextStyle(
                                        color: Colors.white60, fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
