import 'package:flutter/material.dart';

class MedicationPage extends StatefulWidget {
  const MedicationPage({super.key});

  @override
  State<MedicationPage> createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  final nameController = TextEditingController();
  final dosageController = TextEditingController();
  final timeController = TextEditingController();
  final notesController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F4F4),

      // Floating add button
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1A7B7D),
        child: const Icon(Icons.add, size: 30),
        onPressed: () {
          // Add another medication logic
        },
      ),

      // Logo + Title + Save Button
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3F4F4),
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Icon(Icons.local_hospital, size: 40, color: Colors.teal[700]),
            const SizedBox(height: 4),
            const Text(
              "Medication",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            const SizedBox(height: 4),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.black),
            onPressed: () {
              // Submit
            },
          )
        ],
      ),
      
 
      // Form Body
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Medicine Name",
                  prefixIcon: Icon(Icons.medication),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: dosageController,
                decoration: const InputDecoration(
                  labelText: "Dosage",
                  prefixIcon: Icon(Icons.line_weight),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: timeController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Time To Take",
                  prefixIcon: Icon(Icons.schedule),
                  border: OutlineInputBorder(),
                ),
                onTap: pickTime,
              ),
              const SizedBox(height: 15),

              TextField(
                controller: notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Notes",
                  prefixIcon: Icon(Icons.note_alt_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.teal[800],
        unselectedItemColor: Colors.grey,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: "reminders"),
          BottomNavigationBarItem(icon: Icon(Icons.emergency), label: "Emergency"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],

        currentIndex: 3, // Active on Profile
        onTap: (index) {
          // Navigation logic here
        },
      ),
    );
  }
}
