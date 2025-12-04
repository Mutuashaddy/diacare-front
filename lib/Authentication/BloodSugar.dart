import 'package:flutter/material.dart';
import 'package:diacare/Authentication/Home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diacare/Authentication/api_config.dart';

class BloodSugarPage extends StatefulWidget {
  const BloodSugarPage({super.key});

  @override
  State<BloodSugarPage> createState() => _BloodSugarPageState();
}

class _BloodSugarPageState extends State<BloodSugarPage> {
  final TextEditingController sugarController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? measuredAt;
  String? selectedUnit;

  final Color bgColor = const Color(0xFFE3F4F4);
  final Color mainColor = const Color(0xFF1A7B7D);

  // Pick measurement time
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

  // Save Blood Sugar Data
  Future<void> saveBloodSugarData() async {
    if (!_formKey.currentState!.validate() ||
        measuredAt == null ||
        selectedUnit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields.")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Authentication error. Please log in again.")),
        );
      }
      return;
    }

    final url = Uri.parse("${ApiConfig.baseUrl}blood-sugar");

    final data = {
      "sugar_level": sugarController.text,
      "measured_at": measuredAt,
      "measurement_time": timeController.text,
      "unit": selectedUnit,
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

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Blood sugar data saved successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
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
            "Save Failed", "An unknown error occurred. Status code: ${response.statusCode}");
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
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: mainColor,
        centerTitle: true,
        title: const Text(
          "Blood Sugar",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: sugarController,
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? "Please enter blood sugar level" : null,
                decoration: const InputDecoration(
                  labelText: "Blood Sugar Level",
                  prefixIcon: Icon(Icons.favorite),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField(
                value: measuredAt,
                validator: (value) =>
                    value == null ? "Please select when it was measured" : null,
                decoration: const InputDecoration(
                  labelText: "Measured At",
                  prefixIcon: Icon(Icons.access_time),
                  border: OutlineInputBorder(),
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
                    measuredAt = value.toString();
                  });
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: timeController,
                readOnly: true,
                validator: (value) =>
                    value!.isEmpty ? "Please pick a time" : null,
                decoration: InputDecoration(
                  labelText: "Measurement Time",
                  prefixIcon: const Icon(Icons.timer),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: pickTime,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField(
                value: selectedUnit,
                validator: (value) =>
                    value == null ? "Please select a unit" : null,
                decoration: const InputDecoration(
                  labelText: "Unit",
                  prefixIcon: Icon(Icons.scale),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "mmol/L", child: Text("mmol/L")),
                  DropdownMenuItem(value: "mg/dL", child: Text("mg/dL")),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedUnit = value.toString();
                  });
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mainColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: saveBloodSugarData, // <- Call save function here
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
