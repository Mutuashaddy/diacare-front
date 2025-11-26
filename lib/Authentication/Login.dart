import 'package:diacare/Authentication/Register.dart';
import 'package:flutter/material.dart';
import 'package:diacare/Authentication/BioData.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;



class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
final passwordController = TextEditingController();
final baseUrl = "http://192.168.100.27:8000/api/";   

//fuction login proces
Future<void> loginUser() async {
  final url = Uri.parse("${baseUrl}login");

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": emailController.text,
        "password": passwordController.text,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      String token = data["token"];

      // Save token using SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);
      



      // Navigate after success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BioData()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: ${response.body}")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}



  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F4F4), 
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                //  Logo  
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Image.asset(
                      'images/dia.png', 
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  'Log in',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A7B7D), 
                  ),
                ),

                const SizedBox(height: 30),

                //  Email Field 
                TextFormField(
                   controller: emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.email,
                      color: Color(0xFF1A7B7D),
                    ),
                    labelText: 'Enter Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                //Password Field 
                TextFormField(
                   controller: passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Color(0xFF1A7B7D),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Color(0xFF1A7B7D),
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                    labelText: 'Enter Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                //  Login Button 
               SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF1A7B7D),
      padding: EdgeInsets.symmetric(vertical: 15),
    ),
    onPressed: loginUser,
    child: Text('Log In', style: TextStyle(color: Colors.white, fontSize: 16)),
  ),
),
const SizedBox(height: 20),
            //  Register Redirect 
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const Register()),
                        );
                      },
                      child: const Text(
                        "Register",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
