// File: screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers for input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Loading state for the login button
  bool _isLoading = false;

  // Function to perform login
  void _login() async {
    setState(() {
      _isLoading = true;
    });

    // Read input values
    final username = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Basic validation
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      // Create a ParseUser instance and attempt login
      final user = ParseUser(username, password, null);
      final response = await user.login();

      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful!')),
        );
        // Navigate to home screen on success
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.error!.message}')),
        );
      }
    } catch (e) {
      // Catch and show any exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Returns a greeting string based on time of day
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  // Returns a motivational thought based on time of day
  String _getThought() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Start your day with a smile and positive thoughts.';
    if (hour < 17) return 'Keep going! You\'re doing great this afternoon.';
    return 'Relax and reflect on the wins of the day.';
  }

  @override
  Widget build(BuildContext context) {
    // Get dynamic greeting and thought
    final greeting = _getGreeting();
    final thought = _getThought();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            const CircleAvatar(
              radius: 40,
              child: Text(
                'A',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16.0),
            Column(
              children: [
                Text(
                  "Welcome to ToDo App!!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                SizedBox(height: 4),
                Text(
                  "Organize your day, one task at a time.",
                  style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Dynamic greeting
            Text(
              greeting,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            // Dynamic motivational thought
            Text(
              thought,
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32.0),

            // Username/email field
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Username/Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16.0),

            // Password field
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24.0),

            // Login button or loading spinner
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),

            const SizedBox(height: 16.0),

            // Navigate to signup screen
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: const Text('Don\'t have an account? Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
