import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportspectra/providers/user_provider.dart';
import 'package:sportspectra/resources/auth_methods.dart';
import 'package:sportspectra/screens/home_screen.dart';
import 'package:sportspectra/screens/login_screen.dart';
import 'package:sportspectra/screens/onboarding_screen.dart';
import 'package:sportspectra/screens/signup_screen.dart';
import 'package:sportspectra/utils/colors.dart';
import 'package:sportspectra/widgets/loading_indicator.dart';
import 'models/user.dart' as model;

void main() async {
  // ensure widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // if web, connect to firebase web
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyBZ5hyQln-bep4lGbbF6eFXIr8Ex6L2p5c",
            authDomain: "sportspectra-f56d5.firebaseapp.com",
            projectId: "sportspectra-f56d5",
            storageBucket: "sportspectra-f56d5.appspot.com",
            messagingSenderId: "201033761181",
            appId: "1:201033761181:web:16ba74eb31d402829a2f74"));
  } else {
    await Firebase.initializeApp();
  }

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
    ),
  ], child: const MyApp()));
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
        HomeScreen.routeName: (context) => const HomeScreen(),
      },
      // when we close the app and reopen, we want users that have logged in to stay logged in, and not go back to login screen
      home: FutureBuilder(
        // if current user signed up, currentUser cannot be null
        future: AuthMethods()
            .getCurrentUser(FirebaseAuth.instance.currentUser != null
                // if they havent signed up it may be null and you return null
                ? FirebaseAuth.instance.currentUser!.uid
                : null)
            .then((value) {
          //if map value is null, dont do anything cuz still in onboarding, if has any value then need to store in user provider
          if (value != null) {
            Provider.of<UserProvider>(context, listen: false).setUser(
              model.User.fromMap(value),
            );
          }
          // if value not equal to null, return value
          return value;
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }

          if (snapshot.hasData) {
            // if snapshot has data, that means user already logged in so go to home screen
            return const HomeScreen();
          }
          return const OnboardingScreen();
        },
      ),
    );
  }
}
