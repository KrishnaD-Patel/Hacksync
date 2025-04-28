import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateHackathonScreen extends StatefulWidget {
  const CreateHackathonScreen({Key? key}) : super(key: key);

  @override
  _CreateHackathonScreenState createState() => _CreateHackathonScreenState();
}

class _CreateHackathonScreenState extends State<CreateHackathonScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _registrationDeadlineController = TextEditingController();
  final TextEditingController _problemStatementController = TextEditingController();
  final TextEditingController _guidelinesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _locationController.dispose();
    _registrationDeadlineController.dispose();
    _problemStatementController.dispose();
    _guidelinesController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User not logged in')),
          );
          return;
        }

        await FirebaseFirestore.instance.collection('hackathon').add({
          'name': _nameController.text.trim(),
          'date': DateTime.parse(_dateController.text.trim()),
          'place': _locationController.text.trim(),
          'registrationDeadline': DateTime.parse(_registrationDeadlineController.text.trim()),
          'problemStatement': _problemStatementController.text.trim(),
          'guidelines': _guidelinesController.text.trim(),
          'organizerId': user.uid,
        });

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hackathon Created!'),
            content: const Text('Your hackathon has been successfully created. Let the innovation begin! 🚀'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text('Awesome!'),
              ),
            ],
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text = picked.toIso8601String();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Hackathon')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Hackathon Name'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter hackathon name' : null,
              ),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Date'),
                readOnly: true,
                onTap: () => _selectDate(context, _dateController),
                validator: (value) => value == null || value.isEmpty ? 'Please select date' : null,
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter location' : null,
              ),
              TextFormField(
                controller: _registrationDeadlineController,
                decoration: const InputDecoration(labelText: 'Registration Deadline'),
                readOnly: true,
                onTap: () => _selectDate(context, _registrationDeadlineController),
                validator: (value) => value == null || value.isEmpty ? 'Please select registration deadline' : null,
              ),
              TextFormField(
                controller: _problemStatementController,
                decoration: const InputDecoration(labelText: 'Problem Statement'),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Please enter problem statement' : null,
              ),
              TextFormField(
                controller: _guidelinesController,
                decoration: const InputDecoration(labelText: 'Guidelines'),
                maxLines: 2,
                validator: (value) => value == null || value.isEmpty ? 'Please enter guidelines' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Create Hackathon'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
