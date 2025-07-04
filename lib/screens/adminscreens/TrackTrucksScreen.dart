import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TrackTrucksScreen extends StatelessWidget {
  const TrackTrucksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Registered Drivers')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('drivers').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final drivers = snapshot.data!.docs;

          if (drivers.isEmpty) {
            return const Center(child: Text('No drivers found.'));
          }

          List<Marker> markers = [];
          List<Widget> driverCards = [];

          for (var doc in drivers) {
            final data = doc.data() as Map<String, dynamic>;

            final name = data['name'] ?? 'Unknown';
            final email = data['email'] ?? 'N/A';
            final phone = data['phone'] ?? 'N/A';
            final status = data['status'] ?? 'available';
            final lat = data['driverLat'];
            final lng = data['driverLng'];

            // أضف العلامة على الخريطة إن وُجد الموقع
            if (lat != null && lng != null) {
              final LatLng location = LatLng(lat, lng);

              markers.add(
                Marker(
                  width: 60.0,
                  height: 60.0,
                  point: location,
                  child: Tooltip(
                    message: name,
                    child: Icon(
                      Icons.local_shipping,
                      color: status == 'on_delivery'
                          ? Colors.orange
                          : Colors.green,
                      size: 40,
                    ),
                  ),
                ),
              );
            }

            // أنشئ البطاقة بمعلومات السائق
            driverCards.add(
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                elevation: 3,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        status == 'on_delivery' ? Colors.orange : Colors.green,
                    child:
                        const Icon(Icons.local_shipping, color: Colors.white),
                  ),
                  title: Text(name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Email: $email'),
                      Text('Phone: $phone'),
                      Text('Status: ${status.toUpperCase()}'),
                    ],
                  ),
                ),
              ),
            );
          }

          const mapCenter = LatLng(24.7136, 46.6753); // Riyadh

          return Column(
            children: [
              SizedBox(
                height: 300,
                child: FlutterMap(
                  options: const MapOptions(
                    initialCenter: mapCenter,
                    initialZoom: 12.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    MarkerLayer(markers: markers),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Drivers List',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey),
                ),
              ),
              Expanded(child: ListView(children: driverCards)),
            ],
          );
        },
      ),
    );
  }
}
