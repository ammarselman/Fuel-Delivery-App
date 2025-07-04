import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  Icon _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return const Icon(Icons.check_circle, color: Colors.green, size: 32);
      case 'rejected':
        return const Icon(Icons.cancel, color: Colors.red, size: 32);
      case 'assigned':
      case 'on_delivery':
        return const Icon(Icons.local_shipping, color: Colors.amber, size: 32);
      case 'delivered':
        return const Icon(Icons.done_all, color: Colors.blue, size: 32);
      case 'pending':
      default:
        return const Icon(Icons.access_time, color: Colors.orange, size: 32);
    }
  }

  Future<void> _markAsDelivered(String orderId, BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({'status': 'delivered'});

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order marked as delivered.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    final ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/assets/bg.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: ordersStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Error loading orders'));
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Center(
                  child: Text('🗃️ No orders found',
                      style: TextStyle(color: Colors.white)),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
                itemCount: docs.length,
                itemBuilder: (context, i) {
                  final data = docs[i].data() as Map<String, dynamic>;
                  final createdAt = (data['createdAt'] as Timestamp).toDate();
                  final status = (data['status'] ?? 'pending').toLowerCase();
                  final id = docs[i].id;

                  final showMarkDelivered =
                      status == 'assigned' || status == 'on_delivery';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: _getStatusIcon(status),
                          title: Text(
                            'Quantity: ${data['quantity']} L',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                'Status: ${status[0].toUpperCase()}${status.substring(1)}',
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Date: ${createdAt.toLocal()}',
                                style: const TextStyle(color: Colors.white60),
                              ),
                            ],
                          ),
                        ),
                        if (showMarkDelivered)
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 12, left: 16, right: 16),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade600,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              icon: const Icon(Icons.check_circle),
                              label: const Text("Mark as Delivered"),
                              onPressed: () => _markAsDelivered(id, context),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
