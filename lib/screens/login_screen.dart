import 'package:flutter/material.dart';
import 'package:sportspectra/resources/auth_methods.dart';
import 'package:sportspectra/screens/home_screen.dart';
import 'package:sportspectra/widgets/custom_button.dart';
import 'package:sportspectra/widgets/custom_textfield.dart';
import 'package:sportspectra/widgets/loading_indicator.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // emailController is used to control email textfield to interact with it. made the TextEditingController in custom_textfield.controller.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthMethods _authMethods = AuthMethods();

  bool _isLoading = false;

  loginUser() async {
    setState(() {
      _isLoading = true;
    });
    bool res = await _authMethods.loginUser(
        context, _emailController.text, _passwordController.text);
    setState(() {
      _isLoading = false;
    });
    if (res) {
      //  pushReplacementNamed not only replaces the current route with the new one but also removes the current route from the navigation stack. This ensures that the user cannot navigate back to the previous screen using the back button.
      // After a user successfully logs in, you might want to clear the login screen from the navigation stack to prevent users from going back to the login screen using the back button. This is especially important for security reasons to avoid exposing sensitive information like login credentials.
      Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // for any screen size, it will adjust application to fit screen
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log In'),
      ),
      // need scrollable cuz when keyboard pops up we want to be able to adjust screen by scrolling
      body: _isLoading
          ? const LoadingIndicator()
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      CustomButton(onTap: loginUser, text: 'Log In')
                    ]),
              ),
            ),
    );
  }
}
