import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _user = FirebaseAuth.instance.currentUser;
  final _nameController = TextEditingController();

  Future<void> _update() async {
    if (_user == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_user!.uid)
        .update({'name': _nameController.text.trim()});
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    // load current name
    if (_user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .get()
          .then((doc) {
        if (doc.exists) {
          setState(() {
            _nameController.text = (doc.data()!['name'] ?? '');
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _update, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
