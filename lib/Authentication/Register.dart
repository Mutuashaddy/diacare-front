import 'package:flutter/material.dart';
import 'package:diacare/Authentication/Login.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  final baseUrl = "http://192.168.100.27:8000/api/";
 // Replace with your API base URL

  final _formkey = GlobalKey<FormState>();
   final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

  bool _passwordVisible = false; 


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
      dobController.text =
          "${selected.year}-${selected.month}-${selected.day}"; 
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
    if (!_formkey.currentState!.validate()) return;

    if (dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your date of birth.")),
      );
      return;
    }

    int age = calculateAge(dob!);

    if (age < 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("You must be at least 15 years old to register.")),
      );
      return;
    }

    final registerUrl = Uri.parse("${baseUrl}register");

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
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration failed: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
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
                  validator: (value) =>
                      value!.isEmpty ? 'Enter your password' : null,
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
    onPressed: registerUser,
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF1A7B7D),
      padding: EdgeInsets.symmetric(vertical: 15),
    ),
    child: Text(
      'Register',
      style: TextStyle(color: Colors.white, fontSize: 16),
    ),
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

