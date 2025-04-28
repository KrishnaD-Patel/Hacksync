import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:hacksync/organizer/teams_list.dart'; 
class HackathonDetailScreen extends StatefulWidget {
  final String organizerId;

  const HackathonDetailScreen({Key? key, required this.organizerId, required Map hackathon}) : super(key: key);

  @override
  State<HackathonDetailScreen> createState() => _HackathonDetailScreenState();
}

class _HackathonDetailScreenState extends State<HackathonDetailScreen> {
  final DateFormat formatter = DateFormat('dd MMM yyyy');
  late Future<List<Map<String, dynamic>>> _hackathonsFuture;

  @override
  void initState() {
    super.initState();
    _hackathonsFuture = fetchHackathons();
  }

  Future<List<Map<String, dynamic>>> fetchHackathons() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('hackathon')
        .where('organizerId', isEqualTo: widget.organizerId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; 
      return data;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hackathons Created"),
        leading: Navigator.canPop(context) ? const BackButton() : null,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _hackathonsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final hackathons = snapshot.data ?? [];

          if (hackathons.isEmpty) {
            return const Center(child: Text('No hackathons found.'));
          }

          return ListView.builder(
            itemCount: hackathons.length,
            itemBuilder: (context, index) {
              final hackathon = hackathons[index];
              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(hackathon["name"] ?? "Hackathon", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      
                      const SizedBox(height: 8),
                      if (hackathon["date"] != null)
                        Text("📅 Date: ${formatter.format(hackathon["date"].toDate())}", style: const TextStyle(fontSize: 16)),
                      
                      const SizedBox(height: 8),
                      if (hackathon["place"] != null)
                        Text("📍 Place: ${hackathon["place"]}", style: const TextStyle(fontSize: 16)),
                      
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TeamsListScreen(
                                  hackathonId: hackathon["id"],
                                  hackathonName: hackathon["name"],
                                  hackathonData: hackathon,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 52, 199, 204),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "Team Details",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
