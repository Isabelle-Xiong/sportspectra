import 'package:flutter/material.dart';
import 'package:sportspectra/screens/login_screen.dart';
import 'package:sportspectra/screens/signup_screen.dart';
import 'package:sportspectra/widgets/custom_button.dart';

class OnboardingScreen extends StatelessWidget {
  static const routeName = '/onboarding';
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //determine what and how elements will appear on screen here
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Column(
        // make all children center
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Welcome to \n SportSpectra',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 40,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: CustomButton(
              onTap: () {
                // Navigator.pushNamed is basically segue. on tap of login button, it will take you to login screen)
                Navigator.pushNamed(context, LoginScreen.routeName);
              },
              text: 'Log in',
            ),
          ),
          CustomButton(
              onTap: () {
                Navigator.pushNamed(context, SignupScreen.routeName);
              },
              text: 'Sign up')
        ],
      ),
    ));
  }
}
