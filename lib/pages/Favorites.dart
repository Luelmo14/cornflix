import 'dart:convert';
import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../components/NavBar.dart';
import 'MovieDetails.dart';

class Favorites extends StatefulWidget {
  const Favorites({Key? key}) : super(key: key);

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  final user = FirebaseAuth.instance.currentUser;
  List<int> favoriteMovieIds = [];
  List<Map<String, dynamic>> favoriteMovies = [];
  Future<List<Map<String, dynamic>>> _movieDetailsFuture = Future.value([]);
  final favoritesNavigatorKey = GlobalKey<NavigatorState>();
  bool _isFirstAccess = false;

  @override
  initState() {
    super.initState();
    _checkFirstAccess();
    fetchUserFavMoviesIds();
    _movieDetailsFuture = fetchMovieDetails();
  }

  fetchUserFavMoviesIds() async {
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get()
          .then((value) {
        favoriteMovieIds = List<int>.from(value['fav_movies']);
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchMovieDetails() async {
    await fetchUserFavMoviesIds();
    for (var id in favoriteMovieIds) {
      var client = http.Client();
      var url = Uri.parse(
          'https://api.themoviedb.org/3/movie/$id?api_key=b5f80d427803f2753428de379acc4337&language=en-US');
      var response = await client.get(url);
      if (response.statusCode == 200) {
        var movieData = jsonDecode(response.body);
        //favoriteMovies.clear();
        favoriteMovies.add(movieData);
      } else {
        // ignore: avoid_print
        print(
            'Failed to load movies with status code : ${response.statusCode}');
      }
    }
    return favoriteMovies;
  }

  deleteFavId(int id) {
    FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'fav_movies': FieldValue.arrayRemove([id])
    });
  }

  pushToMovieDetailsPage(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetails(id: id, previousPage: 'Favorites', navigatorKey: favoritesNavigatorKey),
      ),
    );
  }

  _checkFirstAccess() {
    FirebaseFirestore.instance.collection('users').doc(user!.uid).get().then((value) {
      if (value.data()!['is_first_favorites_time']) {
        setState(() {
          _isFirstAccess = true;
        });
      } else {
        setState(() {
          _isFirstAccess = false;
        });
      }
    });
  }

  updateFirstAccess() {
    FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'is_first_favorites_time': false
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isFirstAccess && favoriteMovieIds.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Flushbar(
          backgroundGradient: const LinearGradient(
            colors: [
              Color.fromRGBO(243, 134, 71, 22),
              Color.fromRGBO(243, 104, 71, 22),
              Color.fromRGBO(243, 134, 71, 22)],
          ),
          barBlur: 2.4,
          margin: const EdgeInsets.only(left: 15, right: 15, bottom: 70),
          borderRadius: BorderRadius.circular(15),
          flushbarPosition: FlushbarPosition.BOTTOM,
          titleText: const Text(
            'Your favorite movies!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontFamily: 'Inter',
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0.5, 0.5),
                ),
              ],
            ),
          ),
          messageText: const Text(
            'Swipe horizontally to delete a movie from your favorites list.',
            style: TextStyle(
              color: Color.fromRGBO(255, 255, 255, 20),
              fontSize: 13.5,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0.6, 0.6),
                ),
              ],
            ),
          ),
          icon: const Icon(
            Icons.favorite,
            size: 23,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0.6, 0.6),
              ),
            ],
          ),
          isDismissible: false,
          shouldIconPulse: true,
          mainButton: TextButton(
            onPressed: () {
              Navigator.of(context).pop();

            },
            child: const Text(
              'Got it!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontFamily: 'Inter',
                fontSize: 14.6,
                shadows: [
                  Shadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0.8, 0.8),
                  ),
                ],
              ),
            ),
          ),
        ).show(context);
      });
      updateFirstAccess();
      _isFirstAccess = false;
    }
    return WillPopScope(
      onWillPop: () async {
        // return to home page using navbar
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const NavBar(index: 0),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: Tween<double>(
                  begin: 0.4,
                  end: 1.0,
                ).animate(animation),
                child: child,
              );
            },
          ),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(23, 25, 26, 1),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0.55, 0.55),
                            blurRadius: 7.5,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logoNoBackground.png',
                        height: 37,
                      ),
                    ),
                    const Text('CornFlix ',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(
                              color: Colors.black87,
                              blurRadius: 7,
                              offset: Offset(1.2, 1.2),
                            ),
                          ],
                        )),
                  ],
                ),
                const SizedBox(height: 30),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text('Favorites',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontSize: 18.5,
                        fontWeight: FontWeight.w400,
                        shadows: [
                          Shadow(
                            color: Colors.black87,
                            blurRadius: 7,
                            offset: Offset(1.2, 1.2),
                          ),
                        ],
                      )
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // check if there are any favorite movies

                FutureBuilder(
                  future: _movieDetailsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (favoriteMovies.isEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            SizedBox(height: 100),
                            Text(
                                'No favorites? No problem!',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Color.fromRGBO(150, 150, 150, 1),
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                )
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Start exploring and add some to your list.',
                              overflow: TextOverflow.clip,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color.fromRGBO(150, 150, 150, 1),
                                fontSize: 17,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                                height: 1.5,
                              ),
                            ),
                          ],
                        );
                      }
                      favoriteMovies = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: favoriteMovies.length,
                        itemBuilder: (context, index) {
                          var movie = favoriteMovies[index];
                          return Dismissible(
                            key: Key(movie['id'].toString()),
                            onDismissed: (direction) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      '${movie['title']} removed from favorites',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  backgroundColor: const Color.fromRGBO(255, 56, 56, 1),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                                  dismissDirection: DismissDirection.horizontal,
                                ),
                              );
                              setState(() {
                                favoriteMovies.removeAt(index);
                              });
                              deleteFavId(movie['id']);
                            },
                            background: Container(
                              color: Colors.red,
                              child: const Icon(
                                Icons.delete,
                                size: 40,
                                color: Colors.white,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 13, right: 13, bottom: 11),
                              child: GestureDetector(
                                onTap: () {
                                  pushToMovieDetailsPage(movie['id']);
                                },
                                child: Container(
                                  height: 105,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: const Color.fromRGBO(36, 37, 41, 1),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25),
                                        spreadRadius: 0,
                                        blurRadius: 4,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Flexible(
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(9),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(14),
                                            child: Image.network(
                                              'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                                              height: 105,
                                              width: 80,
                                              fit: BoxFit.cover,
                                              filterQuality: FilterQuality.none,
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(right: 9.5),
                                                child: Text(
                                                  movie['title'],
                                                  style: const TextStyle(
                                                    fontFamily: 'Inter',
                                                    color: Colors.white,
                                                    fontSize: 17.5,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  overflow: TextOverflow.clip,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                // release date and if empty 'no release date'
                                                movie['release_date'] != ''
                                                    ? movie['release_date']
                                                    : 'No release date',
                                                style: const TextStyle(
                                                  fontFamily: 'Inter',
                                                  color: Colors.white,
                                                  fontSize: 16.3,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    }
                    return const Padding(
                      padding: EdgeInsets.only(top: 155, bottom: 155),
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator(
                            color: Color.fromRGBO(255, 56, 56, 1)),
                      ),
                    );
                  }
                ),
                const SizedBox(height: 30),
          ])),
        ),
      ),
    );
  }
}
