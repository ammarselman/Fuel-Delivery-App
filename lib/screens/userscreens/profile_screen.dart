import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _loading = true;
  late String _email;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser!;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data()!;
    setState(() {
      _nameController.text = data['name'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _email = data['email'] ?? user.email!;
      _loading = false;
    });
  }

  Future<void> _updateProfile() async {
    final user = _auth.currentUser!;
    await _firestore.collection('users').doc(user.uid).update({
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
    });
    Fluttertoast.showToast(msg: 'Profile updated');
  }

  Future<void> _changePassword() async {
    final user = _auth.currentUser!;
    await _auth.sendPasswordResetEmail(email: user.email!);
    Fluttertoast.showToast(
      msg: 'Password reset link sent to $_email',
    );
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor:
            Colors.white, // ✅ يضمن أن الأيقونات والنص باللون الأبيض
        title: const Text('Profile'),
      ),
      body: Stack(
        children: [
          // 🔁 Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/bg.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 🔲 Blur layer
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          // 📦 Glass card with profile content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Full Name', Icons.person),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: TextEditingController(text: _email),
                        readOnly: true,
                        style: const TextStyle(color: Colors.white70),
                        decoration: _inputDecoration('Email', Icons.email),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _phoneController,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDecoration('Phone', Icons.phone),
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text(
                          'Save Changes',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: _updateProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.lock_reset),
                        label: const Text('Change Password'),
                        onPressed: () {
                          Navigator.pushNamed(context, '/changePassword');
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
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
      prefixIcon: Icon(icon, color: Colors.white70),
      labelStyle: const TextStyle(color: Colors.white),
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
