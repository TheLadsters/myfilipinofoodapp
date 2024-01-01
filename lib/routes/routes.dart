import 'package:myfilipinofoodapp/screens/layouts/home_screen.dart';
import 'package:myfilipinofoodapp/screens/login_screen.dart';
import 'package:myfilipinofoodapp/screens/settings_screen.dart';

final routes = {
  '/login': (context) => const LoginScreen(),
  '/homepage': (context) => const HomeScreen(),
  '/settings': (context) => const SettingsScreen(),
};
