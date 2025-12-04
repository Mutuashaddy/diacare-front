import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:diacare/Authentication/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:diacare/Authentication/Home.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  bool isEditing = true;
  bool isLoading = false;

  // Controllers
  final TextEditingController caregiverName = TextEditingController();
  final TextEditingController caregiverNumber = TextEditingController();

  final TextEditingController doctorName = TextEditingController();
  final TextEditingController doctorNumber = TextEditingController();

  final TextEditingController hospitalName = TextEditingController();
  final TextEditingController hospitalNumber = TextEditingController();
  final TextEditingController hospitalLocation = TextEditingController();

  // CALL FUNCTION
  Future<void> callNumber(String number) async {
    final Uri uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not call $number")),
      );
    }
  }

  // SAVE FUNCTION
  Future<void> saveToDatabase() async {
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Authentication error. Please log in again.")),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.post(
        Uri.parse("${ApiConfig.baseUrl}emergency"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "caregiver_name": caregiverName.text,
          "caregiver_number": caregiverNumber.text,
          "doctor_name": doctorName.text,
          "doctor_number": doctorNumber.text,
          "hospital_name": hospitalName.text,
          "hospital_number": hospitalNumber.text,
          "hospital_location": hospitalLocation.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await prefs.setBool("emergencyContactFilled", true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Saved successfully!")),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else if (response.statusCode == 422) {
        final errors = jsonDecode(response.body)['errors'];
        String errorMessage = "";
        errors.forEach((key, value) => errorMessage += "- ${value[0]}\n");
        _showErrorDialog("Validation Error", errorMessage.trim());
      } else {
        _showErrorDialog("Error", "Status: ${response.statusCode}");
      }
    } catch (e) {
      _showErrorDialog("Network Error", e.toString());
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3F4F4),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Emergency Contacts",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit, color: Colors.black),
            onPressed: () {
              setState(() => isEditing = !isEditing);
            },
          )
        ],
      ),

      // BODY
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              buildCard(
                icon: Icons.person,
                title: "Caregiver",
                nameController: caregiverName,
                numberController: caregiverNumber,
              ),
              const SizedBox(height: 15),

              buildCard(
                icon: Icons.local_hospital,
                title: "Doctor",
                nameController: doctorName,
                numberController: doctorNumber,
              ),
              const SizedBox(height: 15),

              // HOSPITAL CARD
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.apartment, color: Colors.teal, size: 30),
                      title: TextField(
                        controller: hospitalName,
                        decoration: const InputDecoration(
                          labelText: "Hospital Name",
                          border: InputBorder.none,
                        ),
                        enabled: isEditing,
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.call, color: Colors.green, size: 28),
                      title: TextField(
                        controller: hospitalNumber,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: "Hospital Number",
                          border: InputBorder.none,
                        ),
                        enabled: isEditing,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.phone, color: Colors.green),
                        onPressed: () {
                          if (hospitalNumber.text.isNotEmpty) {
                            callNumber(hospitalNumber.text);
                          }
                        },
                      ),
                    ),

                    ListTile(
                      leading: const Icon(Icons.location_on, color: Colors.teal, size: 30),
                      title: TextField(
                        controller: hospitalLocation,
                        decoration: const InputDecoration(
                          labelText: "Hospital Location (Google Maps Link)",
                          border: InputBorder.none,
                        ),
                        enabled: isEditing,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.map, color: Colors.teal),
                        onPressed: () {
                          if (hospitalLocation.text.isNotEmpty) {
                            launchUrl(Uri.parse(hospitalLocation.text),
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // SAVE BUTTON
              Visibility(
                visible: isEditing,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A7B7D),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: isLoading ? null : saveToDatabase,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Save", style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ERROR DIALOG
  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  // REUSABLE CARD
  Widget buildCard({
    required IconData icon,
    required String title,
    required TextEditingController nameController,
    required TextEditingController numberController,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: Colors.teal, size: 30),
            title: TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "$title Name",
                border: InputBorder.none,
              ),
              enabled: isEditing,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.call, color: Colors.green),
            title: TextField(
              controller: numberController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "$title Number",
                border: InputBorder.none,
              ),
              enabled: isEditing,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.phone, color: Colors.green),
              onPressed: () {
                if (numberController.text.isNotEmpty) {
                  callNumber(numberController.text);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
