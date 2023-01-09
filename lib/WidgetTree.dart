import 'package:corn_flix/AuthPage.dart';
import 'package:corn_flix/components/NavBar.dart';
import 'package:corn_flix/pages/GenrePicker.dart';
import 'package:flutter/material.dart';
import 'package:corn_flix/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  final firebaseUser = FirebaseAuth.instance.currentUser;
  bool showGenrePage = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const AuthPage();
        } else {
          return FutureBuilder(
            future: _fetch(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (showGenrePage) {
                  return const NavBar();
                } else {
                  return GenrePicker();
                }
              } else {
                return Container(
                  alignment: Alignment.center,
                  height: 60,
                  child: const CircularProgressIndicator(
                    color: Colors.red,
                  ),
                );
              }
            },
          );
        }
      },
    );
  }


  _fetch() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get()
          .then((value) {
        showGenrePage = value.data()?['genre_page_done'];
      });
    }
  }
}