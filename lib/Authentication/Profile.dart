import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;

  final Color bgColor = const Color(0xFFE3F4F4);
  final Color mainColor = const Color(0xFF1A7B7D);

  // Controllers
  final fullNameController = TextEditingController(text: "Shadrack Mutua");
  final dobController = TextEditingController(text: "2001-05-10");
  final diabetesTypeController = TextEditingController(text: "Type 2");
  final ageController = TextEditingController(text: "23");

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

      // BODY
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
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

              // TITLE
              Text(
                "My Profile",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                ),
              ),

              const SizedBox(height: 30),

              buildTextField("Full Name", fullNameController),
              const SizedBox(height: 20),

              buildTextField("Date of Birth", dobController),
              const SizedBox(height: 20),

              buildTextField("Diabetes Type", diabetesTypeController),
              const SizedBox(height: 20),

              buildTextField("Age", ageController),
              const SizedBox(height: 70),
            ],
          ),
        ),
      ),

      // SAVE + LOGOUT BUTTONS
      bottomNavigationBar: SizedBox(
        height: 140,
        child: Column(
          children: [
            // BUTTON ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // SAVE BUTTON
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

                // LOGOUT BUTTON
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

            const SizedBox(height: 10),

             // --------------------------- BOTTOM NAV ---------------------------
     BottomNavigationBar(
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
          ],
        ),
      ),
    );
  }

  // TEXT FIELD WIDGET
  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextField(
        controller: controller,
        enabled: isEditing,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // NAV ICON
  Widget navItem(IconData icon, String label, {bool isActive = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0xFF1A7B7D) : Colors.grey,
        ),
        Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF1A7B7D) : Colors.grey,
            fontSize: 12,
          ),
        )
      ],
    );
  }
}
