import 'package:corn_flix/pages/Favorites.dart';
import 'package:flutter/material.dart';
import '../pages/Home.dart';
import '../pages/Profile.dart';
import '../pages/Search.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int index = 0;
  final pages = [const Home(), Search(), Favorites(), Profile()];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: pages[index],
    bottomNavigationBar: Container(
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(
          top: BorderSide(
            color: Color.fromRGBO(243, 134, 71, 1),
            width: 2,
          ),
        ),
      ),
      child: SizedBox(
        height: 78,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: index,
          backgroundColor: const Color.fromRGBO(36, 37, 41, 1),
          onTap: (index) => setState(() => this.index = index),
          selectedItemColor: const Color.fromRGBO(243, 134, 71, 1),
          unselectedItemColor: Colors.white,
          iconSize: 25,
          unselectedLabelStyle: const TextStyle(fontSize: 13.2, fontFamily: 'Inter', fontWeight: FontWeight.w400),
          selectedLabelStyle: const TextStyle(fontSize: 13.2, fontFamily: 'Inter'),
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: ImageIcon(
                  AssetImage('assets/images/whiteHome.png'),
                ),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: ImageIcon(
                  AssetImage('assets/images/orangeHome.png'),
                ),
              ),
              label: 'Home'
            ),
            BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: ImageIcon(
                    AssetImage('assets/images/whiteSearch.png'),
                  ),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: ImageIcon(
                    AssetImage('assets/images/orangeSearch.png'),
                  ),
                ),
                label: 'Search'
            ),
            BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: ImageIcon(
                    AssetImage('assets/images/whiteFavs.png'),
                  ),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: ImageIcon(
                    AssetImage('assets/images/orangeFavs.png'),
                  ),
                ),
                label: 'Favorites'
            ),
            BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: ImageIcon(
                    AssetImage('assets/images/whiteProfile.png'),
                  ),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 5),
                  child: ImageIcon(
                    AssetImage('assets/images/orangeProfile.png'),
                  ),
                ),
                label: 'Profile'
            ),
          ],
        ),
      ),
    ),
  );
}