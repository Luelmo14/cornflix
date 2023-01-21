import 'package:flutter/material.dart';
import '../data/RecommendedMovies.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

import 'MovieDetails.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final searchNavigatorKey = GlobalKey<NavigatorState>();
  RecommendedMovies? searchedMovies;
  TextEditingController searchController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  final Map<int,bool> _moviesFavStatus = {};

  @override
  void initState() {
    super.initState();
  }

  Future<void> getSearchedMovies(String query) async {
    var client = http.Client();
    var url = Uri.parse('https://api.themoviedb.org/3/search/movie?api_key=b5f80d427803f2753428de379acc4337&language=en-US&query=$query&page=1&include_adult=false');
    var response = await client.get(url);

    if (response.statusCode == 200) {
      var data = response.body;

      Map<String, dynamic> searchMoviesMap = jsonDecode(data);
      searchMoviesMap['results'].removeWhere((e) => e['poster_path'] == null);
      setState(() {
        searchedMovies = RecommendedMovies.fromJson(searchMoviesMap);
      });
      for (int i = 0; i < (searchedMovies?.results?.length ?? 0); i++) {
        _moviesFavStatus[searchedMovies?.results?[i].id ?? 0] = await _checkIfLiked(searchedMovies?.results?[i].id ?? 0);
      }

    } else {
      // ignore: avoid_print
      print(response.statusCode);
    }
  }

  Future<bool> _checkIfLiked(int id) async {
    bool liked = false;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get()
          .then((value) {
        if (value['fav_movies'].contains(id)) {
          liked = true;
        }
      });
    }
    return liked;
  }

  _toggleLike(int id) {
    if (user != null && _moviesFavStatus[id] != null) {
      if (_moviesFavStatus[id] == true) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({'fav_movies': FieldValue.arrayUnion([id])});
      } else {
        FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({'fav_movies': FieldValue.arrayRemove([id])});
      }
    }
  }

  saveFavId(int id) {
    FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'fav_movies': FieldValue.arrayUnion([id])
    });
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
        builder: (context) => MovieDetails(id: id, previousPage: 'MovieDetails', navigatorKey: searchNavigatorKey),
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
            mainAxisAlignment: MainAxisAlignment.center,
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
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Container(
                  height: 55,
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(1.3, 1.3),
                        blurRadius: 5.5,
                      ),
                    ],
                    color: const Color.fromRGBO(36, 37, 41, 1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.only(top: 3, right: 10),
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        getSearchedMovies(value);
                      });
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(left: 16, right: 11),
                        child: ImageIcon(
                          AssetImage('assets/images/searchTextFieldIcon.png'),
                          color: Color.fromRGBO(202, 202, 202, 1),
                        ),
                      ),
                      prefixIconConstraints: BoxConstraints(
                        minWidth: 10,
                        minHeight: 10,
                      ),
                      hintText: 'Search for a movie',
                      hintStyle: TextStyle(
                        color: Color.fromRGBO(202, 202, 202, 1),
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ),
              searchedMovies == null
                  ? const Padding(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 200),
                    child: Text(
                      'Search thousands of movies of all kinds, from action to comedy, and everything in between. Infinite possibilities!',
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
                  )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: searchedMovies?.results?.length ?? 0,
                      itemBuilder: (context, index) {
                        _checkIfLiked(searchedMovies?.results?[index].id ?? 0).then((val) => _moviesFavStatus[searchedMovies?.results?[index].id ?? 0] = val);
                        return Padding(
                          padding: const EdgeInsets.only(left: 20, right: 20),
                          child: GestureDetector(
                            onTap: () {
                              pushToMovieDetailsPage(searchedMovies!.results![index].id ?? 0);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(top: 15),
                              height: 150,
                              decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black38,
                                    offset: Offset(1.3, 1.3),
                                    blurRadius: 5.5,
                                  ),
                                ],
                                color: const Color.fromRGBO(36, 37, 41, 1),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      'https://image.tmdb.org/t/p/w500${searchedMovies?.results?[index].posterPath}',
                                      height: 150,
                                      width: 100,
                                      fit: BoxFit.cover,
                                      filterQuality: FilterQuality.none,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 14),
                                      SizedBox(
                                        width: MediaQuery.of(context).size.width - 170,
                                        child: Text(
                                          searchedMovies?.results?[index].title ?? '',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w500,
                                          ),
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        searchedMovies?.results?[index].releaseDate != ''
                                            ? '${searchedMovies?.results?[index].releaseDate}'
                                            : 'No release date',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontFamily: 'Inter',
                                          ),
                                      ),
                                      FloatingActionButton(
                                        onPressed: () async {
                                          _moviesFavStatus[searchedMovies?.results?[index].id ?? 0] = !_moviesFavStatus[searchedMovies?.results?[index].id ?? 0]!;
                                          await _toggleLike(searchedMovies?.results?[index].id ?? 0);
                                          setState(() {});
                                        },
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        child: _moviesFavStatus[searchedMovies?.results?[index].id ?? 0] ?? false
                                            ? Image.asset(
                                          'assets/images/FavDetailsOrange.png',
                                          height: 30,
                                          width: 30,
                                        ) : Image.asset(
                                          'assets/images/favDetails.png',
                                          height: 30,
                                          width: 30,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}