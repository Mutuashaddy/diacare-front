import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diacare/Authentication/api_config.dart';
import 'package:diacare/Authentication/Index.dart';
import 'package:diacare/Authentication/Login.dart';



class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  bool _isLoading = true;
  String? _errorMessage;

  final Color bgColor = const Color(0xFFE3F4F4);
  final Color mainColor = const Color(0xFF1A7B7D);

  final fullNameController = TextEditingController();
  final diabetesTypeController = TextEditingController();
  final ageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = "You are not logged in.";
      });
      return;
    }

    final url = Uri.parse("${ApiConfig.baseUrl}biodata");

    try {
      final response = await http.get(url, headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          fullNameController.text = data['full_name'] ?? '';
          diabetesTypeController.text = data['diabetes_type'] ?? '';
          ageController.text = data['age']?.toString() ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = "Failed to load profile data. Status: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "An error occurred: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      // Handle not logged in
      return;
    }

    final url = Uri.parse("${ApiConfig.baseUrl}biodata");

    final body = {
      'full_name': fullNameController.text,
      'diabetes_type': diabetesTypeController.text,
      'age': ageController.text,
    };

    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!"), backgroundColor: Colors.green),
        );
        setState(() {
          isEditing = false;
        });
      } else {
        // Handle error
      }
    } catch (e) {
      // Handle exception
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse("${ApiConfig.baseUrl}logout");

    try {
      await http.post(url, headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });
    } finally {
      // Always clear local data and navigate, even if API call fails
      await prefs.remove('token');
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Index()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    diabetesTypeController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,

      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF1A7B7D)),
            onPressed: () {
              setState(() {
                isEditing = !isEditing;
              });
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                : Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        // LOGO
                        Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Image.asset("images/dia.png"),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          "My Profile",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: mainColor,
                          ),
                        ),

                        const SizedBox(height: 30),

                        buildTextField("Full Name", fullNameController),
                        const SizedBox(height: 20),

                        buildTextField("Diabetes Type", diabetesTypeController),
                        const SizedBox(height: 20),

                        buildTextField("Age", ageController),
                        const SizedBox(height: 40),

                        // SAVE AND LOGOUT BUTTONS
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // SAVE
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: mainColor,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 35),
                                ),
                                onPressed: isEditing ? _saveProfileData : null,
                                child: const Text("Save",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),

                            // LOGOUT
                            Padding(
                              padding: const EdgeInsets.only(right: 20),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 30),
                                ),
                                onPressed: _logout,
                                child: const Text("Logout",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
      ),

     
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextFormField(
        controller: controller,
        enabled: isEditing,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
