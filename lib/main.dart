// Main application file
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Back4App connection
  await Parse().initialize(
     // Replace with your Back4App Application ID
    'LUOpAeXkNC44U8UVmovqjio4rlE1C4utbTtlObWw', 
     // Replace with your Back4App Server URL, typically https://parseapi.back4app.com/
    'https://parseapi.back4app.com/', 
     // Replace with your Back4App Client Key
    clientKey: 'jrLQbcmj3qICZjm3n1ISn4UUh98idI40HL0HhqpI', 
    // Set to false in production
    debug: false, 
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
         '/profile': (_) => const ProfileScreen(),
      },
    );
  }
}