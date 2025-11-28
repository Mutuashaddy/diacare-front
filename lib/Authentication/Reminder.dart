import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Medication {
  String name;
  TimeOfDay time;
  Medication({required this.name, required this.time});
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

  
  //fuction to push notification
  
  Future<void> _initNotifications() async {
    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await notifications.initialize(initSettings);

    //Request permissions 
    await notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    
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
  
  Future<TimeOfDay?> _pickTime(
      BuildContext context, TimeOfDay initial) async {
    return await showTimePicker(
      context: context,
      initialTime: initial,
    );
  }

  //ADD NEW MEDICATION
  
  void addMedication() {
    setState(() {
      medications.add(
        Medication(name: "", time: TimeOfDay.now()),
      );
    });
  }

  
  //SAVE MEDICATIONS
  void saveMedications() {
    for (var med in medications) {
      if (med.name.trim().isNotEmpty) {
        scheduleNotification(med);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Medication reminders saved!")),
    );
  }

  
  // SCHEDULE NOTIFICATION (DAILY)
 
  Future<void> scheduleNotification(Medication med) async {
    final now = tz.TZDateTime.now(tz.local);

    //Create today's scheduled time
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      med.time.hour,
      med.time.minute,
    );

    // If time already passed today → schedule for tomorrow
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
                          ),
                        );
                      },
                    ),
            ),

            // SAVE BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: saveMedications,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size.fromHeight(50),
                ),
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  "Save Reminders",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}


