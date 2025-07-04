import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReviewRequestsScreen extends StatelessWidget {
  const ReviewRequestsScreen({super.key});

  Future<void> updateOrderStatus(String orderId, String status) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({'status': status});
  }

  Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return doc.exists ? doc.data() : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Requests')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(child: Text('No pending orders.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final data = order.data() as Map<String, dynamic>;
              final userId = data['userId'] ?? '';
              final quantity = data['quantity'] ?? 0;
              final fuel = data['fuelType'] ?? 'N/A';
              final lat = data['latitude'];
              final lng = data['longitude'];
              final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

              return FutureBuilder<Map<String, dynamic>?>(
                future: fetchUserData(userId),
                builder: (context, userSnapshot) {
                  final user = userSnapshot.data;

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fuel: $fuel - $quantity L',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          if (lat != null && lng != null)
                            Text(
                                'Location: Lat: ${lat.toStringAsFixed(4)}, Lng: ${lng.toStringAsFixed(4)}'),
                          if (createdAt != null)
                            Text('Requested at: ${createdAt.toLocal()}'),
                          const SizedBox(height: 8),
                          const Divider(),
                          user != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('User: ${user['name'] ?? 'N/A'}'),
                                    Text('Phone: ${user['phone'] ?? 'N/A'}'),
                                    Text('Email: ${user['email'] ?? 'N/A'}'),
                                  ],
                                )
                              : const Text('User info not found'),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () =>
                                    updateOrderStatus(order.id, 'accepted'),
                                icon: const Icon(Icons.check),
                                label: const Text("Accept"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton.icon(
                                onPressed: () =>
                                    updateOrderStatus(order.id, 'rejected'),
                                icon: const Icon(Icons.close),
                                label: const Text("Reject"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
