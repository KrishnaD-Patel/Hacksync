import 'package:flutter/material.dart';
import '../organizer/organizer_dashboard.dart';
import '../participant/participant_dashboard.dart';

class HomeScreen extends StatelessWidget {
  final String role;
  HomeScreen({required this.role});

  @override
  Widget build(BuildContext context) {
    return role.toLowerCase() == "organizer" ? OrganizerDashboard() : ParticipantDashboard();
  }
}
