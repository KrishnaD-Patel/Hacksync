import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'create_hackathon.dart';

class OrganizerDashboardPage extends StatefulWidget {
  const OrganizerDashboardPage({super.key});

  @override
  State<OrganizerDashboardPage> createState() => _OrganizerDashboardPageState();
}

class _OrganizerDashboardPageState extends State<OrganizerDashboardPage> {
  String organizerName = "";
  List<Map<String, dynamic>> hackathons = [];
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchOrganizerData();
    _fetchHackathons();
    _fetchRecentRegistrations();
  }

  Future<void> _fetchOrganizerData() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        setState(() {
          organizerName = userDoc.data()?['name'] ?? "Organizer";
        });
      }
    }
  }

  Future<void> _fetchHackathons() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      var snapshot = await FirebaseFirestore.instance
          .collection('hackathon')
          .where('organizerId', isEqualTo: userId)
          .get();

      setState(() {
        hackathons = snapshot.docs.map((doc) {
          var data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    }
  }

  Future<void> _fetchRecentRegistrations() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    var hackathonsSnapshot = await FirebaseFirestore.instance
        .collection('hackathon')
        .where('organizerId', isEqualTo: userId)
        .get();

    List<String> hackathonIds = hackathonsSnapshot.docs.map((doc) => doc.id).toList();
    List<Map<String, dynamic>> recentRegs = [];

    for (String hackathonId in hackathonIds) {
      var regSnapshot = await FirebaseFirestore.instance
          .collection('registrations')
          .where('hackathonId', isEqualTo: hackathonId)
          .get();

      for (var doc in regSnapshot.docs) {
        var data = doc.data();

        String hackathonName = 'Hackathon';
        var matchingHackathon = hackathonsSnapshot.docs.where((h) => h.id == hackathonId).toList();
        if (matchingHackathon.isNotEmpty) {
          hackathonName = matchingHackathon.first.data()['name'] ?? 'Hackathon';
        }

        recentRegs.add({
          'title': data['userName'] ?? 'New Registration',
          'message': 'Registered for $hackathonName',
          'time': (data['timestamp'] as Timestamp?)?.toDate().toString().split('.')[0] ?? '',
        });
      }
    }

    setState(() {
      notifications = recentRegs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HackSync Organizer')),
      body: _buildDashboardContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Teams'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Create'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
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
                color: Colors.orangeAccent.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 35)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back',
                          style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                      Text(organizerName,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('My Hackathons',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: hackathons.length + 1,
                itemBuilder: (context, index) {
                  if (index < hackathons.length) {
                    var hack = hackathons[index];
                    return GestureDetector(
                      onTap: () {
                      },
                      child: Container(
                        width: 200,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              hack['name'] ?? 'Hackathon',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              hack['date'] != null
                                  ? DateFormat('dd MMM yyyy').format(
                                      (hack['date'] as Timestamp).toDate())
                                  : '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () {
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(30),
                                backgroundColor: Colors.lightBlue,
                              ),
                              child: const Text('More Details', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateHackathonScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(Icons.add, size: 32, color: Colors.deepPurple),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
