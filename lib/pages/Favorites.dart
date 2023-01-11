import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class Favorites extends StatefulWidget {
  const Favorites({Key? key}) : super(key: key);

  @override
  State<Favorites> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites> {
  List<int> favoriteMovieIds = [];
  List<Map<String, dynamic>> favoriteMovies = [];
  Future<List<Map<String, dynamic>>> _movieDetailsFuture = Future.value([]);

  @override
  initState() {
    fetchUserFavMoviesIds();
    _movieDetailsFuture = fetchMovieDetails();
    super.initState();
  }

  fetchUserFavMoviesIds() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(23, 25, 26, 1),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
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
                            },
                            background: Container(
                              color: Colors.red,
                              child: const Icon(Icons.delete),
                            ),
                            child: ListTile(
                              title: Text(
                                movie['title'],
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                movie['release_date'],
                                style: const TextStyle(
                                  color: Colors.white,
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
        ]))),
      ),
    );
  }
}
