import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fp_1/pages/auth.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        actions: [
          Text("Sign Out!"),
          IconButton(
              onPressed: signUserOut,
              icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Text(
          "LOGGED IN AS: " + user.email!,
          style: TextStyle(fontSize: 15),
        ),
      ),
    );
  }


}