import 'package:flutter/material.dart';

class BloodSugarPage extends StatefulWidget {
  const BloodSugarPage({super.key});

  @override
  State<BloodSugarPage> createState() => _BloodSugarPageState();
}

class _BloodSugarPageState extends State<BloodSugarPage> {
  final TextEditingController sugarController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  // Dropdown values
  String? measuredAt;
  String? unit;

  // Colors
  final Color bgColor = const Color(0xFFE3F4F4);
  final Color mainColor = const Color(0xFF1A7B7D);

  // Select time
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
        child: Column(
          children: [

            // Blood Sugar Level
            TextField(
              controller: sugarController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Blood Sugar Level",
                prefixIcon: Icon(Icons.favorite),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // Measured At Dropdown
            DropdownButtonFormField(
              value: measuredAt,
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

            // Time Picker
            TextField(
              controller: timeController,
              readOnly: true,
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

            // Unit Dropdown
            DropdownButtonFormField(
              value: unit,
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
                  unit = value.toString();
                });
              },
            ),

            const SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  // SAVE LOGIC HERE
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
     // --------------------------- BOTTOM NAV ---------------------------
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: 3,
      selectedItemColor: const Color(0xFF1A7B7D),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,

      onTap: (index) {
        if (index == 0) Navigator.pushNamed(context, "/home");
         if (index == 1) Navigator.pushNamed(context, "/reminders");
        if (index == 2) Navigator.pushNamed(context, "/emergency");
        if (index == 3) {} // Already on Profile
      },

      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
         BottomNavigationBarItem(icon: Icon(Icons.access_time), label: "Reminder"),
        BottomNavigationBarItem(icon: Icon(Icons.emergency), label: "Emergency"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
      ],
    ),
    );
  }
}
