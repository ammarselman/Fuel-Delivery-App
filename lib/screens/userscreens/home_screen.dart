import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final scaffoldKey = GlobalKey<ScaffoldState>();

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/splash');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: _buildDrawer(context),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 🔁 Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/assets/bg.jpeg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🔲 Blur layer
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),

          // 📱 UI Content
          SafeArea(
            child: Column(
              children: [
                // AppBar custom with drawer icon
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: () => scaffoldKey.currentState?.openDrawer(),
                      ),
                      const Text(
                        "Fuel Delivery",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 4)
                          ],
                        ),
                      ),
                      const SizedBox(width: 48), // مساحة تعويض أيقونة الإعدادات
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _glassCard(context,
                          icon: Icons.local_gas_station,
                          label: 'Request Fuel',
                          route: '/fuelRequest'),
                      _glassCard(context,
                          icon: Icons.history,
                          label: 'My Orders',
                          route: '/myOrders'),
                      _glassCard(context,
                          icon: Icons.location_on,
                          label: 'Track Order',
                          route: '/trackOrder'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassCard(BuildContext context,
      {required IconData icon, required String label, required String route}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: InkWell(
            onTap: () => Navigator.pushNamed(context, route),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white, size: 30),
                  const SizedBox(width: 16),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios,
                      color: Colors.white70, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black.withOpacity(0.5),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.purpleAccent],
              ),
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Welcome',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.white),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.white),
            title: const Text('Profile', style: TextStyle(color: Colors.white)),
            onTap: () => Navigator.pushNamed(context, '/ProfileScreen'),
          ),
          const Divider(color: Colors.white38),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title:
                const Text('Logout', style: TextStyle(color: Colors.redAccent)),
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}
