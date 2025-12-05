import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diacare/Authentication/api_config.dart';

import 'package:diacare/Authentication/Home.dart';
class BloodPressurePage extends StatefulWidget {
  const BloodPressurePage({super.key});

  @override
  State<BloodPressurePage> createState() => _BloodPressurePageState();
}

class _BloodPressurePageState extends State<BloodPressurePage> {
  // Controllers
  final systolicController = TextEditingController();
  final diastolicController = TextEditingController();
  final heartRateController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Dropdown values
  String? measuredAt;
  String? measurementPosition;
  String? measurementArm;

  // Colors
  final Color bgColor = const Color(0xFFE3F4F4);
  final Color textColor = Colors.black;
  final Color hintColor = Colors.black54;
  final Color mainColor = const Color(0xFF1A7B7D);

  // Time Picker
  Future<void> pickTime() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        timeController.text = picked.format(context);
      });
    }
  }

  // Date Picker
  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        dateController.text = picked.toIso8601String().split('T').first;
      });
    }
  }

  // Save Blood Pressure Data
  Future<void> saveBloodPressure() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please fill all the required fields.")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      if (mounted) {
        _showErrorDialog("Authentication Error", "Please log in again.");
      }
      return;
    }

    final url = Uri.parse("${ApiConfig.baseUrl}blood-pressure");

    final data = {
      "systolic": systolicController.text,
      "diastolic": diastolicController.text,
      "heart_rate": heartRateController.text.isNotEmpty ? heartRateController.text : null,
      "measurement_position": measurementPosition,
      "measurement_arm": measurementArm,
      "measurement_time": measuredAt, // "Morning", "Noon", etc.
      "measured_at": dateController.text,
    };


    try {
      // Use a client that follows redirects to handle 302s properly
      final client = http.Client();
      final request = http.Request('POST', url)
        ..headers.addAll({
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        })
        ..body = jsonEncode(data);

      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      client.close();

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Blood Pressure data saved successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else if (response.statusCode == 422) {
        final errors = jsonDecode(response.body)['errors'] as Map<String, dynamic>;
        String errorMessage = "Please correct the following errors:\n";
        errors.forEach((key, value) {
          errorMessage += "- ${value[0]}\n";
        });
        _showErrorDialog("Validation Failed", errorMessage);
      } else {
        _showErrorDialog(
            "Save Failed", "An unknown error occurred. Status code: ${response.statusCode}\nResponse: ${response.body}");
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
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        centerTitle: true,
        title: const Text(
          "Blood Pressure",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              // Systolic
              TextFormField(
                controller: systolicController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter systolic value';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Systolic (mmHg)",
                  prefixIcon: const Icon(Icons.monitor_heart, color: Color(0xFF1A7B7D)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              // Diastolic
              TextFormField(
                controller: diastolicController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter diastolic value';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Diastolic (mmHg)",
                  prefixIcon: const Icon(Icons.monitor_heart_outlined, color: Color(0xFF1A7B7D)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              // Heart Rate
              TextFormField(
                controller: heartRateController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Heart Rate (bpm)",
                  prefixIcon: const Icon(Icons.favorite, color: Color(0xFF1A7B7D)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              // Measured At
              DropdownButtonFormField(
                value: measuredAt,
                validator: (value) {
                  if (value == null) {
                    return 'Please select when it was measured';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Measured At",
                  prefixIcon: const Icon(Icons.access_time, color: Color(0xFF1A7B7D)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: "Morning", child: Text("Morning")),
                  DropdownMenuItem(value: "Noon", child: Text("Noon")),
                  DropdownMenuItem(value: "Afternoon", child: Text("Afternoon")),
                  DropdownMenuItem(value: "Evening", child: Text("Evening")),
                  DropdownMenuItem(value: "Night", child: Text("Night")),
                ],
                onChanged: (value) {
                  setState(() {
                    measuredAt = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Measurement Time
              TextFormField(
                controller: timeController,
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please pick a time';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Measurement Time",
                  prefixIcon: const Icon(Icons.timer, color: Color(0xFF1A7B7D)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.schedule, color: Color(0xFF1A7B7D)),
                    onPressed: pickTime,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Measurement Date
              TextFormField(
                controller: dateController,
                readOnly: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please pick a date';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Measurement Date",
                  prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF1A7B7D)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.date_range, color: Color(0xFF1A7B7D)),
                    onPressed: pickDate,
                  ),
                ),
              ),
              const SizedBox(height: 20),


              // Unit (fixed mmHg)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black45),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.compress, color: Color(0xFF1A7B7D)),
                    SizedBox(width: 10),
                    Text(
                      "Unit: mmHg",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Measurement Position 
              DropdownButtonFormField(
                value: measurementPosition,
                validator: (value) {
                  if (value == null) {
                    return 'Please select a position';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Measurement Position",
                  prefixIcon: const Icon(Icons.accessibility_new, color: Color(0xFF1A7B7D)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: "Sitting", child: Text("Sitting")),
                  DropdownMenuItem(value: "Standing", child: Text("Standing")),
                  DropdownMenuItem(value: "Lying Down", child: Text("Lying Down")),
                ],
                onChanged: (value) => setState(() => measurementPosition = value),
              ),
              const SizedBox(height: 20),

              // Measurement Arm
              DropdownButtonFormField(
                value: measurementArm,
                validator: (value) {
                  if (value == null) {
                    return 'Please select an arm';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: "Measurement Arm",
                  prefixIcon: const Icon(Icons.pan_tool, color: Color(0xFF1A7B7D)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: "Left Arm", child: Text("Left Arm")),
                  DropdownMenuItem(value: "Right Arm", child: Text("Right Arm")),
                ],
                onChanged: (value) => setState(() => measurementArm = value),
              ),
              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: saveBloodPressure,
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                ),
              )
            ],
          ),
        ),),
    );
  }
}
