import 'package:flutter/material.dart';
import 'package:kaloriku/view/screen/profile_page.dart';
import 'package:kaloriku/view/screen/desc_page.dart';
import 'package:kaloriku/view/screen/menu_page.dart';

class DynamicBottomNavbar extends StatefulWidget {
  const DynamicBottomNavbar({super.key});

  @override
  State<DynamicBottomNavbar> createState() => _DynamicBottomNavbarState();
}

class _DynamicBottomNavbarState extends State<DynamicBottomNavbar> {
  int _currentPageIndex = 0;

  final List<Widget> _pages = const [
    ProfilePage(),
    DescPage(),
    MenuPage(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth > 600;

        if (isWideScreen) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentPageIndex,
                  onDestinationSelected: onTabTapped,
                  backgroundColor: const Color.fromARGB(255, 16, 81, 50),
                  selectedIconTheme: const IconThemeData(color: Colors.black),
                  unselectedIconTheme: const IconThemeData(color: Colors.white),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.person),
                      label: Text('Profil'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.info),
                      label: Text('Tentang Aplikasi'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.fastfood),
                      label: Text('Food'),
                    ),
                  ],
                ),
                Expanded(child: _pages[_currentPageIndex]),
              ],
            ),
          );
        } else {
          return Scaffold(
            body: _pages[_currentPageIndex],
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _currentPageIndex,
              onTap: onTabTapped,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profil',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.info),
                  label: 'Tentang Aplikasi',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.fastfood),
                  label: 'Food',
                ),
              ],
              backgroundColor: const Color.fromARGB(255, 16, 81, 50),
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.white,
            ),
          );
        }
      },
    );
  }
}
