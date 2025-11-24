import 'package:flutter/material.dart';
import 'package:diacare/Authentication/Profile.dart';
import 'package:diacare/Authentication/Emergency.dart';
import 'package:diacare/Authentication/Home.dart';
import 'package:diacare/Authentication/Reminder.dart ';
import 'package:diacare/Authentication/Medication.dart ';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;

  final Color bgColor = const Color(0xFFE3F4F4);
  final Color mainColor = const Color(0xFF1A7B7D);

  // final fullNameController = TextEditingController(text: "Shadrack Mutua");
  // final dobController = TextEditingController(text: "2001-05-10");
  // final diabetesTypeController = TextEditingController(text: "Type 2");
  // final ageController = TextEditingController(text: "23");

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
        child: Center(
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

              buildTextField("Full Name",TextEditingController() ),
              const SizedBox(height: 20),

              buildTextField("Date of Birth" ,TextEditingController()),
              const SizedBox(height: 20),

              buildTextField("Diabetes Type" ,TextEditingController()),
              const SizedBox(height: 20),

              buildTextField("Age" ,TextEditingController()),
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
                      onPressed: () {},
                      child: const Text("Save", style: TextStyle(color: Colors.white)),
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
                      onPressed: () {},
                      child: const Text("Logout", style: TextStyle(color: Colors.white)),
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
      child: TextField(
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
