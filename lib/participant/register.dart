import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  final Map<String, dynamic> hackathonInfo;

  const RegisterScreen({
    Key? key,
    required this.hackathonInfo,
  }) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _teamNameController = TextEditingController();
  final TextEditingController _leaderNameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _teamSizeController = TextEditingController();
  List<TextEditingController> _memberControllers = [];

  void _updateTeamMembers() {
    int teamSize = int.tryParse(_teamSizeController.text) ?? 0;
    setState(() {
      _memberControllers = List.generate(teamSize, (index) => TextEditingController());
    });
  }

  Future<void> _registerTeam() async {
    String teamName = _teamNameController.text.trim();
    String leaderName = _leaderNameController.text.trim();
    String contact = _contactController.text.trim();
    String email = _emailController.text.trim();
    int teamSize = int.tryParse(_teamSizeController.text.trim()) ?? 0;
    List<String> members = _memberControllers.map((controller) => controller.text.trim()).toList();
    String hackathonName = widget.hackathonInfo['name'] ?? 'Unknown Hackathon';

    if (teamName.isEmpty || leaderName.isEmpty || contact.isEmpty || email.isEmpty || teamSize <= 0 || members.contains('')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields correctly')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('Teams').add({
        'teamName': teamName,
        'leaderName': leaderName,
        'contact': contact,
        'email': email,
        'teamSize': teamSize,
        'members': members,
        'hackathonName': hackathonName,
        'timestamp': FieldValue.serverTimestamp(), // optional: to keep track of registration time
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registered Successfully!')),
      );
      Navigator.pop(context); // go back after registering
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration Failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register for Hackathon"),
        backgroundColor: const Color.fromARGB(255, 52, 199, 204),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField("Team Name", _teamNameController),
            _buildTextField("Team Leader Name", _leaderNameController),
            _buildTextField("Contact Number", _contactController),
            _buildTextField("Email", _emailController),
            _buildTextField(
              "Number of Team Members",
              _teamSizeController,
              isNumber: true,
              onChanged: _updateTeamMembers,
            ),
            const SizedBox(height: 12),
            for (int i = 0; i < _memberControllers.length; i++)
              _buildTextField("Team Member ${i + 1} Name", _memberControllers[i]),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _registerTeam,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 52, 199, 204),
                ),
                child: const Text(
                  "Register",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, void Function()? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: TextField(
              controller: controller,
              keyboardType: isNumber ? TextInputType.number : TextInputType.text,
              decoration: InputDecoration(
                hintText: "Enter $label",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: onChanged != null ? (value) => onChanged() : null,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    _leaderNameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _teamSizeController.dispose();
    for (var controller in _memberControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
