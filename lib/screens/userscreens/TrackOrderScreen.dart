import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TrackOrderScreen extends StatefulWidget {
  const TrackOrderScreen({super.key});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    final ordersStream = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: user!.uid)
        .where('assignedTo', isNotEqualTo: null)
        .orderBy('createdAt', descending: true)
        .snapshots();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Track My Orders'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/bg.jpeg'), // الخلفية
                fit: BoxFit.cover,
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(color: Colors.black.withOpacity(0.3)),
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
                    child: Text('No active orders yet.',
                        style: TextStyle(color: Colors.white)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final fuel = data['fuelType'];
                    final quantity = data['quantity'];
                    final time = (data['createdAt'] as Timestamp?)?.toDate();
                    final userLat = data['latitude'];
                    final userLng = data['longitude'];
                    final driverLat = data['driverLat'];
                    final driverLng = data['driverLng'];

                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
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
                              Text('Fuel: $fuel - $quantity L',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              if (time != null)
                                Text('Created at: ${time.toLocal()}',
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 13)),
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.map),
                                  label: const Text('Track'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.lightBlue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.75,
                                        child: _buildMapView(
                                          LatLng(userLat, userLng),
                                          LatLng(driverLat, driverLng),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
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

  Widget _buildMapView(LatLng userLocation, LatLng driverLocation) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Scaffold(
        body: FlutterMap(
          options: MapOptions(
            initialCenter: userLocation,
            initialZoom: 13.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            ),
            MarkerLayer(markers: [
              Marker(
                point: userLocation,
                width: 60,
                height: 60,
                child: const Icon(Icons.person_pin_circle,
                    size: 40, color: Colors.blue),
              ),
              Marker(
                point: driverLocation,
                width: 60,
                height: 60,
                child: const Icon(Icons.local_shipping,
                    size: 40, color: Colors.red),
              ),
            ]),
            PolylineLayer(
              polylines: [
                Polyline(
                  points: [userLocation, driverLocation],
                  color: Colors.green,
                  strokeWidth: 4,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
