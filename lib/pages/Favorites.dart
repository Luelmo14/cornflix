import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

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

  @override
  initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(23, 25, 26, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logoNoBackground.png',
                    height: 37,
                  ),
                  const Text('CornFlix ',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
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
                    )
                  ),
                ),
              ),
              const SizedBox(height: 10),
              FutureBuilder(
                future: _movieDetailsFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
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
                                    '${movie['title']} removed from favorites'),
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
                                              movie['release_date'].substring(0, 4),
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
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
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
    );
  }
}
