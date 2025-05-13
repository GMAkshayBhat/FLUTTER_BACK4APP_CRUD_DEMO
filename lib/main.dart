// Main application file
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Back4App connection
  await Parse().initialize(
    'LUOpAeXkNC44U8UVmovqjio4rlE1C4utbTtlObWw',  // Replace with your Back4App Application ID
    'https://parseapi.back4app.com/',  // Replace with your Back4App Server URL, typically https://parseapi.back4app.com/
    clientKey: 'jrLQbcmj3qICZjm3n1ISn4UUh98idI40HL0HhqpI',  // Replace with your Back4App Client Key
    debug: true, // Set to false in production
    autoSendSessionId: true,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Back4App Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder<dynamic>(
  future: ParseUser.currentUser(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    } else if (snapshot.hasData && snapshot.data != null) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  },
),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}