import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hacksync/participant/register.dart';
import 'package:intl/intl.dart';

class HackathonListScreen extends StatelessWidget {
  const HackathonListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hackathons")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('hackathons')
            .where('createdByRole', isEqualTo: 'organizer')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Hackathons Available"));
          }

          var hackathons = snapshot.data!.docs;
          List<Map<String, dynamic>> upcomingHackathons = [];
          List<Map<String, dynamic>> completedHackathons = [];

          for (var doc in hackathons) {
            var hackathon = doc.data() as Map<String, dynamic>;
            DateTime eventDate = hackathon["date"].toDate();
            if (eventDate.isAfter(DateTime.now())) {
              upcomingHackathons.add({...hackathon, "id": doc.id});
            } else {
              completedHackathons.add({...hackathon, "id": doc.id});
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Upcoming Hackathons",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildHackathonList(upcomingHackathons, context),
                const SizedBox(height: 20),
                const Text(
                  "Completed Hackathons",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildHackathonList(completedHackathons, context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHackathonList(List<Map<String, dynamic>> hackathons, BuildContext context) {
    if (hackathons.isEmpty) {
      return const Center(child: Text("No hackathons found"));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: hackathons.length,
      itemBuilder: (context, index) {
        var hackathon = hackathons[index];
        String formattedDate = DateFormat('dd MMM yyyy').format(hackathon["date"].toDate());

        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(
              hackathon["name"] ?? "No Name",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Date: $formattedDate"),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HackathonDetailsScreen(
                    hackathonId: hackathon["id"],
                    hackathonData: hackathon,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class HackathonDetailsScreen extends StatelessWidget {
  final String hackathonId;
  final Map<String, dynamic> hackathonData;

  const HackathonDetailsScreen({
    Key? key,
    required this.hackathonId,
    required this.hackathonData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('dd MMM yyyy').format(hackathonData["date"].toDate());

    return Scaffold(
      appBar: AppBar(
        title: Text(hackathonData["name"] ?? "Hackathon Details"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Text(
                hackathonData["name"] ?? "No Name",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.date_range, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  Text(
                    "Date: $formattedDate",
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.blueGrey),
                  const SizedBox(width: 8),
                  Text(
                    "Place: ${hackathonData["place"] ?? "Unknown"}",
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "Problem Statement:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                hackathonData["problemStatement"] ?? "N/A",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegisterScreen(hackathonInfo: hackathonData),
                      ),
                    );
                  },
                  child: const Text("Register"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
