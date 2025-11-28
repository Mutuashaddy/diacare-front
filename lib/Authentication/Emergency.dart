import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  bool isEditing = false;

  // Controllers
  TextEditingController caregiverName = TextEditingController();
  TextEditingController caregiverNumber = TextEditingController();

  TextEditingController doctorName = TextEditingController();
  TextEditingController doctorNumber = TextEditingController();

  // 🌟 NEW CONTROLLER for Hospital Name
  TextEditingController hospitalName = TextEditingController();
  TextEditingController hospitalNumber = TextEditingController();
  TextEditingController hospitalLocation = TextEditingController();

  // Your backend API URL
  final String apiUrl = "http://YOUR_SERVER_IP/api/emergency"; // <-- replace with your endpoint

  // Call method
  Future<void> callNumber(String number) async {
    final Uri uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch phone app for $number')),
      );
    }
  }

  // Save to database
  Future<void> saveToDatabase() async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "caregiver_name": caregiverName.text,
          "caregiver_number": caregiverNumber.text,
          "doctor_name": doctorName.text,
          "doctor_number": doctorNumber.text,
          // 🌟 Updated to include hospital_name
          "hospital_name": hospitalName.text, 
          "hospital_number": hospitalNumber.text,
          "hospital_location": hospitalLocation.text,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Success
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Emergency contacts saved successfully!")),
          );
          setState(() => isEditing = false);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to save: ${response.statusCode}")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
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

              // 🌟 CONSOLIDATED HOSPITAL CARD
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    // Hospital Name
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
                    // Hospital Number
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
                        icon: const Icon(Icons.phone, color: Colors.green, size: 30),
                        onPressed: () {
                          if (hospitalNumber.text.isNotEmpty) {
                            callNumber(hospitalNumber.text);
                          }
                        },
                      ),
                    ),
                    // Hospital Location Link
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
                        icon: const Icon(Icons.map, color: Colors.teal, size: 30),
                        onPressed: () {
                          if (hospitalLocation.text.isNotEmpty) {
                            launchUrl(
                              Uri.parse(hospitalLocation.text),
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

              // SAVE BUTTON (Color updated to 0xFF1A7B7D)
              Visibility(
                visible: isEditing,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A7B7D), // The requested color
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: saveToDatabase,
                    child: const Text("Save", style: TextStyle(color: Colors.white, fontSize: 18)), // White text
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Contact Card Template
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
            leading: const Icon(Icons.call, color: Colors.green, size: 28),
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
              icon: const Icon(Icons.phone, color: Colors.green, size: 30),
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

