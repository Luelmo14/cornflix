import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  final VoidCallback showRegister;
  const Login({Key? key, required this.showRegister}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String? errorMessage = '';
  bool hidePassword = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signInWithEmailAndPassword() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() {
          errorMessage = 'No user found for that email.';
        });
      } else if (e.code == 'wrong-password') {
        setState(() {
          errorMessage = 'Wrong password provided for that user.';
        });
      } else if (e.code == 'invalid-email') {
        setState(() {
          errorMessage = 'Invalid email.';
        });
      } else {
        setState(() {
          errorMessage = 'Please fill in all fields.';
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
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
                const SizedBox(height: 45),
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
                      'Login to ',
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

                const SizedBox(height: 45),

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
                      borderRadius: BorderRadius.circular(14),
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

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.only(left: 25.0, right: 25.0),
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

                const SizedBox(height: 35),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    splashColor: Colors.black12.withOpacity(0.165),
                    splashFactory: InkRipple.splashFactory,
                    onTap: signInWithEmailAndPassword,
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
                          'Login',
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
                      'Not a member yet? ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(202, 202, 202, 1),
                          fontFamily: 'Inter',
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
                      onTap: widget.showRegister,
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Color.fromRGBO(255, 56, 56, 1),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
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
    );
  }
}