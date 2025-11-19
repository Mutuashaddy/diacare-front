import 'package:flutter/material.dart';

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

  // List of posts
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
                        // TOPIC
                        Text(
                          post["topic"],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // MESSAGE
                        Text(
                          post["message"],
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 12),

                        // LIKE + REPLY BUTTONS
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

                        // REPLIES SECTION
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

  
  // CREATE POST POPUP
  
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
              // TOPIC DROPDOWN
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

              // MESSAGE FIELD
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

  
  // REPLY POPUP
  
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
