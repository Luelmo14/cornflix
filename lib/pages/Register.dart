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
        } else if (e.code == 'email-already-in-use') {
          setState(() {
            errorMessage = 'The account already exists for that email.';
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
    return Scaffold(
        backgroundColor: const Color.fromRGBO(23, 25, 26, 1),
        body: SafeArea(
          child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 35),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: widget.showLoginPage,
                            child: Image.asset(
                              'assets/images/backArrow.png',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 25),
                    Image.asset(
                      'assets/images/logo.png',
                      height: 83,
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
                            )
                        ),
                        Text(
                            'CornFlix',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Color.fromRGBO(255, 56, 56, 1),
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
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
                            color: const Color.fromRGBO(36, 37, 41, 1),
                            borderRadius: BorderRadius.circular(14)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: TextField(
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
                            color: const Color.fromRGBO(36, 37, 41, 1),
                            borderRadius: BorderRadius.circular(14)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: TextField(
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
                            color: const Color.fromRGBO(36, 37, 41, 1),
                            borderRadius: BorderRadius.circular(14)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: TextField(
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
                            color: const Color.fromRGBO(36, 37, 41, 1),
                            borderRadius: BorderRadius.circular(14)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: TextField(
                              obscureText: true,
                              controller: passwordController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Inter',
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Password',
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
                            color: const Color.fromRGBO(36, 37, 41, 1),
                            borderRadius: BorderRadius.circular(14)
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                          child: TextField(
                              obscureText: true,
                              controller: confirmPasswordController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Inter',
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Confirm Password',
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

                    const SizedBox(height: 25),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: GestureDetector(
                        onTap: createUserWithEmailAndPassword,
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
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
                                    fontFamily: 'Inter'
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
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.showLoginPage,
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                                color: Color.fromRGBO(255, 56, 56, 1),
                                fontWeight: FontWeight.bold
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
    );
  }
}