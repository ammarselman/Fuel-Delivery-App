import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:truk_oil/firebase_options.dart';
import 'package:truk_oil/screens/adminscreens/AdminDashboardScreen.dart';
import 'package:truk_oil/screens/auth/admin/AdminLoginScreen.dart';
import 'package:truk_oil/screens/driver/DriverAccessScreen.dart';
import 'package:truk_oil/screens/driver/DriverAssignedOrdersScreen.dart';
import 'package:truk_oil/screens/driver/DriverAvailableOrdersScreen.dart';
import 'package:truk_oil/screens/driver/DriverHomeScreen.dart';
import 'package:truk_oil/screens/auth/driver/DriverLoginScreen.dart';
import 'package:truk_oil/screens/auth/driver/DriverRegisterScreen.dart';
import 'package:truk_oil/screens/userscreens/ChangePasswordScreen.dart';
import 'package:truk_oil/screens/userscreens/FuelRequestScreen.dart';
import 'package:truk_oil/screens/adminscreens/GenerateReportsScreen.dart';
import 'package:truk_oil/screens/userscreens/MyOrdersScreen.dart';
import 'package:truk_oil/screens/adminscreens/ReviewRequestsScreen.dart';
import 'package:truk_oil/screens/adminscreens/SendNotificationScreen.dart';
import 'package:truk_oil/screens/userscreens/TrackOrderScreen.dart';
import 'package:truk_oil/screens/adminscreens/TrackTrucksScreen.dart';
import 'package:truk_oil/screens/userscreens/UpdateProfileScreen.dart';
import 'package:truk_oil/screens/userscreens/home_screen.dart';
import 'package:truk_oil/screens/auth/user/login_screen.dart';
import 'package:truk_oil/screens/userscreens/profile_screen.dart';
import 'package:truk_oil/screens/auth/user/register_screen.dart';
import 'package:truk_oil/screens/welcome/splashscreen.dart';
import 'package:truk_oil/screens/welcome/welcomepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FuelDeliveryApp());
}

class FuelDeliveryApp extends StatelessWidget {
  const FuelDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fuel Delivery',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/welcome': (_) => const WelcomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => HomeScreen(),
        '/fuelRequest': (_) => const FuelRequestScreen(),
        '/myOrders': (_) => const MyOrdersScreen(),
        '/trackOrder': (_) => const TrackOrderScreen(),
        '/ProfileScreen': (_) => const ProfileScreen(),
        '/updateProfile': (_) => const UpdateProfileScreen(),
        '/changePassword': (_) => const ChangePasswordScreen(),
        '/adminLogin': (_) => const AdminLoginScreen(),
        '/adminDashboard': (_) => const AdminDashboardScreen(),
        '/reviewRequests': (_) => const ReviewRequestsScreen(),
        '/trackTrucks': (_) => const TrackTrucksScreen(),
        '/sendNotifications': (_) => const SendNotificationScreen(),
        '/generateReports': (_) => const GenerateReportsScreen(),
        '/driverAccess': (_) => const DriverAccessScreen(),
        '/driverLogin': (_) => const DriverLoginScreen(),
        '/driverRegister': (_) => const DriverRegisterScreen(),
        '/driverHome': (_) => const DriverHomeScreen(),
        '/driverAvailable': (_) => const DriverAvailableOrdersScreen(),
        '/driverAssigned': (_) => const DriverAssignedOrdersScreen(),
      },
    );
  }
}
