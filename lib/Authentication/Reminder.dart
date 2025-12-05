import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:diacare/Authentication/api_config.dart';

// MEDICATION MODEL
class Medication {
  String name;
  TimeOfDay time;

  TextEditingController nameController;

  Medication({
    required this.name,
    required this.time,
  }) : nameController = TextEditingController(text: name);

  void dispose() {
    nameController.dispose();
  }
}

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  State<ReminderPage> createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final List<Medication> medications = [];
  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  @override
  void dispose() {
    for (var med in medications) {
      med.dispose();
    }
    super.dispose();
  }

  // INIT NOTIFICATIONS
  Future<void> _initNotifications() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: androidSettings);

    await notifications.initialize(initSettings);

    // Request notification permission
    await notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'med_channel',
      'Medication Reminders',
      description: 'Daily reminder to take medication',
      importance: Importance.high,
    );

    await notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // TIME PICKER
  Future<TimeOfDay?> _pickTime(BuildContext context, TimeOfDay initial) async {
    return await showTimePicker(
      context: context,
      initialTime: initial,
    );
  }

  // ADD NEW MEDICATION
  void addMedication() {
    setState(() {
      medications.add(
        Medication(name: "", time: TimeOfDay.now()),
      );

      medications.last.nameController.addListener(() {
        medications.last.name = medications.last.nameController.text;
      });
    });
  }

  // SAVE ALL MEDICATIONS
  Future<void> saveMedications() async {
    bool allSavedToDb = true;

    for (var med in medications) {
      if (med.name.trim().isNotEmpty) {
        scheduleNotification(med);

        final success = await _saveReminderToDatabase(med);
        if (!success) allSavedToDb = false;
      }
    }

    if (allSavedToDb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Medication reminders saved successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Some reminders failed to save to the database.")),
      );
    }
  }

  // SAVE REMINDER TO DATABASE (WITH DEBUG PRINT)
  Future<bool> _saveReminderToDatabase(Medication med) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      if (mounted) {
        _showErrorDialog(
            "Authentication Error", "You are not logged in. Please log in again.");
      }
      return false;
    }

    final url = Uri.parse("${ApiConfig.baseUrl}reminders");

    final data = {
      'medicine_name': med.name,
      'time_to_take':
          '${med.time.hour.toString().padLeft(2, '0')}:${med.time.minute.toString().padLeft(2, '0')}',
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );

      // DEBUG PRINTS — SEE EXACT ERROR FROM LARAVEL
      print("======== REMINDER API DEBUG ========");
      print("URL: $url");
      print("SEND DATA: $data");
      print("STATUS CODE: ${response.statusCode}");
      print("RESPONSE BODY: ${response.body}");
      print("====================================");

      if (!mounted) return false;

      return response.statusCode == 201;
    } catch (e) {
      if (mounted) {
        _showErrorDialog(
            "Network Error for ${med.name}", "An unexpected error occurred: $e");
      }
      return false;
    }
  }

  // ERROR DIALOG
  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
              child: const Text('Okay'),
              onPressed: () => Navigator.of(ctx).pop())
        ],
      ),
    );
  }

  // SCHEDULE LOCAL DAILY NOTIFICATION
  Future<void> scheduleNotification(Medication med) async {
    final now = tz.TZDateTime.now(tz.local);

    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      med.time.hour,
      med.time.minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'med_channel',
      'Medication Reminders',
      channelDescription: 'Daily reminder to take medication',
      importance: Importance.high,
      priority: Priority.high,
    );

    final details = NotificationDetails(android: androidDetails);

    await notifications.zonedSchedule(
      med.hashCode,
      'Medication Reminder',
      'Time to take ${med.name}',
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medication Reminder"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: addMedication,
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: medications.isEmpty
                  ? const Center(
                      child: Text("No medications added. Tap + to add."),
                    )
                  : ListView.builder(
                      itemCount: medications.length,
                      itemBuilder: (context, index) {
                        final med = medications[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: TextField(
                              controller: med.nameController,
                              decoration: const InputDecoration(
                                labelText: 'Medicine Name',
                                border: InputBorder.none,
                              ),
                              onChanged: (value) => med.name = value,
                            ),
                            subtitle: Row(
                              children: [
                                const Text("Time: "),
                                TextButton(
                                  onPressed: () async {
                                    final picked =
                                        await _pickTime(context, med.time);
                                    if (picked != null) {
                                      setState(() => med.time = picked);
                                    }
                                  },
                                  child: Text(
                                    med.time.format(context),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                )
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() => medications.removeAt(index));
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: saveMedications,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text(
              "Save Reminders",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
