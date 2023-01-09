import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth.dart';

class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String name = '', surname = '', email = '';

  Future<void> signOut() async {
    await Auth().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  FutureBuilder(
                    future: _fetch(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Welcome to Profile Page',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              'Name: $name',
                            ),
                            Text(
                              'Surname: $surname',
                            ),
                            Text(
                              'Email: $email',
                            )
                          ],
                        );
                      } else {
                        return const CircularProgressIndicator(
                          color: Colors.red,
                        );
                      }
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      signOut();
                    },
                    child: const Text('Log Out'),
                  ),
                ],
              ),
            ),
          ),
        ),
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
        name = value.data()?['name'];
        surname = value.data()?['surname'];
        email = value.data()?['email'];
      });
    }
  }
}
