import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


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

  // Dropdown values
  String? selectedGender;
  String? selectedDiabetesType;

  // Dropdown options
  final genderList = ["Male", "Female", "Other"];
  final diabetesTypes = ["Type 1", "Type 2", "Gestational", "Prediabetes"];

  // Pick DOB
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

        // Auto-calc age
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

 @override
Widget build(BuildContext context) {
  int _currentIndex = 3; // Profile active

  return Scaffold(
    backgroundColor: const Color(0xFFE3F4F4),

    appBar: AppBar(
      backgroundColor: const Color(0xFF1A7B7D),
      centerTitle: true,
      title: const Text(
        "BioData",
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.edit, color: Colors.white),
        ),
      ],
    ),

    body: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(
            controller: fullNameController,
            decoration: InputDecoration(
              labelText: "Full Name",
              prefixIcon: const Icon(Icons.person, color: Color(0xFF1A7B7D)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 15),

          TextField(
            controller: dobController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: "Date of Birth",
              prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF1A7B7D)),
              suffixIcon: IconButton(
                icon: const Icon(Icons.date_range, color: Color(0xFF1A7B7D)),
                onPressed: () => pickDate(context),
              ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 15),

          TextField(
            controller: ageController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: "Age",
              prefixIcon: const Icon(Icons.timelapse, color: Color(0xFF1A7B7D)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black45),
            ),
            child: DropdownButtonFormField<String>(
              value: selectedGender,
              decoration: const InputDecoration(
                border: InputBorder.none,
                icon: Icon(Icons.wc, color: Color(0xFF1A7B7D)),
                labelText: "Gender",
              ),
              items: genderList.map((gender) {
                return DropdownMenuItem(
                  value: gender,
                  child: Text(gender),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedGender = value);
              },
            ),
          ),
          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black45),
            ),
            child: DropdownButtonFormField<String>(
              value: selectedDiabetesType,
              decoration: const InputDecoration(
                border: InputBorder.none,
                icon: Icon(Icons.medical_services, color: Color(0xFF1A7B7D)),
                labelText: "Diabetes Type",
              ),
              items: diabetesTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedDiabetesType = value);
              },
            ),
          ),
          const SizedBox(height: 15),

          TextField(
            controller: emergencyContactController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: "Emergency Contact",
              prefixIcon: const Icon(Icons.phone_android, color: Color(0xFF1A7B7D)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 15),

          TextField(
            controller: doctorNumberController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: "Doctor’s Number",
              prefixIcon: const Icon(Icons.local_hospital, color: Color(0xFF1A7B7D)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A7B7D),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {},
              child: const Text(
                "Save BioData",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    ),

    
  );
}
}
