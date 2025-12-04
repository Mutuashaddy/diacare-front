import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:diacare/Authentication/api_config.dart';
import 'package:diacare/Authentication/Emergency.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BioData extends StatefulWidget {
  const BioData({super.key});

  @override
  State<BioData> createState() => _BioDataState();
}

class _BioDataState extends State<BioData> {
  // Controllers
  final fullNameController = TextEditingController();
  final dobController = TextEditingController();
  final ageController = TextEditingController();
  final emergencyContactController = TextEditingController();
  final doctorNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  String? selectedGender;
  String? selectedDiabetesType;

  final genderList = ["Male", "Female", "Other"];
  final diabetesTypes = ["Type 1", "Type 2", "Gestational", "Prediabetes"];

  Future<void> pickDate(BuildContext context) async {
    DateTime? datePicked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (datePicked != null) {
      String formattedDate = DateFormat("yyyy-MM-dd").format(datePicked);

      setState(() {
        dobController.text = formattedDate;

        final today = DateTime.now();
        int age = today.year - datePicked.year;

        if (today.month < datePicked.month ||
            (today.month == datePicked.month && today.day < datePicked.day)) {
          age--;
        }

        ageController.text = age.toString();
      });
    }
  }

  Future<void> saveBioData() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields.")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      setState(() => isLoading = false);
      return;
    }

    final url = Uri.parse("${ApiConfig.baseUrl}bio-data");

    final data = {
      "full_name": fullNameController.text,
      "dob": dobController.text,
      "age": ageController.text,
      "gender": selectedGender,
      "diabetes_type": selectedDiabetesType,
      "emergency_contact": emergencyContactController.text,
      "doctor_number": doctorNumberController.text,
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
            content: Text("BioData saved successfully!"),
            backgroundColor: Colors.green,
          ),
        );

        await prefs.setBool("bioDataFilled", true);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EmergencyPage()),
        );
      } else if (response.statusCode == 422) {
        final errors = jsonDecode(response.body)['errors'];
        String msg = "Fix the following:\n";
        errors.forEach((k, v) {
          msg += "- ${v[0]}\n";
        });
        _showErrorDialog("Validation Failed", msg);
      } else {
        _showErrorDialog(
          "Error",
          "Unknown error occurred. Status: ${response.statusCode}",
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A7B7D),
        title: const Text("BioData", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: fullNameController,
                validator: (v) => v!.isEmpty ? "Enter your full name" : null,
                decoration: _input("Full Name", Icons.person),
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: dobController,
                readOnly: true,
                validator: (v) => v!.isEmpty ? "Select your DOB" : null,
                decoration: _input("Date of Birth", Icons.calendar_today,
                    suffix: Icons.date_range,
                    onSuffixTap: () => pickDate(context)),
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: ageController,
                readOnly: true,
                decoration: _input("Age", Icons.timelapse),
              ),
              const SizedBox(height: 15),

              DropdownButtonFormField(
                value: selectedGender,
                validator: (v) => v == null ? "Select gender" : null,
                decoration: _input("Gender", Icons.wc),
                items: genderList
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => selectedGender = v),
              ),
              const SizedBox(height: 15),

              DropdownButtonFormField(
                value: selectedDiabetesType,
                validator: (v) => v == null ? "Select diabetes type" : null,
                decoration: _input("Diabetes Type", Icons.medical_services),
                items: diabetesTypes
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => selectedDiabetesType = v),
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: emergencyContactController,
                validator: (v) => v!.isEmpty ? "Enter emergency contact" : null,
                keyboardType: TextInputType.phone,
                decoration: _input("Emergency Contact", Icons.phone_android),
              ),
              const SizedBox(height: 15),

              TextFormField(
                controller: doctorNumberController,
                keyboardType: TextInputType.phone,
                decoration:
                    _input("Doctor's Number (Optional)", Icons.local_hospital),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A7B7D),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isLoading ? null : saveBioData,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save BioData",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _input(String label, IconData icon,
      {IconData? suffix, VoidCallback? onSuffixTap}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Color(0xFF1A7B7D)),
      suffixIcon: suffix != null
          ? IconButton(
              onPressed: onSuffixTap,
              icon: Icon(suffix, color: Color(0xFF1A7B7D)),
            )
          : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
