import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  // Method to make calls
  Future<void> callNumber(String number) async {
    final Uri uri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $number';
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
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Caregiver
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.teal, size: 30),
                title: const Text("Caregiver"),
                subtitle: const Text("0723456789"),
                trailing: IconButton(
                  icon: const Icon(Icons.call, color: Colors.green, size: 30),
                  onPressed: () => callNumber("0723456789"),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Doctor
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.local_hospital, color: Colors.red, size: 30),
                title: const Text("Doctor"),
                subtitle: const Text("0799123456"),
                trailing: IconButton(
                  icon: const Icon(Icons.call, color: Colors.green, size: 30),
                  onPressed: () => callNumber("0799123456"),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Hospital Number
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.phone_in_talk, color: Colors.blue, size: 30),
                title: const Text("Hospital Number"),
                subtitle: const Text("0744001122"),
                trailing: IconButton(
                  icon: const Icon(Icons.call, color: Colors.green, size: 30),
                  onPressed: () => callNumber("0744001122"),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Hospital Name + Location
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.location_on, color: Colors.deepPurple, size: 30),
                title: const Text("Hospital Name"),
                subtitle: const Text("Nairobi West Hospital"),
                trailing: IconButton(
                  icon: const Icon(Icons.map, color: Colors.teal, size: 30),
                  onPressed: () {
                    launchUrl(
                      Uri.parse("https://maps.google.com/?q=Nairobi+West+Hospital"),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.teal[800],
        unselectedItemColor: Colors.grey,

        currentIndex: 2, // Emergency active

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Community"),
          BottomNavigationBarItem(icon: Icon(Icons.emergency), label: "Emergency"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
