import 'package:cipher_schools_assignment/screens/add_transcation/add_expense.dart';
import 'package:cipher_schools_assignment/screens/add_transcation/add_income.dart';
import 'package:cipher_schools_assignment/screens/auth/login.dart';
import 'package:cipher_schools_assignment/screens/auth/signup.dart';
import 'package:cipher_schools_assignment/screens/auth/welcome_screen.dart';
import 'package:cipher_schools_assignment/screens/bottom_navigation_page.dart';
import 'package:cipher_schools_assignment/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String splashRoute = '/';
  static const String welcomeRoute = '/welcome';
  static const String signupRoute = '/signup';
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';
  static const String expenseRoute = '/expense';
  static const String incomeRoute = '/income';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      initialRoute: splashRoute,
      routes: {
        splashRoute: (context) => const SplashScreen(),
        welcomeRoute: (context) => const WelcomeScreen(),
        signupRoute: (context) => const Signup(),
        loginRoute: (context) => const Login(),
        homeRoute: (context) => const BottomNavigationPage(),
        incomeRoute: (context) => const AddIncome(),
        expenseRoute: (context) => const AddExpense(),
      },
    );
  }
}
