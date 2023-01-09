import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../components/NavBar.dart';

class Favorites extends StatelessWidget {
  Favorites({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Welcome to Favorites Page',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),

    );
  }
}