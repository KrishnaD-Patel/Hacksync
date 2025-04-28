import 'package:flutter/material.dart';
import 'package:hacksync/participant/dashboard_page.dart';
import 'hackathon_details.dart';
import 'teams_list.dart';
import 'profile_screen.dart';

class ParticipantDashboard extends StatefulWidget {
  const ParticipantDashboard({super.key});

  @override
  State<ParticipantDashboard> createState() => _ParticipantDashboardState();
}

class _ParticipantDashboardState extends State<ParticipantDashboard> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DashboardPage(), // or any screen you want as the default
    );
  }
}
