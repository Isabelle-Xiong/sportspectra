import 'package:flutter/material.dart';
import 'package:sportspectra/screens/login_screen.dart';
import 'package:sportspectra/screens/onboarding_screen.dart';
import 'package:sportspectra/screens/signup_screen.dart';
import 'package:sportspectra/utils/colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SportSpectra',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: AppBarTheme.of(context).copyWith(
          backgroundColor: backgroundColor,
          elevation: 0,
          titleTextStyle: const TextStyle(
            color: primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: const IconThemeData(
            color: primaryColor,
          ),
        ),
      ),
      routes: {
        // map of widget functions

        //routename was defined in the onboarding_screen.dart. You can also define it here but error prone if you make typo
        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
        LoginScreen.routeName: (context) => const LoginScreen(),
        SignupScreen.routeName: (context) => const SignupScreen(),
      },
      home: const OnboardingScreen(),
    );
  }
}
