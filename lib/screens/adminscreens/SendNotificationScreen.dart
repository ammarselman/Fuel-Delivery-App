import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  _SendNotificationScreenState createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  Future<void> sendNotificationToAll() async {
    final users = await FirebaseFirestore.instance.collection('users').get();
    final tokens = users.docs
        .map((doc) => doc.data()['fcmToken'])
        .where((token) => token != null)
        .toList();

    for (var token in tokens) {
      await sendPushMessage(token, _titleController.text, _bodyController.text);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notification sent to all users')),
    );
  }

  Future<void> sendPushMessage(String token, String title, String body) async {
    // ignore: prefer_const_declarations
    final serverKey =
        'YOUR_SERVER_KEY_HERE'; // Replace with your FCM server key

    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode(
          <String, dynamic>{
            'to': token,
            'notification': <String, dynamic>{
              'title': title,
              'body': body,
            },
            'priority': 'high',
          },
        ),
      );
    } catch (e) {
      print("Error sending push notification: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Notifications')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title')),
            TextField(
                controller: _bodyController,
                decoration: const InputDecoration(labelText: 'Body')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendNotificationToAll,
              child: const Text('Send Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
