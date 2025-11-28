import 'package:flutter/material.dart';

class MedicationPage extends StatefulWidget {
  const MedicationPage({super.key});

  @override
  State<MedicationPage> createState() => _MedicationPageState();
}

class _MedicationPageState extends State<MedicationPage> {
  final nameController = TextEditingController();
  final dosageController = TextEditingController();
  final notesController = TextEditingController();

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
            child: Padding(
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
                onPressed: () {},
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


