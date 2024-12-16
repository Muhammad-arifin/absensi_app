import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'LoginPage.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> register() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final name = _nameController.text;
    final role = "user"; // Role tetap sebagai "user"

    final response = await Supabase.instance.client.auth.signUp(email, password);

    if (response.error == null) {
      // Masukkan data pengguna ke tabel 'users'
      final user = response.user;
      final userId = user?.id;

      if (userId != null) {
        final result = await Supabase.instance.client.from('users').insert({
          'id': userId,
          'email': email,
          'name': name,
          'role': role, // Simpan role sebagai "user"
        }).execute();

        if (result.error == null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        } else {
          showErrorDialog(result.error!.message);
        }
      }
    } else {
      showErrorDialog(response.error!.message);
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Registration Failed"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade900, Colors.blue.shade300],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person_add,
                      size: 50,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter email' : null,
                  ),
                  SizedBox(height: 10),
                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                    ),
                    obscureText: true,
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter password' : null,
                  ),
                  SizedBox(height: 10),
                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.9),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter name' : null,
                  ),
                  SizedBox(height: 20),
                  // Register Button
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        register();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                      backgroundColor: const Color.fromARGB(255, 224, 240, 255),
                    ),
                    child: Text(
                      style: TextStyle(fontSize: 16, color: Colors.blueAccent),
                      'Register'
                    ),
                  ),
                  SizedBox(height: 20),
                  // Navigation to Login
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    child: Text(
                      'Already have an account? Login here',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
