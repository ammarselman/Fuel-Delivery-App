import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool showContent = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        showContent = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final blue = Colors.lightBlue.shade300;

    return Scaffold(
      backgroundColor: blue,
      body: SafeArea(
        child: Stack(
          children: [
            //زر السائق
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.local_shipping, color: Colors.white),
                tooltip: 'Driver Login',
                onPressed: () => Navigator.pushNamed(context, '/driverAccess'),
              ),
            ),
            // زر المسؤول
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon:
                    const Icon(Icons.admin_panel_settings, color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, '/adminLogin'),
              ),
            ),
            // محتوى الشاشة
            Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 800),
                opacity: showContent ? 1.0 : 0.0,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Hero(
                        tag: 'logo',
                        child: Image.asset(
                          'lib/assets/logo-removebg-preview.png',
                          height: 100,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Welcome to Fuel Delivery App',
                        style: GoogleFonts.raleway(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Order your fuel quickly and safely, delivered to your doorstep with real-time tracking.',
                        style: GoogleFonts.quicksand(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/login'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 12),
                          backgroundColor: Colors.lightBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
