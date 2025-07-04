import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class DriverAvailableOrdersScreen extends StatefulWidget {
  const DriverAvailableOrdersScreen({super.key});

  @override
  State<DriverAvailableOrdersScreen> createState() =>
      _DriverAvailableOrdersScreenState();
}

class _DriverAvailableOrdersScreenState
    extends State<DriverAvailableOrdersScreen> {
  final _auth = FirebaseAuth.instance;
  late User _driver;

  @override
  void initState() {
    super.initState();
    _driver = _auth.currentUser!;
  }

  Future<void> _acceptOrder(String orderId) async {
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'assignedTo': _driver.uid,
      'driverLat': pos.latitude,
      'driverLng': pos.longitude,
      'status': 'assigned',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order assigned to you.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .where('status', isEqualTo: 'accepted')
        .snapshots();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Available Orders'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/truck.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),
          SafeArea(
            child: StreamBuilder<QuerySnapshot>(
              stream: ordersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                if (docs.isEmpty) {
                  return const Center(
                      child: Text('No available orders',
                          style: TextStyle(color: Colors.white)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final id = docs[i].id;
                    final quantity = data['quantity'];
                    final fuel = data['fuelType'];
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
                              Text('Fuel Type: $fuel',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text('Quantity: $quantity L',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14)),
                              const SizedBox(height: 6),
                              if (time != null)
                                Text('Requested at: ${time.toLocal()}',
                                    style: const TextStyle(
                                        color: Colors.white60, fontSize: 13)),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: ElevatedButton(
                                  onPressed: () => _acceptOrder(id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.lightBlue.shade300,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 10),
                                  ),
                                  child: const Text('Accept'),
                                ),
                              )
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
