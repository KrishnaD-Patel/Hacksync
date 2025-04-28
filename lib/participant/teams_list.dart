import 'package:flutter/material.dart';
import 'dashboard_page.dart';

class TeamsPage extends StatefulWidget {
  @override
  _TeamsPageState createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  final List<Map<String, dynamic>> hackathons = [
    {
      "name": "Hackathon 1",
      "teams": [
        {"name": "Team 1", "members": ["Meet", "Rishi", "Het"]},
        {"name": "Team 2", "members": ["Harsh", "Yashvi", "Krishna"]},
      ]
    },
    {
      "name": "Hackathon 2",
      "teams": [
        {"name": "Team 1", "members": ["Hetvi", "Khushi", "Prince"]},
        {"name": "Team 2", "members": ["Mohit", "Dixit", "Dhruvi"]},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Teams"),
        backgroundColor: const Color.fromRGBO(52, 199, 204, 1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => DashboardPage()));
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: hackathons.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: ExpansionTile(
                  title: Text(
                    hackathons[index]["name"],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  children: hackathons[index]["teams"].map<Widget>((team) {
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blueAccent, width: 1),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.group, color: Colors.blue),
                        title: Text(
                          team["name"],
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text("Members: ${team["members"].join(", ")}"),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TeamDetailsPage(team: team),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class TeamDetailsPage extends StatelessWidget {
  final Map<String, dynamic> team;

  const TeamDetailsPage({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(team["name"]),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Team Name: ${team["name"]}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Members:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                ...team["members"].map<Widget>((member) => ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(member),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
