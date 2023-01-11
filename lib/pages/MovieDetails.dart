import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corn_flix/data/RecommendedMovies.dart';
import 'package:corn_flix/data/TopCastData.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../data/MovieDetailsData.dart';

class MovieDetails extends StatefulWidget {
  final int id;
  const MovieDetails({Key? key, required this.id}) : super(key: key);

  @override
  _MovieDetailsState createState() => _MovieDetailsState();
}

class _MovieDetailsState extends State<MovieDetails> {
  MovieDetailsData? movieDetailsData;
  final user = FirebaseAuth.instance.currentUser;
  bool _isFavButtonSelected = false;
  TopCastData? topCastData;
  RecommendedMovies? similarMovies;

  Image _favButtonImage = Image.asset(
    'assets/images/favDetails.png',
    height: 30,
    width: 30,
  );

  @override
  void initState() {
    super.initState();
  }

  getMovieDetailsById() async {
    int id = widget.id;
    var client = http.Client();
    var url = Uri.parse('https://api.themoviedb.org/3/movie/$id?api_key=b5f80d427803f2753428de379acc4337&language=en-US');
    var response = await client.get(url);

    if (response.statusCode == 200) {
      var data = response.body;

      Map<String, dynamic> jsonData = jsonDecode(data);
      movieDetailsData = MovieDetailsData.fromJson(jsonData);
      return movieDetailsData;

    } else {
      // ignore: avoid_print
      print(response.statusCode);
    }
  }

  getMovieTopCast() async {
    int id = widget.id;
    var client = http.Client();
    var url = Uri.parse('https://api.themoviedb.org/3/movie/$id/credits?api_key=b5f80d427803f2753428de379acc4337&language=en-US');
    var response = await client.get(url);

    if (response.statusCode == 200) {
      var data = response.body;

      Map<String, dynamic> jsonData = jsonDecode(data);
      topCastData = TopCastData.fromJson(jsonData);
      topCastData!.cast?.removeWhere((element) => element.profilePath == null);
      return topCastData;

    } else {
      // ignore: avoid_print
      print(response.statusCode);
    }
  }

  getSimilarMovies() async {
    int id = widget.id;
    var client = http.Client();
    var url = Uri.parse('https://api.themoviedb.org/3/movie/$id/similar?api_key=b5f80d427803f2753428de379acc4337&language=en-US&page=1');
    var response = await client.get(url);

    if (response.statusCode == 200) {
      var data = response.body;

      Map<String, dynamic> jsonData = jsonDecode(data);
      similarMovies = RecommendedMovies.fromJson(jsonData);
      similarMovies!.results?.removeWhere((element) => element.posterPath == null);
      return similarMovies;

    } else {
      // ignore: avoid_print
      print(response.statusCode);
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
                  future: getMovieDetailsById(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Stack(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.black,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color.fromRGBO(15, 15, 15, 1),
                                    width: 15,
                                  ),
                                ),
                              ),
                            child: Image.network(
                              'https://image.tmdb.org/t/p/w500/${movieDetailsData!.backdropPath}',
                              fit: BoxFit.cover,
                              height: 400,
                              width: double.infinity,
                            ),
                          ),
                          Positioned(
                            top: 35,
                            left: 25,
                            child: FloatingActionButton(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Image.asset(
                                'assets/images/backFromDetails.png',
                                height: 44,
                                width: 44,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 360,
                            right: 3,
                            child: SizedBox(
                              height: 30,
                              child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: movieDetailsData!.genres?.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 7),
                                    child: Theme(
                                      data: ThemeData(canvasColor: Colors.transparent),
                                      child: Chip(
                                        backgroundColor: const Color.fromRGBO(36, 37, 41, 0.80),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(9),
                                        ),
                                        label: Text(
                                          movieDetailsData!.genres![index].name ?? '',
                                          style: const TextStyle(
                                            color: Color.fromRGBO(255, 255, 255, 75),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    )
                                  );
                                },
                              ),
                            ),
                          ),
                       Column(
                         children: [
                           const SizedBox(height: 420),
                           Row(
                             children: [
                               Align(
                                 child: Padding(
                                   padding: const EdgeInsets.only(left: 15),
                                   child: Chip(
                                     backgroundColor: const Color.fromRGBO(240, 205, 86, 1),
                                     shape: RoundedRectangleBorder(
                                       borderRadius: BorderRadius.circular(10),
                                     ),
                                     label: Row(
                                       mainAxisSize: MainAxisSize.min,
                                       children: [
                                         const Text(
                                           'Score ',
                                           style: TextStyle(
                                             color: Colors.black,
                                             fontSize: 14,
                                             fontWeight: FontWeight.w400,
                                           ),
                                         ),
                                         Text(
                                           '${movieDetailsData!.voteAverage?.toStringAsFixed(1)}',
                                           style: const TextStyle(
                                             color: Colors.black,
                                             fontSize: 15,
                                             fontWeight: FontWeight.w700,
                                           ),
                                         ),
                                         const Text(
                                           '/10',
                                           style: TextStyle(
                                             color: Colors.black,
                                             fontSize: 14,
                                             fontWeight: FontWeight.w400,
                                           ),
                                         ),
                                       ],
                                     ),
                                   ),
                                 ),
                               ),
                               Padding(
                                 padding: const EdgeInsets.only(left: 6),
                                 child: Text(
                                    '${movieDetailsData!.voteCount} votes',
                                    style: const TextStyle(
                                      color: Color.fromRGBO(255, 255, 255, 75),
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                               ),
                               // Add and image button aligned to the right for the favorite movies
                               Expanded(
                                 child: Align(
                                   alignment: Alignment.centerRight,
                                   child: Padding(
                                     padding: const EdgeInsets.only(right: 7),
                                     child: FloatingActionButton(
                                       onPressed: () {
                                         setState(() {
                                           if (_isFavButtonSelected) {
                                             _isFavButtonSelected = false;
                                              deleteFavId(widget.id);
                                           } else {
                                             _isFavButtonSelected = true;
                                             saveFavId(widget.id);
                                           }
                                           _favButtonImage = _isFavButtonSelected ?
                                           Image.asset(
                                             'assets/images/FavDetailsOrange.png',
                                             height: 30,
                                             width: 30,
                                           ) : Image.asset(
                                             'assets/images/favDetails.png',
                                             height: 30,
                                             width: 30,
                                           );
                                         });
                                       },
                                       backgroundColor: Colors.transparent,
                                       elevation: 0,
                                       child: _favButtonImage,
                                     ),
                                   ),
                                 ),
                               ),
                             ],
                           ),
                           const SizedBox(height: 13),
                           Align(
                             alignment: Alignment.centerLeft,
                             child: Padding(
                               padding: const EdgeInsets.only(left: 15),
                               child: Text(
                                 movieDetailsData!.title ?? '',
                                 style: const TextStyle(
                                   color: Colors.white,
                                   fontSize: 30,
                                   fontWeight: FontWeight.w600,
                                   fontFamily: 'Inter'
                                 ),
                               ),
                             ),
                           ),
                           const SizedBox(height: 9),
                           Row(
                             children: [
                               Padding(
                                 padding: const EdgeInsets.only(left: 15),
                                 child: Text(
                                   movieDetailsData!.releaseDate?.substring(0, 4) ?? '',
                                   style: const TextStyle(
                                     color: Color.fromRGBO(255, 255, 255, 75),
                                     fontSize: 16,
                                     fontWeight: FontWeight.w400,
                                       fontFamily: 'Inter'
                                   ),
                                 ),
                               ),
                               const Padding(
                                 padding: EdgeInsets.only(left: 5),
                                 child: Text(
                                   '·',
                                   style: TextStyle(
                                     color: Color.fromRGBO(255, 255, 255, 75),
                                     fontSize: 17,
                                     fontWeight: FontWeight.w600,
                                       fontFamily: 'Inter'
                                   ),
                                 ),
                               ),
                               Padding(
                                 padding: const EdgeInsets.only(left: 5),
                                 child: Text(
                                   '${(movieDetailsData!.runtime! / 60).floor()}h ${(movieDetailsData!.runtime! % 60).floor()}m',
                                   style: const TextStyle(
                                     color: Color.fromRGBO(255, 255, 255, 75),
                                     fontSize: 16,
                                     fontWeight: FontWeight.w400,
                                       fontFamily: 'Inter'
                                   ),
                                 ),
                               ),
                             ],
                           ),
                            const SizedBox(height: 5),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 15),
                                child: Text(
                                  'Country: ${movieDetailsData!.productionCountries!.map((e) => e.name == 'United States of America' ? 'USA' : e.name).toList().join(', ')}',
                                  style: const TextStyle(
                                    color: Color.fromRGBO(255, 255, 255, 75),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                      fontFamily: 'Inter'
                                  ),
                                ),
                              ),
                            ),
                           const SizedBox(height: 5),
                           Align(
                             alignment: Alignment.centerLeft,
                             child: Padding(
                               padding: const EdgeInsets.only(left: 15),
                               child: Text(
                                 'Original title: ${movieDetailsData!.originalTitle}',
                                 style: const TextStyle(
                                   color: Color.fromRGBO(255, 255, 255, 75),
                                   fontSize: 16,
                                   fontWeight: FontWeight.w400,
                                     fontFamily: 'Inter'
                                 ),
                               ),
                             ),
                           ),
                           const SizedBox(height: 20),
                           Align(
                             alignment: Alignment.centerLeft,
                             child: Padding(
                               padding: const EdgeInsets.only(left: 15, right: 25),
                               child: Text(
                                 movieDetailsData!.overview ?? '',
                                 style: const TextStyle(
                                     color: Colors.white,
                                     fontSize: 16,
                                     fontWeight: FontWeight.w400,
                                     fontFamily: 'Inter'
                                 ),
                               ),
                             ),
                           ),
                         ],
                       ),
                     ],
                     );
                    } else {
                      return const Padding(
                        padding: EdgeInsets.only(top: 155, bottom: 155),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(color: Color.fromRGBO(255, 56, 56, 1)),
                        ),
                      );
                    }
                  },
                ),
                FutureBuilder(
                  future: getMovieTopCast(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: [
                          const SizedBox(height: 20),
                          const Padding(
                            padding: EdgeInsets.only(left: 15, top: 15),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Top cast',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 23,
                                  fontWeight: FontWeight.w400,
                                    fontFamily: 'Inter'
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          ListView(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: 120,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: topCastData!.cast!.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(left: 15),
                                      child: SizedBox(
                                        width: 70,
                                        child: Column(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(30),
                                              child: Image.network(
                                                'https://image.tmdb.org/t/p/w500${topCastData!.cast![index].profilePath}',
                                                height: 70,
                                                width: 70,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            SizedBox(
                                              width: 70,
                                              child: Text(
                                                topCastData!.cast![index].name ?? '',
                                                maxLines: 2,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                    fontFamily: 'Inter'
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else {
                      return const Padding(
                        padding: EdgeInsets.only(top: 155, bottom: 155),
                        child: SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(color: Color.fromRGBO(255, 56, 56, 1)),
                        ),
                      );
                    }
                  }
                ),
                FutureBuilder(
                    future: getSimilarMovies(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 15, top: 15),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Similar Movies',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 23,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'Inter'
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            ListView(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                SizedBox(
                                  height: 200,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: similarMovies!.results!.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.only(left: 15),
                                        child: SizedBox(
                                          width: 90,
                                          child: Column(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: Image.network(
                                                  'https://image.tmdb.org/t/p/w500${similarMovies!.results![index].posterPath}',
                                                  height: 130,
                                                  width: 90,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              SizedBox(
                                                width: 70,
                                                child: Text(
                                                  similarMovies!.results![index].title ?? '',
                                                  maxLines: 4,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w400,
                                                      fontFamily: 'Inter'
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      } else {
                        return const Padding(
                          padding: EdgeInsets.only(top: 155, bottom: 155),
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(color: Color.fromRGBO(255, 56, 56, 1)),
                          ),
                        );
                      }
                    }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

