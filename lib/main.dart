import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:soccer_finder/home/home-page.dart';
import 'package:soccer_finder/signin/ui/sign-in.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {

    Widget? home;

    FirebaseAuth.instance
        .authStateChanges()
        .listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
        setState(() {
          home = const SignInPage();
        });
      } else {
        print('User is currently signed in!');
        setState(() {
          home = const HomePage();
        });
      }
    });

    return MaterialApp(
      title: 'Find soccer teams to play with',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: home ?? const Center(child: CircularProgressIndicator()),
    );
  }
}
