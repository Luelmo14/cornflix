import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:corn_flix/data/ChipData.dart';
import 'package:corn_flix/data/Chips.dart';
import '../components/NavBar.dart';

class GenrePicker extends StatefulWidget {
  GenrePicker({Key? key}) : super(key: key);

  @override
  State<GenrePicker> createState() => _GenrePickerState();
}

class _GenrePickerState extends State<GenrePicker> {
  String? errorMessage = '';
  List<ChipData> chips = Chips.all;
  final user = FirebaseAuth.instance.currentUser;
  List<ChipData> selectedChips = [];

  Widget buildChips() => Wrap(
    spacing: 8,
    children: chips.map((chip) => ChipTheme(
      data: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
          side: const BorderSide(
            color: Color.fromRGBO(36, 37, 41, 1),
            width: 0,
          ),
        ),
      ),
      child: ActionChip(
        label: Text(
            chip.name,
            style: const TextStyle(
              fontSize: 16,
            ),
        ),
        padding: const EdgeInsets.all(8),
        labelStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w400,
        ),
        backgroundColor: chip.color,
        onPressed: () {
          if (selectedChips.any((element) => element.name == chip.name)) {
            setState(() {
              selectedChips.removeWhere((element) => element.name == chip.name);
              chips = chips.map((c) => c == chip ? chip.copy(color: const Color.fromRGBO(36, 37, 41, 1)) : c).toList();
            });
          } else {
            setState(() {
              selectedChips.add(chip);
              chips = chips.map((c) => c == chip ? chip.copy(color: const Color.fromRGBO(255, 56, 56, 1)) : c).toList();
            });
          }
        },
      ),
    )).toList(),
  );

  addUserGenresAndPush() {
    if (selectedChips.isEmpty) {
      setState(() {
        errorMessage = 'Please select at least one genre';
      });
    } else {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .update({
        'genres': selectedChips.map((e) => e.id).toList(),
        'genre_page_done': true,
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const NavBar(index: 0),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(23, 25, 26, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 75),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 78,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: const [
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                        'Pick your favorite',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        )
                    ),
                  ),
                ],
              ),
              Row(
                children: const [
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                        'movie genres!',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Color.fromRGBO(255, 56, 56, 1),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        )
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: const [
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                        'Choose your favorite genres and let us',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Color.fromRGBO(190, 190, 190, 1),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        )
                    ),
                  ),
                ],
              ),
              Row(
                children: const [
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                        'guide you to your next great film discovery.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Color.fromRGBO(190, 190, 190, 1),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        )
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 9),

              Text(
                errorMessage!,
                style: const TextStyle(
                    color: Colors.red,
                    fontFamily: 'Inter'),
              ),

              const SizedBox(height: 3),

              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: buildChips(),
                ),
              ),

              const SizedBox(height: 23),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: GestureDetector(
                  onTap: addUserGenresAndPush,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 56, 56, 1),
                        borderRadius: BorderRadius.circular(14)
                    ),
                    child: const Center(
                        child: Text(
                          'Finish!',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter'
                          ),
                        )
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    );
  }
}