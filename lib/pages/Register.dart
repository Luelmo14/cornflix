import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Register extends StatefulWidget {
  final VoidCallback showLoginPage;
  const Register({Key? key, required this.showLoginPage}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String? errorMessage = '';
  bool hidePassword = true;
  bool hideConfirmPassword = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();

  Future<void> createUserWithEmailAndPassword() async {
    if (passwordConfirmed()) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        addUserDetails(nameController.text.trim(),
            surnameController.text.trim());

      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          setState(() {
            errorMessage = 'The password provided is too weak.';
          });
        } else if (e.code == 'invalid-email') {
          setState(() {
            errorMessage = 'Invalid email.';
          });
        } else if (e.code == 'email-already-in-use') {
          setState(() {
            errorMessage = 'The account already exists for that email.';
          });
        } else {
          setState(() {
            errorMessage = 'Please fill in all fields.';
          });
        }
      } catch (e) {
        // ignore: avoid_print
        print(e);
      }
    } else {
      setState(() {
        errorMessage = 'Passwords do not match.';
      });
    }
  }

  Future addUserDetails(String name, String surname) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'name': name,
      'surname': surname,
      'genre_page_done': false,
      'fav_movies': [],
      'dismissed_movies': [],
      'is_first_time': true,
      'is_first_favorites_time': true,
    });
  }

  bool passwordConfirmed() {
    if (passwordController.text.trim() == confirmPasswordController.text.trim()) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    surnameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.showLoginPage();
        return false;
      },
      child: Scaffold(
          backgroundColor: const Color.fromRGBO(23, 25, 26, 1),
          body: SafeArea(
            child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.only(left: 30),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: widget.showLoginPage,
                              child: Image.asset(
                                'assets/images/backArrow.png',
                                height: 30,
                                width: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: const BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black38,
                              offset: Offset(0, 0),
                              blurRadius: 19,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 83,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                              'Register to ',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                shadows: [
                                  Shadow(
                                    color: Colors.black87,
                                    blurRadius: 7,
                                    offset: Offset(1.2, 1.2),
                                  ),
                                ],
                              )
                          ),
                          Text(
                              'CornFlix',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                color: Color.fromRGBO(255, 56, 56, 1),
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                shadows: [
                                  Shadow(
                                    color: Colors.black45,
                                    blurRadius: 7,
                                    offset: Offset(1.2, 1.2),
                                  ),
                                ],
                              )
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      const Text(
                          'Movie info at your fingertips!',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Color.fromRGBO(202, 202, 202, 1),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 5,
                                offset: Offset(0.8, 0.8),
                              ),
                            ],
                          )
                      ),

                      const SizedBox(height: 35),

                      Text(
                        errorMessage!,
                        style: const TextStyle(
                            color: Colors.red,
                            fontFamily: 'Inter'),
                      ),

                      const SizedBox(height: 15),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          decoration: BoxDecoration(
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(1, 1.3),
                                  blurRadius: 6,
                                ),
                              ],
                              color: const Color.fromRGBO(36, 37, 41, 1),
                              borderRadius: BorderRadius.circular(14)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: TextField(
                                keyboardType: TextInputType.name,
                                controller: nameController,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Inter',
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Name',
                                  hintStyle: TextStyle(
                                    color: Color.fromRGBO(202, 202, 202, 1),
                                    fontFamily: 'Inter',
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  )
                                )
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          decoration: BoxDecoration(
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(1, 1.3),
                                  blurRadius: 6,
                                ),
                              ],
                              color: const Color.fromRGBO(36, 37, 41, 1),
                              borderRadius: BorderRadius.circular(14)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: TextField(
                                keyboardType: TextInputType.name,
                                controller: surnameController,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Inter',
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Surname',
                                    hintStyle: TextStyle(
                                      color: Color.fromRGBO(202, 202, 202, 1),
                                      fontFamily: 'Inter',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    )
                                )
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          decoration: BoxDecoration(
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(1, 1.3),
                                  blurRadius: 6,
                                ),
                              ],
                              color: const Color.fromRGBO(36, 37, 41, 1),
                              borderRadius: BorderRadius.circular(14)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: TextField(
                                keyboardType: TextInputType.emailAddress,
                                controller: emailController,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Inter',
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Email',
                                    hintStyle: TextStyle(
                                      color: Color.fromRGBO(202, 202, 202, 1),
                                      fontFamily: 'Inter',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    )
                                )
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          decoration: BoxDecoration(
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(1, 1.3),
                                  blurRadius: 6,
                                ),
                              ],
                              color: const Color.fromRGBO(36, 37, 41, 1),
                              borderRadius: BorderRadius.circular(14)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: TextField(
                                obscureText: hidePassword,
                                controller: passwordController,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Inter',
                                ),
                                decoration: InputDecoration(
                                    suffixIcon: Material(
                                      color: Colors.transparent,
                                      shape: const CircleBorder(),
                                      clipBehavior: Clip.hardEdge,
                                      child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              hidePassword = !hidePassword;
                                            });
                                          },
                                          icon: Icon(
                                            hidePassword ? Icons.remove_red_eye_outlined : Icons.remove_red_eye_rounded,
                                            color: const Color.fromRGBO(202, 202, 202, 1),
                                            size: 22,
                                          )
                                      ),
                                    ),
                                  border: InputBorder.none,
                                  hintText: 'Password',
                                    hintStyle: const TextStyle(
                                      color: Color.fromRGBO(202, 202, 202, 1),
                                      fontFamily: 'Inter',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    )
                                )
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Container(
                          decoration: BoxDecoration(
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(1, 1.3),
                                  blurRadius: 6,
                                ),
                              ],
                              color: const Color.fromRGBO(36, 37, 41, 1),
                              borderRadius: BorderRadius.circular(14)
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: TextField(
                                obscureText: hideConfirmPassword,
                                controller: confirmPasswordController,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Inter',
                                ),
                                decoration: InputDecoration(
                                    suffixIcon: Material(
                                      color: Colors.transparent,
                                      shape: const CircleBorder(),
                                      clipBehavior: Clip.hardEdge,
                                      child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              hideConfirmPassword = !hideConfirmPassword;
                                            });
                                          },
                                          icon: Icon(
                                            hideConfirmPassword ? Icons.remove_red_eye_outlined : Icons.remove_red_eye_rounded,
                                            color: const Color.fromRGBO(202, 202, 202, 1),
                                            size: 22,
                                          )
                                      ),
                                    ),
                                  border: InputBorder.none,
                                  hintText: 'Confirm Password',
                                    hintStyle: const TextStyle(
                                      color: Color.fromRGBO(202, 202, 202, 1),
                                      fontFamily: 'Inter',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    )
                                )
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          splashColor: Colors.black12.withOpacity(0.165),
                          splashFactory: InkRipple.splashFactory,
                          onTap: createUserWithEmailAndPassword,
                          child: Ink(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    offset: Offset(1, 1.3),
                                    blurRadius: 6,
                                  ),
                                ],
                                color: const Color.fromRGBO(255, 56, 56, 1),
                                borderRadius: BorderRadius.circular(14)
                            ),
                            child: const Center(
                                child: Text(
                                  'Register',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Inter',
                                    shadows: [
                                      Shadow(
                                        color: Colors.black12,
                                        blurRadius: 5,
                                        offset: Offset(0.5, 0.5),
                                      ),
                                    ],
                                  ),
                                )
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 45),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already a member? ',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(202, 202, 202, 1),
                              shadows: [
                                Shadow(
                                  color: Colors.black38,
                                  blurRadius: 5,
                                  offset: Offset(0.8, 0.8),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: widget.showLoginPage,
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                  color: Color.fromRGBO(255, 56, 56, 1),
                                  fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    blurRadius: 5,
                                    offset: Offset(0.8, 0.8),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 75),
                    ],
                  ),
                )
            ),
          )
      ),
    );
  }
}