import 'package:flutter/material.dart';
import 'package:diacare/Authentication/BloodPressure.dart';
import 'package:diacare/Authentication/PostPage.dart';
import 'package:diacare/Authentication/BloodSugar.dart';
import 'package:diacare/Authentication/Profile.dart';
import 'package:diacare/Authentication/Medication.dart';
import 'package:diacare/Authentication/Emergency.dart';
import 'package:diacare/Authentication/Home.dart';
import 'package:diacare/Authentication/Reminder.dart';
import 'package:diacare/Authentication/ViewBloodPressure.dart';
import 'package:diacare/Authentication/ViewBloodSugar.dart';
import 'package:diacare/Authentication/ViewMedication.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _homePage(context),
      const MedicationPage(),
      const EmergencyPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE3F4F4),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1A7B7D),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.access_time), label: "Reminders"),
          BottomNavigationBarItem(icon: Icon(Icons.local_hospital), label: "Emergency"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  // HOME PAGE
  Widget _homePage(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeaderSection(screenWidth),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // BLOOD SUGAR CARD
                _buildHealthCard(
                  title: 'Blood Sugar',
                  icon: Icons.bloodtype,
                  iconColor: Colors.red,
                  normalRange: '70 - 99 mg/dL or 4.4 - 7.0 mmol/L',
                  context: context,
                  onReport: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BloodSugarPage()),
                    );
                  },
                  onViewLogs: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BloodSugarPage()),//view page
                    );
                  },
                ),

                const SizedBox(height: 20),

                // BLOOD PRESSURE CARD
                _buildHealthCard(
                  title: 'Blood Pressure',
                  icon: Icons.monitor_heart,
                  iconColor: Colors.blue,
                  normalRange: 'Normal: 90/60 - 120/80 mmHg',
                  context: context,
                  onReport: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BloodPressurePage()),
                    );
                  },
                  onViewLogs: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const BloodPressurePage()), //view page
                    );
                  },
                ),

                const SizedBox(height: 20),

                _buildMedsCard(context),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // HEADER SECTION
  Widget _buildHeaderSection(double screenWidth) {
    return Container(
      width: screenWidth,
      padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1A7B7D),
            Color(0xFF125E5F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Text(
            'How are you feeling today?',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          const SizedBox(height: 5),
          const Text(
            "See what's trending today!",
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 15),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PostPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1A7B7D),
              minimumSize: const Size(180, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Go to Community',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // HEALTH CARD
  Widget _buildHealthCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String normalRange,
    required BuildContext context,
    required VoidCallback onReport,
    required VoidCallback onViewLogs,
  }) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),

            const Divider(color: Colors.black26),

            Center(
              child: Text('Normal:',
                  style: TextStyle(color: Colors.grey.shade700)),
            ),

            Center(
              child: Text(
                normalRange,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A7B7D),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: onReport,
                    child: const Text("Add"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A7B7D),
                      foregroundColor: Colors.white),
                    onPressed: onViewLogs,   // FIXED
                    child: const Text("View All Logs"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // MEDICATION CARD
  Widget _buildMedsCard(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.medication_liquid_outlined,
                    color: Color(0xFF1A7B7D), size: 24),
                SizedBox(width: 8),
                Text(
                  'Your Meds',
                  style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const Divider(color: Colors.black26),

            _buildMedicationRow("Metformin", "- 1 x 2", Colors.green),
            _buildMedicationRow("Insulin", "- 1 unit", Colors.red),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A7B7D),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MedicationPage()),
                      );
                    },
                    child: const Text("Add"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A7B7D),
                        foregroundColor: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MedicationPage()),//view page
                      );
                    },
                    child: const Text("View All Medications"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationRow(String name, String details, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.circle, color: color, size: 10),
          const SizedBox(width: 10),
          Text(name, style: const TextStyle(color: Colors.black, fontSize: 18)),
          const SizedBox(width: 6),
          Text(details, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
