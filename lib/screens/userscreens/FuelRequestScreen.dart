import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class FuelRequestScreen extends StatefulWidget {
  const FuelRequestScreen({super.key});

  @override
  State<FuelRequestScreen> createState() => _FuelRequestScreenState();
}

class _FuelRequestScreenState extends State<FuelRequestScreen> {
  final _quantityController = TextEditingController();
  final _user = FirebaseAuth.instance.currentUser;
  String _fuelType = 'Gasoline 90';
  Position? _userLocation;
  bool _loading = false;

  Future<void> _getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _userLocation = position;
    });
  }

  Future<void> _submitRequest() async {
    if (_user == null ||
        _quantityController.text.isEmpty ||
        _userLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please fill all fields and select location.")),
      );
      return;
    }

    setState(() => _loading = true);

    await FirebaseFirestore.instance.collection('orders').add({
      'userId': _user!.uid,
      'quantity': int.tryParse(_quantityController.text) ?? 0,
      'fuelType': _fuelType,
      'latitude': _userLocation!.latitude,
      'longitude': _userLocation!.longitude,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fuel request submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    setState(() => _loading = false);
    Future.delayed(
        const Duration(milliseconds: 800), () => Navigator.pop(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Fuel Request'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // 🔁 Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/bg.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 💠 Blur layer
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),

          // 📦 Main Form
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Request Your Fuel',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _quantityController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration(
                            'Quantity (Liters)', Icons.local_gas_station),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        dropdownColor: Colors.black87,
                        value: _fuelType,
                        decoration: _inputDecoration(
                            'Fuel Type', Icons.local_fire_department),
                        items: const [
                          DropdownMenuItem(
                              value: 'Gasoline 90', child: Text('Gasoline 90')),
                          DropdownMenuItem(
                              value: 'Gasoline 95', child: Text('Gasoline 95')),
                          DropdownMenuItem(
                              value: 'Diesel', child: Text('Diesel')),
                        ],
                        onChanged: (value) =>
                            setState(() => _fuelType = value!),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _getUserLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              _userLocation == null
                                  ? 'Select My Location'
                                  : 'Location Selected',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      if (_userLocation != null) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(
                                  _userLocation!.latitude,
                                  _userLocation!.longitude,
                                ),
                                initialZoom: 15.0,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(_userLocation!.latitude,
                                          _userLocation!.longitude),
                                      width: 60,
                                      height: 60,
                                      child: const Icon(Icons.location_pin,
                                          color: Colors.red, size: 40),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Lat: ${_userLocation!.latitude.toStringAsFixed(5)}, '
                          'Lng: ${_userLocation!.longitude.toStringAsFixed(5)}',
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loading ? null : _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30)),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Submit Request',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white),
      prefixIcon: Icon(icon, color: Colors.white),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white70),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
