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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _showErrorDialog("Authentication Error", "Please log in again.");
      return;
    }

    final url = Uri.parse("${ApiConfig.baseUrl}blood-pressure");

   final data = {
  "systolic": int.parse(systolicController.text),
  "diastolic": int.parse(diastolicController.text),
  "heart_rate": int.tryParse(heartRateController.text),
  "measurement_position": measurementPosition,
  "measurement_arm": measurementArm,
  "measurement_time": measuredAt,   // Morning / Noon / Evening...
  "measured_at": "${dateController.text} ${timeController.text}",
};


    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );

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
      } else {
        _showErrorDialog("Error", "Failed to save data: ${response.body}");
      }
    } catch (e) {
      _showErrorDialog("Network Error", "An error occurred: $e");
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

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Systolic
              TextField(
                controller: systolicController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: "Systolic (mmHg)",
                  prefixIcon: const Icon(Icons.monitor_heart, color: Color(0xFF1A7B7D)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              // Diastolic
              TextField(
                controller: diastolicController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: "Diastolic (mmHg)",
                  prefixIcon: const Icon(Icons.monitor_heart_outlined, color: Color(0xFF1A7B7D)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              // Heart Rate
              TextField(
                controller: heartRateController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
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
              TextField(
                controller: timeController,
                readOnly: true,
                textAlign: TextAlign.center,
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
              TextField(
                controller: dateController,
                readOnly: true,
                textAlign: TextAlign.center,
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
                  onPressed: () {
                    saveBloodPressure();
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                ),
              )
            ],
          ),
        ),
      
    ),
    
 
    );
  }
}
