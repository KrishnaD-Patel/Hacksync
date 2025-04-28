import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
// import package:go_router/go_router.dart;
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hackathon Management App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AuthWrapper(), 
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator())); 
        } else if (snapshot.hasData) {
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection("users").doc(snapshot.data!.uid).get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(body: Center(child: CircularProgressIndicator()));
              } else if (snapshot.hasData && snapshot.data!.exists) {
                String role = snapshot.data!["role"];
                return HomeScreen(role: role); 
              } else {
                return SignupPage(); 
              }
            },
          );
        } else {
          return LoginPage(); 
        }
      },
    );
  }
}

// for go on different pages using URL

// class MyApp extends StatelessWidget{
//   @override
//   Widget build(BuildContext context){
//     return MaterialApp(
//       debugShowCheckedModebanner: false,
//       initialRoute: '/',
//       routes: {
//         '/': (context) => SignupPage(),
//         '/login': (context) => LoginPage(),
//         '/participant': (context) => ParticipantDashboard(),
//         '/organizer': (context) => OrganizerDashboard(),
//       },
//     )
//   }
// }