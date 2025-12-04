import 'package:flutter/material.dart';
import 'package:diacare/Authentication/Login.dart';
import 'package:diacare/Authentication/api_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final dobController = TextEditingController();
  final passController = TextEditingController();
  final confirmPassController = TextEditingController();
  // Use 127.0.0.1 with `adb reverse tcp:8000 tcp:8000` for physical devices

  final _formkey = GlobalKey<FormState>();
   final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

  bool _passwordVisible = false; 
  bool _isLoading = false;


  DateTime? dob;

 

  Future<void> pickDOB() async {
    DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      dob = selected;
      dobController.text = DateFormat('yyyy-MM-dd').format(selected); 
    }
  }

  int calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> registerUser() async {
    setState(() {
      _isLoading = true;
    });

    print("Register button pressed.");
    if (!_formkey.currentState!.validate()) {
      print("Form validation failed.");
      // Stop the loading indicator if validation fails
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your date of birth.")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    int age = calculateAge(dob!);

    if (age < 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("You must be at least 15 years old to register.")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final registerUrl = Uri.parse("${ApiConfig.baseUrl}register");

    print("Attempting to register with URL: $registerUrl");
    try {
      final response = await http.post(
        registerUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'full_name': nameController.text,
          'email': emailController.text,
          'dob': dobController.text,
          'password': passController.text,
          'password_confirmation': confirmPassController.text, 
        }),
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        print("Registration successful!");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registration successful! Please log in."),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      } else if (response.statusCode == 422) {
        // Handle validation errors from the backend
        final errors = jsonDecode(response.body)['errors'] as Map<String, dynamic>;
        String errorMessage = "Registration failed:\n";
        errors.forEach((key, value) {
          errorMessage += "- ${value[0]}\n";
        });
        _showErrorDialog("Validation Error", errorMessage.trim());
      } else {
        // Handle other server errors
        _showErrorDialog("Registration Failed", "An unexpected error occurred. Please try again. (Status: ${response.statusCode})");
      }
    } catch (e) {
      print("An error occurred during registration: $e");
      if (!mounted) return;
      // Provide more specific feedback for timeouts
      String errorMessage = e.toString().contains('TimeoutException')
          ? "Could not connect to the server. Please check your network connection and try again."
          : "An unexpected error occurred: $e";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: const Text('Okay'),
            onPressed: () => Navigator.of(ctx).pop(),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F4F4),
    
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formkey,
            child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
              children: [
                
                const SizedBox(height: 25),

                const Text(
                  
                  "Create Account",
                  style: TextStyle(
                    
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A7B7D),
                  ),
                ),
                const SizedBox(height: 20),

                // Full Name
                TextFormField(
                  controller: nameController,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your name' : null,
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: emailController,
                 validator: (value) {
  if (value!.isEmpty) return "Enter your email";
  if (!emailRegex.hasMatch(value)) return "Invalid email format";
  return null;
},

                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: dobController,
                  readOnly: true,
                  validator: (value) =>
                      value!.isEmpty ? 'Select date of birth' : null,
                  onTap: pickDOB,
                  decoration: const InputDecoration(
                    labelText: "Date of Birth",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_month),
                  ),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: passController,
                  obscureText: !_passwordVisible,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: confirmPassController,
                  obscureText: !_passwordVisible,
                  validator: (value) {
                    if (value!.isEmpty) return 'Confirm your password';
                    if (value != passController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Confirm Password",
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Register Button
                SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: _isLoading ? null : registerUser,
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF1A7B7D),
      padding: EdgeInsets.symmetric(vertical: 15),
    ),
    child: _isLoading
        ? const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          )
        : const Text('Register',
            style: TextStyle(color: Colors.white, fontSize: 16)),
  ),
),

const SizedBox(height: 20),

Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    const Text("Already have an account? "),
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const Login()),
        );
      },
      child: const Text(
        "Login",
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
