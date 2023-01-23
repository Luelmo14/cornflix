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
import 'MovieDetails.dart';
import 'package:flutter/services.dart';
import 'package:another_flushbar/flushbar.dart';


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
  BoxOfficeMovies? upcomingMovies;
  LocationData? locationData;
  Location _location = Location();
  String username = "alexluelmo";
  String userCity = "";
  List<String> languageCodes = [];
  List<dynamic> moviesFromCountry = [];
  RecommendedMovies? moviesFromCountryRecommended;
  Color _filterChipColor = const Color.fromRGBO(36, 37, 41, 1);
  Color _filterChipTextColor = const Color.fromRGBO(176, 176, 178, 1);
  bool _isFilterChipSelected = true;
  final homeNavigatorKey = GlobalKey<NavigatorState>();
  List<int> dismissedMovies = [];
  bool _isFirstAccess = false;

  @override
  void initState() {
    super.initState();
    _checkFirstAccess();
    getRecommendedMovies();
    getMoviesFromCountry();
    getBoxOfficeMovies();
    getUpcomingMovies();
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

  fetchUserDismissedMovies() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get()
          .then((value) {
        dismissedMovies = List<int>.from(value.data()!['dismissed_movies']);
      });
    }
  }

  getRecommendedMovies() async {
    await fetchUserFavGenres();
    await fetchUserDismissedMovies();
    Map<String, dynamic> recommendedMoviesMap = {};

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

      recommendedMoviesMap = jsonDecode(data);
      recommendedMoviesMap['results'].removeWhere((e) => e['poster_path'] == null);
      recommendedMoviesMap['results'].removeWhere((e) => dismissedMovies.contains(e['id']));

      while (recommendedMoviesMap['results'].length < 10) {
        var auxGenreIds = genreIds;
        auxGenreIds.shuffle();
        genreIds.removeLast();
        uri = 'https://api.themoviedb.org/3/discover/movie?api_key=b5f80d427803f2753428de379acc4337&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&with_genres=';
        for (var i = 0; i < genreIds.length; i++) {
          uri += genreIds[i].toString();
          if (i != genreIds.length - 1) {
            uri += '%2C';
          }
        }
        url = Uri.parse(uri);
        response = await client.get(url);

        if (response.statusCode == 200) {
          data = response.body;
          recommendedMoviesMap = jsonDecode(data);
          recommendedMoviesMap['results'].removeWhere((e) => e['poster_path'] == null);
          recommendedMoviesMap['results'].removeWhere((e) => dismissedMovies.contains(e['id']));
        } else {
          // ignore: avoid_print
          print(response.statusCode);
        }
      }
    } else {
      // ignore: avoid_print
      print(response.statusCode);
    }
    return recommendedMovies = RecommendedMovies.fromJson(recommendedMoviesMap);
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

    } else {
      // ignore: avoid_print
      print(response.statusCode);
    }
  }

  getUpcomingMovies() async {
    var client = http.Client();
    var url = Uri.parse('https://api.themoviedb.org/3/movie/upcoming?api_key=b5f80d427803f2753428de379acc4337&language=en-US&page=1');
    var response = await client.get(url);

    if (response.statusCode == 200) {
      var data = response.body;

      Map<String, dynamic> upcomingMoviesMap = jsonDecode(data);
      upcomingMoviesMap['results'].removeWhere((e) => e['poster_path'] == null);
      return upcomingMovies = BoxOfficeMovies.fromJson(upcomingMoviesMap);

    } else {
      // ignore: avoid_print
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
        });
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
    var url = Uri.parse(
        'http://api.geonames.org/countryCodeJSON?lat=${locationData!.latitude}&lng=${locationData!.longitude}&username=$username');
    var response = await client.get(url);

    if (response.statusCode == 200) {
      var data = response.body;
      Map<String, dynamic> cityAndLanguageCodeMap = jsonDecode(data);
      userCity = cityAndLanguageCodeMap['countryName'];
      languageCodes = cityAndLanguageCodeMap['languages']
          .toString().split(',').map((e) => e.split('-')[0]).toList();

      setState(() {});
    } else {
      // ignore: avoid_print
      print(response.statusCode);
    }
  }

  getMoviesFromCountry() async {
    await fetchUserDismissedMovies();
    for (String languageCode in languageCodes) {
      var client = http.Client();
      var url = Uri.parse(
          'https://api.themoviedb.org/3/discover/movie?api_key=b5f80d427803f2753428de379acc4337&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&with_original_language=$languageCode&with_watch_monetization_types=flatrate');
      var response = await client.get(url);
      if (response.statusCode == 200) {
        var data = response.body;
        List<dynamic> moviesFromCountryMap = jsonDecode(data)['results'];
        moviesFromCountryMap.removeWhere((e) => e['poster_path'] == null);
        moviesFromCountryMap.removeWhere((e) => dismissedMovies.contains(e['id']));

        moviesFromCountry.clear();
        moviesFromCountry.addAll(moviesFromCountryMap);
        moviesFromCountry.sort((a, b) => b['popularity'].compareTo(a['popularity']));
        return moviesFromCountryRecommended = RecommendedMovies.fromJson({'results': moviesFromCountry});

      } else {
        // ignore: avoid_print
        print(response.statusCode);
      }
    }
  }

  pushToMovieDetailsPage(int id) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetails(id: id, previousPage: 'Home', navigatorKey: homeNavigatorKey),
      ),
    );
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

  addDismissedMovie(int id) {
    FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'dismissed_movies': FieldValue.arrayUnion([id])
    });
  }

  _checkFirstAccess() {
    FirebaseFirestore.instance.collection('users').doc(user!.uid).get().then((value) {
      if (value.data()!['is_first_time']) {
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
      'is_first_time': false
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isFirstAccess) {
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
            'Welcome to CornFlix!',
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
            'Seems like this is your first time here. Let us show you around!',
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
            Icons.info_outline,
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
              Future.delayed(const Duration(milliseconds: 800), () {
              Flushbar(
                backgroundGradient: const LinearGradient(
                  colors: [
                    Color.fromRGBO(243, 134, 71, 22),
                    Color.fromRGBO(243, 104, 71, 22),
                    Color.fromRGBO(243, 134, 71, 22)],
                ),
                barBlur: 2.4,
                margin: const EdgeInsets.only(left: 15, right: 15, top: 40),
                borderRadius: BorderRadius.circular(15),
                flushbarPosition: FlushbarPosition.TOP,
                titleText: const Text(
                  'Recommended list for you!',
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
                  'Add to favorites with a long press or swipe down to discard!',
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
                  Icons.recommend,
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
                    Future.delayed(const Duration(milliseconds: 800), () {
                      Flushbar(
                        backgroundGradient: const LinearGradient(
                          colors: [
                            Color.fromRGBO(243, 134, 71, 22),
                            Color.fromRGBO(243, 104, 71, 22),
                            Color.fromRGBO(243, 134, 71, 22)],
                        ),
                        barBlur: 2.4,
                        margin: const EdgeInsets.only(left: 80, right: 15, top: 20),
                        borderRadius: BorderRadius.circular(15),
                        flushbarPosition: FlushbarPosition.TOP,
                        messageText: const Text(
                          'You can also filter the movies by your location!',
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
                          Icons.location_on_rounded,
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
                            Future.delayed(const Duration(milliseconds: 800), () {
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
                                  'Explore CornFlix!',
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
                                  'Find your next movie adventure and enjoy the journey!',
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
                                  Icons.movie_creation_outlined,
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
                                    'FINISH',
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
                          },
                          child: const Text(
                            'NEXT',
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
                  },
                  child: const Text(
                    'NEXT',
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
            },
            child: const Text(
              'NEXT',
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('We recommend',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.white,
                              fontSize: 16.6,
                              fontWeight: FontWeight.w400,
                              shadows: [
                                Shadow(
                                  color: Colors.black87,
                                  blurRadius: 7,
                                  offset: Offset(1.2, 1.2),
                                ),
                              ],
                            )),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_isFilterChipSelected) {
                                _isFilterChipSelected = false;
                              } else {
                                _isFilterChipSelected = true;
                                getMoviesFromCountry();
                              }
                              _filterChipColor = _isFilterChipSelected
                                  ? const Color.fromRGBO(36, 37, 41, 1) : const Color.fromRGBO(255, 56, 56, 1);
                              _filterChipTextColor = _isFilterChipSelected
                                  ? const Color.fromRGBO(176, 176, 178, 1) : const Color.fromRGBO(255, 255, 255, 1);
                            });
                          },
                          child: ChipTheme(
                            data: ChipThemeData(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                                side: const BorderSide(
                                  color: Color.fromRGBO(36, 37, 41, 1),
                                  width: 0,
                                ),
                              ),
                            ),
                            child: Chip(
                                backgroundColor: _filterChipColor,
                                label: Text('Filter by your location',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      color: _filterChipTextColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                    ))),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _isFilterChipSelected
                      ? FutureBuilder(
                          future: getRecommendedMovies(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return CarouselSlider.builder(
                                itemCount: recommendedMovies?.results?.length ?? 0,
                                itemBuilder: (BuildContext context, int index, int pageViewIndex) {
                                  var movie = recommendedMovies?.results?[index];
                                  return Dismissible(
                                    key: Key(movie?.id.toString() ?? ''),
                                    direction: DismissDirection.down,
                                    onDismissed: (direction) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${movie?.title} dismissed',
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
                                        recommendedMovies?.results?.removeAt(index);
                                      });
                                      deleteFavId(movie?.id ?? 0);
                                      addDismissedMovie(movie?.id ?? 0);
                                      getRecommendedMovies();
                                      HapticFeedback.mediumImpact();
                                    },
                                    background: Container(
                                      color: const Color.fromRGBO(23, 25, 26, 1),
                                      child: const Icon(
                                        Icons.delete,
                                        size: 190,
                                        color: Colors.white,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          highlightColor: const Color.fromRGBO(243, 134, 71, 1),
                                          splashFactory: InkRipple.splashFactory,
                                          radius: 5000,
                                          borderRadius: BorderRadius.circular(30), // Customize the border radius of the animation
                                          onLongPress: () {
                                            saveFavId(recommendedMovies?.results?[index].id ?? 0);
                                            HapticFeedback.mediumImpact();
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                              content: const Text('Added to favourites',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Inter',
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w600
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              backgroundColor: const Color.fromRGBO(243, 134, 71, 1),
                                              behavior: SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                                              dismissDirection: DismissDirection.horizontal,
                                              duration: const Duration(milliseconds: 2000),
                                            ));
                                          },
                                          child: GestureDetector(
                                            onTap: () {
                                              pushToMovieDetailsPage(recommendedMovies!.results![index].id!);
                                            },
                                            child: Container(
                                              width: 300,
                                              height: 240,
                                              margin: const EdgeInsets.only(left: 3.0, right: 3.0),
                                              decoration: BoxDecoration(
                                                boxShadow: const [
                                                  BoxShadow(
                                                    color: Colors.black45,
                                                    offset: Offset(1.3, 1.3),
                                                    blurRadius: 5.5,
                                                  ),
                                                ],
                                                borderRadius: BorderRadius.circular(14),
                                                image: DecorationImage(
                                                  image: CachedNetworkImageProvider(
                                                      'https://image.tmdb.org/t/p/w300/${recommendedMovies?.results?[index].posterPath}'),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
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
                                                shadows: [
                                                  Shadow(
                                                    color: Colors.black87,
                                                    blurRadius: 7,
                                                    offset: Offset(1.2, 1.2),
                                                  ),
                                                ],
                                              )),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                options: CarouselOptions(
                                  height: 290,
                                  viewportFraction: 0.58,
                                  initialPage: 0,
                                  enableInfiniteScroll: true,
                                  reverse: false,
                                  autoPlay: true,
                                  autoPlayInterval: const Duration(seconds: 9),
                                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                                  autoPlayCurve: Curves.fastOutSlowIn,
                                  enlargeCenterPage: true,
                                  scrollDirection: Axis.horizontal,
                                  enlargeFactor: 0.16,
                                ),
                              );
                            } else if (snapshot.hasError) {
                              return Text("${snapshot.error}");
                            }
                            return const Padding(
                              padding: EdgeInsets.only(top: 120, bottom: 120),
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(color: Color.fromRGBO(255, 56, 56, 1)),
                              ),
                            );
                          })
                      : FutureBuilder(
                      future: getMoviesFromCountry(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return CarouselSlider.builder(
                            itemCount: moviesFromCountryRecommended?.results?.length ?? 0,
                            itemBuilder: (BuildContext context, int index, int pageViewIndex) {
                              var movie = moviesFromCountryRecommended?.results?[index];
                              return Dismissible(
                                key: Key(movie?.id.toString() ?? ''),
                                direction: DismissDirection.down,
                                onDismissed: (direction) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${movie?.title} dismissed',
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
                                    moviesFromCountryRecommended?.results?.removeAt(index);
                                  });
                                  deleteFavId(movie?.id ?? 0);
                                  addDismissedMovie(movie?.id ?? 0);
                                  getMoviesFromCountry();
                                  HapticFeedback.mediumImpact();
                                },
                                background: Container(
                                  color: const Color.fromRGBO(23, 25, 26, 1),
                                  child: const Icon(
                                    Icons.delete,
                                    size: 190,
                                    color: Colors.white,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      highlightColor: const Color.fromRGBO(243, 134, 71, 1),
                                      splashFactory: InkRipple.splashFactory,
                                      radius: 5000,
                                      borderRadius: BorderRadius.circular(30), // Customize the border radius of the animation
                                      onLongPress: () {
                                        saveFavId(moviesFromCountryRecommended?.results?[index].id ?? 0);
                                        HapticFeedback.mediumImpact();
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: const Text('Added to favourites',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'Inter',
                                                fontSize: 17,
                                                fontWeight: FontWeight.w600
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          backgroundColor: const Color.fromRGBO(243, 134, 71, 1),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                                          dismissDirection: DismissDirection.horizontal,
                                          duration: const Duration(milliseconds: 2000),
                                        ));
                                      },
                                      child: GestureDetector(
                                        onTap: () {
                                          pushToMovieDetailsPage(moviesFromCountryRecommended!.results![index].id!);
                                        },
                                        child: Container(
                                          width: 300,
                                          height: 240,
                                          margin: const EdgeInsets.only(left: 3.0, right: 3.0),
                                          decoration: BoxDecoration(
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.black45,
                                                offset: Offset(1.3, 1.3),
                                                blurRadius: 5.5,
                                              ),
                                            ],
                                            borderRadius: BorderRadius.circular(14),
                                            image: DecorationImage(
                                              image: CachedNetworkImageProvider(
                                                  'https://image.tmdb.org/t/p/w300/${moviesFromCountryRecommended?.results?[index].posterPath}'),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 13, right: 13),
                                      child: Text(
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          moviesFromCountryRecommended?.results?[index].title ?? '',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            color: Colors.white,
                                            fontSize: 16.2,
                                            fontWeight: FontWeight.w400,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black87,
                                                blurRadius: 7,
                                                offset: Offset(1.2, 1.2),
                                              ),
                                            ],
                                          )),
                                    ),
                                  ],
                                ),
                              );
                            },
                            options: CarouselOptions(
                              height: 290,
                              viewportFraction: 0.58,
                              initialPage: 0,
                              enableInfiniteScroll: true,
                              reverse: false,
                              autoPlay: true,
                              autoPlayInterval: const Duration(seconds: 9),
                              autoPlayAnimationDuration: const Duration(milliseconds: 800),
                              autoPlayCurve: Curves.fastOutSlowIn,
                              enlargeCenterPage: true,
                              scrollDirection: Axis.horizontal,
                              enlargeFactor: 0.16,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }
                        return const Padding(
                          padding: EdgeInsets.only(top: 120, bottom: 120),
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: CircularProgressIndicator(color: Color.fromRGBO(255, 56, 56, 1)),
                          ),
                        );
                      }),
                  const SizedBox(height: 7),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text('Box Office',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white,
                            fontSize: 16.6,
                            fontWeight: FontWeight.w400,
                            shadows: [
                              Shadow(
                                color: Colors.black87,
                                blurRadius: 7,
                                offset: Offset(1.2, 1.2),
                              ),
                            ],
                          )),
                    ),
                  ),
                  FutureBuilder(
                      future: getBoxOfficeMovies(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return CarouselSlider.builder(
                            itemCount: boxOfficeMovies?.results?.length ?? 0,
                            itemBuilder: (BuildContext context, int index, int pageViewIndex) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      pushToMovieDetailsPage(boxOfficeMovies!.results![index].id!);
                                    },
                                    child: Container(
                                      width: 300,
                                      height: 120,
                                      margin: const EdgeInsets.only(left: 5.0, right: 5.0),
                                      decoration: BoxDecoration(
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black45,
                                            offset: Offset(1.3, 1.3),
                                            blurRadius: 5.5,
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(14),
                                        image: DecorationImage(
                                          image: CachedNetworkImageProvider(
                                              'https://image.tmdb.org/t/p/w300/${boxOfficeMovies?.results?[index].posterPath}'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                            options: CarouselOptions(
                              height: 150.0,
                              aspectRatio: 9 / 9,
                              viewportFraction: 0.33,
                              initialPage: 3,
                              enableInfiniteScroll: true,
                              reverse: false,
                              autoPlay: true,
                              autoPlayInterval: const Duration(seconds: 6),
                              autoPlayAnimationDuration: const Duration(milliseconds: 800),
                              autoPlayCurve: Curves.fastOutSlowIn,
                              scrollDirection: Axis.horizontal,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }
                        return const Padding(
                          padding: EdgeInsets.only(top: 62, bottom: 62),
                          child: SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(color: Color.fromRGBO(255, 56, 56, 1)),
                          ),
                        );
                      }),
                  const SizedBox(height: 15),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Text('Upcoming',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            color: Colors.white,
                            fontSize: 16.6,
                            fontWeight: FontWeight.w400,
                            shadows: [
                              Shadow(
                                color: Colors.black87,
                                blurRadius: 7,
                                offset: Offset(1.2, 1.2),
                              ),
                            ],
                          )),
                    ),
                  ),
                  FutureBuilder(
                      future: getUpcomingMovies(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return CarouselSlider.builder(
                            itemCount: upcomingMovies?.results?.length ?? 0,
                            itemBuilder: (BuildContext context, int index, int pageViewIndex) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      pushToMovieDetailsPage(upcomingMovies!.results![index].id!);
                                    },
                                    child: Container(
                                      width: 300,
                                      height: 120,
                                      margin: const EdgeInsets.only(left: 5.0, right: 5.0),
                                      decoration: BoxDecoration(
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black45,
                                            offset: Offset(1.3, 1.3),
                                            blurRadius: 5.5,
                                          ),
                                        ],
                                        borderRadius: BorderRadius.circular(14),
                                        image: DecorationImage(
                                          image: CachedNetworkImageProvider(
                                              'https://image.tmdb.org/t/p/w300/${upcomingMovies?.results?[index].posterPath}'),
                                          fit: BoxFit.cover,
                                          filterQuality: FilterQuality.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                            options: CarouselOptions(
                              height: 150.0,
                              aspectRatio: 9 / 9,
                              viewportFraction: 0.33,
                              initialPage: 3,
                              enableInfiniteScroll: true,
                              reverse: false,
                              autoPlay: true,
                              autoPlayInterval: const Duration(seconds: 7),
                              autoPlayAnimationDuration: const Duration(milliseconds: 800),
                              autoPlayCurve: Curves.fastOutSlowIn,
                              scrollDirection: Axis.horizontal,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }
                        return const Padding(
                          padding: EdgeInsets.only(top: 62, bottom: 62),
                          child: SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(color: Color.fromRGBO(255, 56, 56, 1)),
                          ),
                        );
                      }),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
