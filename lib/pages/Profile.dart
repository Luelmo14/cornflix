import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth.dart';
import '../data/ChipData.dart';
import '../data/Chips.dart';

class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String name = '', surname = '', email = '';
  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  List<ChipData> chips = Chips.all;
  List<ChipData> selectedChips = [];
  List<int> genreIds = [];
  Map<int, bool> selectedGenres = {};

  @override
  void initState() {
    super.initState();
    fetchUserFavGenres();
    nameController = TextEditingController(text: name);
    surnameController = TextEditingController(text: surname);
    emailController = TextEditingController(text: email);
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
      });
      email = firebaseUser.email!;
    }
  }

  Future<void> signOut() async {
    await Auth().signOut();
  }

  _updateName() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'name': nameController.text});
  }

  _updateSurname(String surnamePassed) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({'surname': surnamePassed});
  }

  updateUserEmail(String emailPassed) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      await firebaseUser
          .updateEmail(emailPassed)
          .then((value) => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Email updated successfully'))))
          .catchError((error) => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error.toString().substring(
                  error.toString().indexOf(']') + 2,
                  error.toString().indexOf(']') + 3)
                  .toUpperCase() +
                  error.toString().substring(error.toString().indexOf(']') + 3)),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              dismissDirection: DismissDirection.horizontal)));
    }
    setState(() {});
  }

  fetchUserFavGenres() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get()
          .then((value) {
        genreIds = List<int>.from(value.data()!['genres']);
      });
    }
  }


  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    surnameController.dispose();
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(23, 25, 26, 1),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FutureBuilder(
                  future: _fetch(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 65),
                          Image.asset('assets/images/profileIcon.png',
                              width: 140, height: 140),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(name,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 27,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 10),
                              Text(surname,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 27,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 55),
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Container(
                              height: 55,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color.fromRGBO(36, 37, 41, 1),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text('First name',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Color.fromRGBO(163, 163, 163, 1),
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w500)),
                                        const SizedBox(height: 1.8),
                                        Text(name,
                                            style: const TextStyle(
                                                fontSize: 17,
                                                color: Colors.white,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Image.asset(
                                        'assets/images/editIcon.png',
                                        width: 25,
                                        height: 25,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                              title: const Text("Edit your name",
                                                  style: TextStyle(color: Colors.white)),
                                              backgroundColor: const Color.fromRGBO(23, 25, 26, 1),
                                              content: TextField(
                                                controller: nameController,
                                                style: const TextStyle(color: Colors.white),
                                                decoration: const InputDecoration(
                                                        hintText: "Enter new name",
                                                        hintStyle: TextStyle(color: Color.fromRGBO(163, 163, 163, 1))),
                                              ),
                                              actions: <Widget>[
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(right: 8),
                                                        child: Container(
                                                          height: 35,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            color: const Color.fromRGBO(36, 37, 41, 1),
                                                          ),
                                                          child: TextButton(
                                                            onPressed: () {
                                                              Navigator.of(context).pop();
                                                            },
                                                            child: const Text(
                                                                "Cancel",
                                                                style: TextStyle(color: Colors.white)),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(left: 8),
                                                        child: Container(
                                                          height: 35,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            color: const Color.fromRGBO(243, 134, 71, 1),
                                                          ),
                                                          child: TextButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                name = nameController.text;
                                                                _updateName();
                                                              });
                                                              Navigator.of(context).pop();
                                                            },
                                                            child: const Text(
                                                                "Confirm",
                                                                style: TextStyle(
                                                                    color: Colors.white)),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          });

                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 11.5),
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Container(
                              height: 55,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color.fromRGBO(36, 37, 41, 1),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text('Last name',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Color.fromRGBO(163, 163, 163, 1),
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w500)),
                                        const SizedBox(height: 1.8),
                                        Text(surname,
                                            style: const TextStyle(
                                                fontSize: 17,
                                                color: Colors.white,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Image.asset(
                                      'assets/images/editIcon.png',
                                      width: 25,
                                      height: 25,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                              title: const Text("Edit your surname",
                                                  style: TextStyle(color: Colors.white)),
                                              backgroundColor: const Color.fromRGBO(23, 25, 26, 1),
                                              content: TextField(
                                                controller: surnameController,
                                                style: const TextStyle(color: Colors.white),
                                                decoration: const InputDecoration(
                                                    hintText: "Enter new surname",
                                                    hintStyle: TextStyle(color: Color.fromRGBO(163, 163, 163, 1))),
                                              ),
                                              actions: <Widget>[
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(right: 8),
                                                        child: Container(
                                                          height: 35,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            color: const Color.fromRGBO(36, 37, 41, 1),
                                                          ),
                                                          child: TextButton(
                                                            onPressed: () {
                                                              Navigator.of(context).pop();
                                                            },
                                                            child: const Text(
                                                                "Cancel",
                                                                style: TextStyle(color: Colors.white)),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(left: 8),
                                                        child: Container(
                                                          height: 35,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            color: const Color.fromRGBO(243, 134, 71, 1),
                                                          ),
                                                          child: TextButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                surname = surnameController.text;
                                                                _updateSurname(surname);
                                                              });
                                                              Navigator.of(context).pop();
                                                            },
                                                            child: const Text(
                                                                "Confirm",
                                                                style: TextStyle(
                                                                    color: Colors.white)),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 11.5),
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 20),
                            child: Container(
                              height: 55,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color.fromRGBO(36, 37, 41, 1),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 14),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text('Email',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Color.fromRGBO(163, 163, 163, 1),
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w500)),
                                        const SizedBox(height: 1.8),
                                        Text(email,
                                            style: const TextStyle(
                                                fontSize: 17,
                                                color: Colors.white,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Image.asset(
                                      'assets/images/editIcon.png',
                                      width: 25,
                                      height: 25,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                              title: const Text("Edit your email",
                                                  style: TextStyle(color: Colors.white)),
                                              backgroundColor: const Color.fromRGBO(23, 25, 26, 1),
                                              content: TextField(
                                                controller: emailController,
                                                style: const TextStyle(color: Colors.white),
                                                decoration: const InputDecoration(
                                                    hintText: "Enter new email",
                                                    hintStyle: TextStyle(color: Color.fromRGBO(163, 163, 163, 1))),
                                              ),
                                              actions: <Widget>[
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(right: 8),
                                                        child: Container(
                                                          height: 35,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            color: const Color.fromRGBO(36, 37, 41, 1),
                                                          ),
                                                          child: TextButton(
                                                            onPressed: () {
                                                              Navigator.of(context).pop();
                                                            },
                                                            child: const Text(
                                                                "Cancel",
                                                                style: TextStyle(color: Colors.white)),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding: const EdgeInsets.only(left: 8),
                                                        child: Container(
                                                          height: 35,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            color: const Color.fromRGBO(243, 134, 71, 1),
                                                          ),
                                                          child: TextButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                email = emailController.text;
                                                                updateUserEmail(email);
                                                              });
                                                              Navigator.of(context).pop();
                                                            },
                                                            child: const Text(
                                                                "Confirm",
                                                                style: TextStyle(
                                                                    color: Colors.white)),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 20, right: 20),
                              child: Wrap(
                                children: _buildGenreChips(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 11.5),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, right: 20),
                                  child: Container(
                                    height: 56,
                                    decoration: const BoxDecoration(
                                      color: Color.fromRGBO(139, 139, 139, 1),
                                      borderRadius: BorderRadius.all(Radius.circular(12)),
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        signOut();
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          ImageIcon(
                                            AssetImage("assets/images/logoutIcon.png"),
                                            color: Colors.black,
                                            size: 22.5,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "Log Out",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 17,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w800),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 11.5),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20, right: 20),
                                  child: Container(
                                    height: 56,
                                    decoration: const BoxDecoration(
                                      color: Color.fromRGBO(220, 70, 70, 1),
                                      borderRadius: BorderRadius.all(Radius.circular(12)),
                                    ),
                                    child: TextButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                                title: const Text("Delete Account",
                                                    style: TextStyle(color: Colors.white)),
                                                backgroundColor: const Color.fromRGBO(23, 25, 26, 1),
                                                content: const Text("Are you sure you want to delete your account?",
                                                    style: TextStyle(color: Colors.white)),
                                                actions: <Widget>[
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(right: 8),
                                                          child: Container(
                                                            height: 35,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(10),
                                                              color: const Color.fromRGBO(36, 37, 41, 1),
                                                            ),
                                                            child: TextButton(
                                                              onPressed: () {
                                                                Navigator.of(context).pop();
                                                              },
                                                              child: const Text(
                                                                  "Cancel",
                                                                  style: TextStyle(color: Colors.white)),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(left: 8),
                                                          child: Container(
                                                            height: 35,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(10),
                                                              color: const Color.fromRGBO(243, 134, 71, 1),
                                                            ),
                                                            child: TextButton(
                                                              onPressed: () {
                                                                //deleteUser();
                                                                Navigator.of(context).pop();
                                                              },
                                                              child: const Text(
                                                                  "Confirm",
                                                                  style: TextStyle(
                                                                      color: Colors.white)),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              );
                                            });
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          ImageIcon(
                                            AssetImage("assets/images/deleteAccountIcon.png"),
                                            color: Colors.white,
                                            size: 23.4,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "Delete Account",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w800),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                        ],
                      );
                    } else {
                      return const CircularProgressIndicator(
                        color: Colors.red,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGenreChips() {
    List<Widget> genreChips = [];
    for (var chipData in Chips.all) {
      var chip = StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return ActionChip(
            label: Text(chipData.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400)),
            backgroundColor: selectedGenres[chipData.id] == true || genreIds.contains(chipData.id)
            ? Colors.red
                : chipData.color,
            onPressed: () {
              setState(() {
                selectedGenres[chipData.id] = !(selectedGenres[chipData.id] == true);
                if (selectedGenres[chipData.id] == true) {
                  if (!genreIds.contains(chipData.id)) {
                    setState(() {
                      genreIds.add(chipData.id);
                    });
                    print(genreIds);
                  } else {
                    selectedGenres[chipData.id] = false;
                    setState(() {
                      genreIds.remove(chipData.id);
                    });
                    print(genreIds);
                  }
                } else {
                  setState(() {
                    genreIds.remove(chipData.id);
                  });
                }
                _updateFavouriteGenres();
              });
            },
        );
          },
      );
      genreChips.add(chip);
    }
    return genreChips;
  }

  _updateFavouriteGenres() async {
    var user = FirebaseAuth.instance.currentUser;
    var userDoc = FirebaseFirestore.instance.collection('users').doc(user?.uid);
    await userDoc.update({
      'genres': genreIds,
    });
  }

}
