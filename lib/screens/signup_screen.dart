import 'package:flutter/material.dart';
import 'package:sportspectra/resources/auth_methods.dart';
import 'package:sportspectra/screens/home_screen.dart';
import 'package:sportspectra/widgets/custom_button.dart';
import 'package:sportspectra/widgets/custom_textfield.dart';

class SignupScreen extends StatefulWidget {
  static const String routeName = '/signup';
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // emailController is used to control email textfield to interact with it. made the TextEditingController in custom_textfield.controller.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final AuthMethods _authMethods = AuthMethods();

  void signUpUser() async {
    bool res = await _authMethods.signUpUser(
      context,
      _emailController.text,
      _usernameController.text,
      _passwordController.text,
    );

    // if res is true, we go to home screen
    if (res) {
      Navigator.pushNamed(context, HomeScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    // for any screen size, it will adjust application to fit screen
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      // need scrollable cuz when keyboard pops up we want to be able to adjust screen by scrolling
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(height: size.height * 0.1),
            const Text('Email',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                )),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: CustomTextField(controller: _emailController),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text('Username',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                )),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: CustomTextField(controller: _usernameController),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text('Password',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                )),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: CustomTextField(controller: _passwordController),
            ),
            const SizedBox(
              height: 20,
            ),
            CustomButton(onTap: signUpUser, text: 'Sign Up')
          ]),
        ),
      ),
    );
  }
}
