import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diacare/Authentication/api_config.dart';
import 'package:diacare/Authentication/Home.dart';


class MedicationPage extends StatefulWidget {
  const MedicationPage({super.key});

  @override
  State<MedicationPage> createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  final nameController = TextEditingController();
  final dosageController = TextEditingController();
  final notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) {
      return; // Validation failed
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      if (mounted) {
        _showErrorDialog("Authentication Error", "You are not logged in. Please log in again.");
      }
      return;
    }

    final url = Uri.parse("${ApiConfig.baseUrl}medications");

    final data = {
      'medicine_name': nameController.text,
      'dosage': dosageController.text,
      'notes': notesController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );

      if (!mounted) return;

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Medication saved successfully!"), backgroundColor: Colors.green),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        _showErrorDialog("Save Failed", "An error occurred: ${response.body}");
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog("Error", "An unexpected error occurred: $e");
      }
    }
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(child: const Text('Okay'), onPressed: () => Navigator.of(ctx).pop())
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F4F4),

      // Move floating button upward slightly
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70), // so it stays above Save button
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF1A7B7D),
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () {},
        ),
      ),

      // Clean AppBar
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3F4F4),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Medication",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Body + save button
      body: Column(
        children: [
          Expanded(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the medicine name';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: "Medicine Name",
                          prefixIcon: Icon(Icons.medication),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: dosageController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the dosage';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: "Dosage",
                          prefixIcon: Icon(Icons.line_weight),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: "Notes (Optional)",
                          prefixIcon: Icon(Icons.note_alt_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Bottom Save button (smaller now)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: SizedBox(
              height: 48, // smaller size
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A7B7D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _saveMedication,
                child: const Text(
                  "SAVE",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
