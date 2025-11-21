import 'package:flutter/material.dart';

void main() {
  runApp(const HealthAppClone());
}

class HealthAppClone extends StatelessWidget {
  const HealthAppClone({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DiaCare Clone',
      theme: ThemeData(
        // Set up the dark theme based on the screenshots
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black, // Dark background
        cardColor: const Color(0xFF1E1E1E), // Slightly lighter dark card background
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        fontFamily: 'Roboto', // Use a standard font
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine the size of the screen for responsive design
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 1. Top Greeting/Header Section ---
            _buildHeaderSection(screenWidth),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // --- 2. Blood Sugar Card ---
                  _buildHealthCard(
                    title: 'Blood Sugar',
                    icon: Icons.upload_file, // Using a generic upload icon for the red symbol
                    iconColor: Colors.red,
                    normalRange: '70 - 99 mg/dL or 4.4 - 7.0 mmol/L',
                    context: context,
                  ),
                  
                  const SizedBox(height: 20),

                  // --- 3. Blood Pressure Card ---
                  _buildHealthCard(
                    title: 'Blood Pressure',
                    icon: Icons.medical_services_outlined, // Using a generic medical icon for the blue symbol
                    iconColor: Colors.blue,
                    normalRange: 'Normal: 90/60 - 120/80 mmHg',
                    context: context,
                  ),

                  const SizedBox(height: 20),

                  // --- 4. Your Meds Card ---
                  _buildMedsCard(context),
                  
                  const SizedBox(height: 100), // Add padding for the bottom navigation area
                ],
              ),
            ),
          ],
        ),
      ),
      // --- 5. Bottom Navigation Bar ---
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // --- Widget Builders ---

  Widget _buildHeaderSection(double screenWidth) {
    return Container(
      width: screenWidth,
      padding: EdgeInsets.only(
        top: MediaQueryData.fromView(WidgetsBinding.instance.window).padding.top + 10,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      // Gradient background from the screenshots
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF007F), Color(0xFF8B00FF)], // Pink/Fuchsia to Violet/Indigo
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'How are you feeling today?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "See what's trending today!",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              // Action for Go to Community
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              minimumSize: const Size(180, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 5,
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

  Widget _buildHealthCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String normalRange,
    required BuildContext context,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                ),
              ],
            ),
            const Divider(color: Colors.white10, height: 20),
            Center(
              child: Text(
                'Normal:',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ),
            Center(
              child: Text(
                normalRange,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                    ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey.shade800,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('View Report'),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey.shade800,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('View All Logs'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedsCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.medication_liquid_outlined, color: Colors.blue, size: 24), // Placeholder for blue icon
                const SizedBox(width: 8),
                Text(
                  'Your Meds',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20),
                ),
              ],
            ),
            const Divider(color: Colors.white10, height: 20),
            
            // Medication List
            _buildMedicationRow(
              name: 'Metformin',
              details: '- 1 x 2',
              iconColor: Colors.green, // Green Icon from screenshot
            ),
            _buildMedicationRow(
              name: 'Insulin',
              details: '- 1 unit',
              iconColor: Colors.red, // Red Icon from screenshot
            ),
            
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey.shade800,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('View Report'),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey.shade800,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('View All Medications'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationRow({
    required String name,
    required String details,
    required Color iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.circle, color: iconColor, size: 10), // Small colored dot/icon
          const SizedBox(width: 10),
          Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 5),
          Text(
            details,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.black, // Dark background
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.access_time),
          label: 'reminders',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_hospital),
          label: 'Emergency',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      currentIndex: 0,
      onTap: (index) {
        // Handle navigation taps
      },
    );
  }
}