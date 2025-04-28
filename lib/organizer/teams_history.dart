import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart' as intl;
import 'teams_list.dart'; // Team list screen after clicking hackathon

class OrganizerHackathonsScreen extends StatefulWidget {
  const OrganizerHackathonsScreen({Key? key}) : super(key: key);

  @override
  _OrganizerHackathonsScreenState createState() => _OrganizerHackathonsScreenState();
}

class _OrganizerHackathonsScreenState extends State<OrganizerHackathonsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _formatDate(Timestamp timestamp) {
    return intl.DateFormat('dd MMM yyyy').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;
    if (user == null) {
      return Scaffold(
        body: const Center(child: Text("Please login to view your hackathons.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Hackathons"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection("hackathon") // <-- Your collection is named "hackathon", not "hackathons"
            .where("organizerId", isEqualTo: user.uid)
            .orderBy("date", descending: false) // upcoming hackathons first
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No hackathons created yet."));
          }

          final hackathons = snapshot.data!.docs;

          return ListView.builder(
            itemCount: hackathons.length,
            itemBuilder: (context, index) {
              final hackathon = hackathons[index];
              final hackathonData = hackathon.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(10),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    hackathonData['name'] ?? 'No Name',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text("📅 Date: ${_formatDate(hackathonData['date'])}"),
                      const SizedBox(height: 4),
                      Text("📍 Location: ${hackathonData['place'] ?? 'Unknown'}"),
                      const SizedBox(height: 4),
                      Text(
                        "⏳ Registration Deadline: ${_formatDate(hackathonData['registrationDeadline'])}",
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeamsListScreen(
                          hackathonId: hackathon.id,
                          hackathonData: hackathonData, hackathonName: '',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
