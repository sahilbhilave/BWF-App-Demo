import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'login.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  late ScaffoldMessengerState _scaffoldMessengerState;
  bool _isLoading = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _registerUser(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      String username = _usernameController.text;
      String password = _passwordController.text;
      String phone = _emailController.text;
      bool registered = await _registerUserToServer(username, password, phone);
      if (registered) {
        Navigator.pop(context);
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _registerUserToServer(
      String username, String password, String phone) async {
    try {
      String url = '${dotenv.env['REGISTER_USER']}';

      var response = await http.post(
        Uri.parse(url),
        body: {
          'username': username,
          'password': password,
          'phone': phone,
        },
      );

      // Map<String, dynamic> jsonResponse = json.decode(response.body);as
      print(response.body);
      if (response.body.contains("successfully")) {
        _showSnackbar('User registered successfully!');
        return true;
      } else {
        _showSnackbar('Error: Username already exists $response');
        return false;
      }
    } catch (e) {
      _showSnackbar('Error registering user: $e');
      return false;
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _navigateToLoginPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Login()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/DC_Logo.jpeg',
                ),
                SizedBox(height: 50),
                TextFormField(
                  controller: _usernameController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(Icons.person, color: Color(0xffff31304D)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter username';
                    }
                    if (!RegExp(r'^[a-zA-Z]*$').hasMatch(value)) {
                      return 'Name should only contain letters and blank spaces';
                    }
                    if (value.length > 50) {
                      return 'Name must be 50 characters or less';
                    }
                    if (value.length < 5) {
                      return 'Name must be at least 5 characters';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.name,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Phone no',
                    labelStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(Icons.phone, color: Color(0xffff31304D)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your mobile number';
                    }
                    if (value.contains(RegExp(r'[^\d]')) ||
                        value.length != 10) {
                      return 'Mobile number must contain only 10 digits';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(Icons.lock, color: Color(0xffff31304D)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 5) {
                      return 'Please enter a password with minimum 5 characters';
                    }
                    if (value.length > 50) {
                      return 'Password can be at most 50 characters long.';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    labelStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(Icons.lock, color: Color(0xffff31304D)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _registerUser(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xffff31304D),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          'Register',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () => _navigateToLoginPage(context),
                  child: Text(
                    'Already a User? Login Here',
                    style: TextStyle(color: Color(0xffff161A30)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
