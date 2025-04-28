import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hacksync/participant/register.dart';

class HackathonDetailsPage extends StatelessWidget {
  final Map<String, dynamic> hackathonData;
  final String hackathonId;

  const HackathonDetailsPage({
    Key? key,
    required this.hackathonData,
    required this.hackathonId,
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
                  const Icon(Icons.calendar_today, color: Colors.blueGrey),
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
              const SizedBox(height: 20),
              const Text(
                "Problem Statement:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                hackathonData["problemStatement"] ?? "No problem statement available.",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                "Guidelines:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                hackathonData["guidelines"] ?? "No guidelines available.",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
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
                  child: const Text("Register Now"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
