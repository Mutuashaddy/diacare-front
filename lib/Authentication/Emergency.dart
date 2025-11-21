import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyPage extends StatefulWidget {
  const EmergencyPage({super.key});

  @override
  State<EmergencyPage> createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  bool isEditing = false;

  // Text controllers
  TextEditingController caregiverName = TextEditingController();
  TextEditingController caregiverNumber = TextEditingController();

  TextEditingController doctorName = TextEditingController();
  TextEditingController doctorNumber = TextEditingController();

  TextEditingController hospitalName = TextEditingController();
  TextEditingController hospitalNumber = TextEditingController();
  TextEditingController hospitalLocation = TextEditingController();

  // Call Method
  Future<void> callNumber(String number) async {
    final Uri uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
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

              // CAREGIVER
              buildCard(
                icon: Icons.person,
                title: "Caregiver",
                nameController: caregiverName,
                numberController: caregiverNumber,
              ),

              const SizedBox(height: 15),

              // DOCTOR
              buildCard(
                icon: Icons.local_hospital,
                title: "Doctor",
                nameController: doctorName,
                numberController: doctorNumber,
              ),

              const SizedBox(height: 15),

              // HOSPITAL NUMBER
              buildCard(
                icon: Icons.phone_in_talk,
                title: "Hospital Number",
                nameController: hospitalName,
                numberController: hospitalNumber,
              ),

              const SizedBox(height: 15),

              // name HOSPITAL LOCATION
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.local_hospital, color: Colors.teal, size: 30),
                  title: TextField(
                    controller: hospitalName,
                    enabled: isEditing,
                    decoration: const InputDecoration(
                      labelText: "Hospital Name",
                      border: InputBorder.none,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.map, color: Colors.teal, size: 30),
                    onPressed: () {
                      if (hospitalLocation.text.isNotEmpty) {
                        launchUrl(
                          Uri.parse(hospitalName.text),
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // SAVE BUTTON
              Visibility(
                visible: isEditing,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal[700],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      setState(() => isEditing = false);
                    },
                    child: const Text("Save", style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.teal[800],
        unselectedItemColor: Colors.grey,
        currentIndex: 2,

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: "reminders"),
          BottomNavigationBarItem(icon: Icon(Icons.emergency), label: "Emergency"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // Reusable card builder
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
              enabled: isEditing,
              decoration: InputDecoration(
                labelText: "$title Name",
                border: InputBorder.none,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.call, color: Colors.green, size: 28),
            title: TextField(
              controller: numberController,
              enabled: isEditing,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "$title Number",
                border: InputBorder.none,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.phone, color: Colors.green, size: 30),
              onPressed: () {
                if (!isEditing && numberController.text.isNotEmpty) {
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
