import 'package:flutter/material.dart';
import 'package:diacare/Authentication/Profile.dart';
import 'package:diacare/Authentication/Emergency.dart';
import 'package:diacare/Authentication/Home.dart';
import 'package:diacare/Authentication/Reminder.dart ';
import 'package:diacare/Authentication/Medication.dart ';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  // Topic list for dropdown
  final List<String> topicsList = [
    "Never Give Up",
    "Healthy Lifestyle",
    "Food & Nutrition",
    "Motivation",
    "Discipline",
    "Mental Strength",
    "Positive Habits",
    "Life Improvement",
    "Fitness & Wellness",
  ];

  String? selectedTopic;
  final TextEditingController messageController = TextEditingController();

  // list to hold posts
  List<Map<String, dynamic>> posts = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       centerTitle: true,
        title: const Text("Community Posts"),
        backgroundColor: Colors.teal,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
        onPressed: () {
          _showCreatePostDialog(context);
        },
      ),
      body: posts.isEmpty
          ? const Center(
              child: Text(
                "No posts yet.\nTap + to create one!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];

                return Card(
                  margin: const EdgeInsets.all(12),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // topic
                        Text(
                          post["topic"],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // message
                        Text(
                          post["message"],
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 12),

                        // like and reply buttons
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.thumb_up_alt_outlined),
                              onPressed: () {
                                setState(() {
                                  post["likes"]++;
                                });
                              },
                            ),
                            Text(post["likes"].toString()),

                            const SizedBox(width: 20),

                            IconButton(
                              icon: const Icon(Icons.comment_outlined),
                              onPressed: () {
                                _showReplyDialog(context, index);
                              },
                            ),
                            Text(post["replies"].length.toString()),
                          ],
                        ),

                        // reply section
                        if (post["replies"].isNotEmpty) ...[
                          const Divider(),
                          const Text(
                            "Replies:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          ...post["replies"].map<Widget>((reply) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text("- $reply"),
                            );
                          })
                        ]
                      ],
                    ),
                  ),
                );
              },
            
            ),
    
    );
  }

  
  // create post popup
  
  void _showCreatePostDialog(BuildContext context) {
    selectedTopic = null;
    messageController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create Post"),
        content: SizedBox(
          height: 220,
          child: Column(
            children: [
              // topic dropdown
              DropdownButtonFormField<String>(
                value: selectedTopic,
                decoration: const InputDecoration(
                  labelText: "Select Topic",
                  border: OutlineInputBorder(),
                ),
                items: topicsList.map((topic) {
                  return DropdownMenuItem(
                    value: topic,
                    child: Text(topic),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedTopic = value;
                  });
                },
              ),
              const SizedBox(height: 15),

              // message textfield
              TextField(
                controller: messageController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Message",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text("Post"),
            onPressed: () {
              if (selectedTopic == null ||
                  messageController.text.trim().isEmpty) return;

              setState(() {
                posts.insert(0, {
                  "topic": selectedTopic!,
                  "message": messageController.text.trim(),
                  "likes": 0,
                  "replies": [],
                });
              });

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  
  //reply popup
  
  void _showReplyDialog(BuildContext context, int postIndex) {
    final replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reply"),
        content: TextField(
          controller: replyController,
          decoration: const InputDecoration(
            labelText: "Write a reply...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text("Send"),
            onPressed: () {
              if (replyController.text.trim().isEmpty) return;

              setState(() {
                posts[postIndex]["replies"].add(replyController.text.trim());
              });

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
// //  BOTTOM NAVIGATION BAR 
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: 3,
//        selectedItemColor: const Color(0xFF1A7B7D),
//         unselectedItemColor: Colors.grey,
//         type: BottomNavigationBarType.fixed,

//         onTap: (index) {
//           if (index == 0) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => const HomeScreen()),
//             );
//           }
//           if (index == 1) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => const MedicationPage()),
//             );
//           }
//           if (index == 2) {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (_) => const EmergencyPage()),
//             );
//           }
//           if (index == 3) {
//             // Already on profile
//           }
//         },

//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//           BottomNavigationBarItem(icon: Icon(Icons.access_time), label: "Reminder"),
//           BottomNavigationBarItem(icon: Icon(Icons.emergency), label: "Emergency"),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
//         ],
//       ),