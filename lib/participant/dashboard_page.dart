import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hacksync/participant/hackathon_detailspage.dart';
import 'package:intl/intl.dart'; 
import 'hackathon_details.dart';
import 'profile_screen.dart';
import 'register.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  String userName = "Participant";
  List<Map<String, dynamic>> hackathons = [];
  List<Map<String, dynamic>> notifications = [];
  bool isLoadingHackathons = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchHackathons();
    _loadMockNotifications();
  }

  Future<void> _fetchUserData() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        setState(() {
          userName = userDoc.data()?['name'] ?? "Participant";
        });
      }
    }
  }

  Future<void> _fetchHackathons() async {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('hackathon').get();
      setState(() {
        hackathons = snapshot.docs.map((doc) => doc.data()).toList();
        isLoadingHackathons = false;
      });
    } catch (e) {
      print('Error fetching hackathons: $e');
      setState(() {
        isLoadingHackathons = false;
      });
    }
  }

  void _loadMockNotifications() {
    setState(() {
      notifications = [
        {
          'title': 'Hackathon Registration Open',
          'message': 'Register now for Hackathon 1!',
          'time': '1h ago',
        },
        {
          'title': 'Reminder: Submission Deadline',
          'message': 'Hackathon 2 submission deadline is tomorrow!',
          'time': '3h ago',
        },
        {
          'title': 'New Hackathon Added',
          'message': 'Hackathon 3 has been announced. Check it out!',
          'time': '6h ago',
        },
      ];
    });
  }

  String formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '';
    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
    return timestamp.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HackSync')),
      body: _selectedIndex == 0 ? _buildDashboardContent() : _navigateToPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          } else {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Hackathons'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Teams'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _navigateToPage(int index) {
    switch (index) {
      case 1:
        return _buildHackathonsPage();
      case 2:
        return const Center(child: Text("Teams Page"));
      default:
        return _buildDashboardContent();
    }
  }

  Widget _buildHackathonsPage() {
    if (isLoadingHackathons) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: hackathons.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(hackathons[index]['name'] ?? ''),
            subtitle: Text(formatTimestamp(hackathons[index]['date'])),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterScreen(hackathonInfo: hackathons[index]),
                  ),
                );
              },
              child: const Text('Register'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 35)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                      Text(userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Upcoming Hackathons', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            isLoadingHackathons
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: hackathons.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.only(right: 16),
                          child: Container(
                            width: 250,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(hackathons[index]['name'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text(formatTimestamp(hackathons[index]['date']), style: TextStyle(color: Colors.grey[600])),
                                const SizedBox(height: 4),
                                Text(hackathons[index]['location'] ?? '', style: const TextStyle(color: Colors.blue)),
                                const Spacer(),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => HackathonDetailsPage(
                                          hackathonData: hackathons[index],
                                          hackathonId: hackathons[index]['id'] ?? '',
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text('More Details'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

            const SizedBox(height: 24),
            const Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active),
                    title: Text(notifications[index]['title'] ?? ''),
                    subtitle: Text(notifications[index]['message'] ?? ''),
                    trailing: Text(notifications[index]['time'] ?? '', style: const TextStyle(color: Colors.blueGrey)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

