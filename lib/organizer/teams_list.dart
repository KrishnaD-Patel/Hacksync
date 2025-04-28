import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeamsListScreen extends StatelessWidget {
  final String hackathonId;
  final String hackathonName;
  final Map<String, dynamic> hackathonData;

  const TeamsListScreen({
    Key? key,
    required this.hackathonId,
    required this.hackathonName,
    required this.hackathonData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CollectionReference teamsCollection =
        FirebaseFirestore.instance.collection('Teams');

    return Scaffold(
      appBar: AppBar(
        title: Text('Registered Teams'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: teamsCollection
            .where('hackathonName', isEqualTo: hackathonName) 
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading teams.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final teams = snapshot.data?.docs ?? [];

          if (teams.isEmpty) {
            return const Center(child: Text('No teams registered yet.'));
          }

          return ListView.builder(
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(team['teamName'] ?? 'Unnamed Team'),
                  subtitle: Text('Leader: ${team['leaderName'] ?? '-'}'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(team['teamName'] ?? ''),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Leader: ${team['leaderName'] ?? '-'}'),
                            const SizedBox(height: 8),
                            Text('Members: ${(team['members'] as List<dynamic>?)?.join(', ') ?? '-'}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
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
