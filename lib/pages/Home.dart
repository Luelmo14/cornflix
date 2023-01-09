import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corn_flix/data/BoxOfficeMovies.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import '../data/RecommendedMovies.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geo;


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final user = FirebaseAuth.instance.currentUser;
  List<int> genreIds = [];
  RecommendedMovies? recommendedMovies;
  BoxOfficeMovies? boxOfficeMovies;
  LocationData? locationData;
  Location _location = Location();
  String username = "alexluelmo";
  String userCity = "";
  List<String> languageCodes = [];
  List<dynamic> moviesFromCountry = [];
  Color _filterChipColor = const Color.fromRGBO(36, 37, 41, 1);
  bool _isFilterChipSelected = false;


  @override
  void initState() {
    super.initState();
    getRecommendedMovies();
    getBoxOfficeMovies();
    _location = Location();
    _requestLocationPermission();
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

  getRecommendedMovies() async {
    await fetchUserFavGenres();

    var client = http.Client();
    var uri = 'https://api.themoviedb.org/3/discover/movie?api_key=b5f80d427803f2753428de379acc4337&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&with_genres=';
    for (var i = 0; i < genreIds.length; i++) {
      uri += genreIds[i].toString();
      if (i != genreIds.length - 1) {
        uri += '%2C';
      }
    }
    var url = Uri.parse(uri);
    var response = await client.get(url);

    if (response.statusCode == 200) {
      var data = response.body;

      Map<String, dynamic> recommendedMoviesMap = jsonDecode(data);
      recommendedMoviesMap['results'].removeWhere((e) => e['poster_path'] == null);
      recommendedMovies = RecommendedMovies.fromJson(recommendedMoviesMap);

      setState(() {});
    } else {
      print(response.statusCode);
    }
  }

  getBoxOfficeMovies() async {
    var client = http.Client();
    var url = Uri.parse('https://api.themoviedb.org/3/movie/now_playing?api_key=b5f80d427803f2753428de379acc4337&language=en-US&page=1');
    var response = await client.get(url);

    if (response.statusCode == 200) {
      var data = response.body;

      Map<String, dynamic> boxOfficeMoviesMap = jsonDecode(data);
      boxOfficeMoviesMap['results'].removeWhere((e) => e['poster_path'] == null);
      return boxOfficeMovies = BoxOfficeMovies.fromJson(boxOfficeMoviesMap);

      setState(() {});
    } else {
      print(response.statusCode);
    }
  }

  void _requestLocationPermission() async {
    var status = await Permission.location.status;
    if (status.isGranted) {
      _getLocation();
    } else {
      if (await Permission.location.request().isGranted) {
        _getLocation();
      } else {
        _showPermissionDeniedDialog();
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Permission denied'),
            content: const Text('Please enable location permission to use this feature'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              )
            ],
          );
        }
    );
  }

  void _getLocation() async {
    try {
      locationData = await _location.getLocation();
      getCityAndLanguageCode();
    } on Exception {
      locationData = null;
    }
  }

  getCityAndLanguageCode() async {
    var client = http.Client();
    var url = Uri.parse('http://api.geonames.org/countryCodeJSON?lat=${locationData!.latitude}&lng=${locationData!.longitude}&username=$username');
    var response = await client.get(url);

    if (response.statusCode == 200) {
      var data = response.body;
      Map<String, dynamic> cityAndLanguageCodeMap = jsonDecode(data);
      userCity = cityAndLanguageCodeMap['countryName'];
      //languageCodes = cityAndLanguageCodeMap['languages'].toString().split(',').map((e) => e.split('-')[0]).toList();
      languageCodes = ['ca', 'gl'];
      print(userCity);
      print(languageCodes);
      setState(() {});
    } else {
      print(response.statusCode);
    }
  }

  getMoviesFromCountry() async {
    for (String languageCode in languageCodes) {
      var client = http.Client();
      var url = Uri.parse('https://api.themoviedb.org/3/discover/movie?api_key=b5f80d427803f2753428de379acc4337&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&with_original_language=$languageCode&with_watch_monetization_types=flatrate');
      var response = await client.get(url);
      print('hola');
      if (response.statusCode == 200) {
        var data = response.body;

        List<dynamic> moviesFromCountryMap = jsonDecode(data)['results'];
        moviesFromCountryMap.removeWhere((e) => e['poster_path'] == null);
        moviesFromCountry.addAll(moviesFromCountryMap);
        // order by popularity desc
        moviesFromCountry.sort((a, b) => b['popularity'].compareTo(a['popularity']));

        // print every movie inside moviesFromCountryMap
        for (var i = 0; i < moviesFromCountryMap.length; i++) {
          print(moviesFromCountryMap[i]['title']);
        }

        setState(() {});
      } else {
        print(response.statusCode);
      }
    }
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
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logoNoBackground.png',
                      height: 37,
                    ),
                    const Text(
                        'CornFlix ',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        )
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'We recommend',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: Colors.white,
                          fontSize: 16.6,
                          fontWeight: FontWeight.w400,
                        )
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isFilterChipSelected = !_isFilterChipSelected;
                            _filterChipColor = _isFilterChipSelected ? const Color.fromRGBO(255, 56, 56, 1) : const Color.fromRGBO(36, 37, 41, 1);
                          });
                          getMoviesFromCountry();
                        },
                        child: Chip(
                          backgroundColor: _filterChipColor,
                            label: const Text(
                                'Filter by your location',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Color.fromRGBO(176, 176, 178, 1),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                )
                            )
                        ),
                      ),
                    ],
                  ),
                ),
                CarouselSlider.builder(
                  itemCount: recommendedMovies?.results?.length ?? 0,
                  itemBuilder: (BuildContext context, int index, int pageViewIndex) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 300,
                          height: 240,
                          margin: const EdgeInsets.only(left: 3.0, right: 3.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                  'https://image.tmdb.org/t/p/w300/${recommendedMovies?.results?[index].posterPath}'
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 13, right: 13),
                          child: Text(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            recommendedMovies?.results?[index].title ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.white,
                              fontSize: 16.2,
                              fontWeight: FontWeight.w400,
                            )
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 7),
                              child: Image.asset(
                                'assets/images/fav.png',
                                height: 30,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 7),
                              child: Image.asset(
                                'assets/images/dislike.png',
                                height: 30,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                  options: CarouselOptions(
                    height: 360.0,
                    viewportFraction: 0.55,
                    initialPage: 0,
                    enableInfiniteScroll: true,
                    reverse: false,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 8),
                    autoPlayAnimationDuration: const Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    scrollDirection: Axis.horizontal,
                    enlargeFactor: 0.23,
                  ),
                ),
                const SizedBox(height: 5),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Text(
                      'Box Office',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: Colors.white,
                        fontSize: 16.6,
                        fontWeight: FontWeight.w400,
                      )
                    ),
                  ),
                ),
                FutureBuilder(
                  future: getBoxOfficeMovies(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return CarouselSlider.builder(
                        itemCount: boxOfficeMovies?.results?.length ?? 0,
                        itemBuilder: (BuildContext context, int index,
                            int pageViewIndex) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 300,
                                height: 120,
                                margin: const EdgeInsets.only(
                                    left: 5.0, right: 5.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  image: DecorationImage(
                                    image: CachedNetworkImageProvider(
                                        'https://image.tmdb.org/t/p/w300/${boxOfficeMovies
                                            ?.results?[index].posterPath}'
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                        options: CarouselOptions(
                          height: 150.0,
                          aspectRatio: 9 / 9,
                          viewportFraction: 0.35,
                          initialPage: 3,
                          enableInfiniteScroll: true,
                          reverse: false,
                          autoPlay: true,
                          autoPlayInterval: const Duration(milliseconds: 200),
                          autoPlayAnimationDuration: const Duration(
                              milliseconds: 1900),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          scrollDirection: Axis.horizontal,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }
                    return const CircularProgressIndicator();
                  }
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
