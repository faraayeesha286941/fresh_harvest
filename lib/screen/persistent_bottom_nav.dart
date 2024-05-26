import 'package:flutter/material.dart';
import 'mainscreen.dart';
import 'package:fresh_harvest/screen/buyer/userprofile.dart'; // Import UserProfile page
import 'package:fresh_harvest/screen/buyer/cartscreen.dart'; // Import CartScreen

class PersistentBottomNav extends StatefulWidget {
  const PersistentBottomNav({super.key});

  @override
  _PersistentBottomNavState createState() => _PersistentBottomNavState();
}

class _PersistentBottomNavState extends State<PersistentBottomNav> {
  int _selectedIndex = 0;
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab = !await _navigatorKeys[_selectedIndex].currentState!.maybePop();
        if (isFirstRouteInCurrentTab) {
          if (_selectedIndex != 0) {
            _onItemTapped(0);
            return false;
          }
        }
        return isFirstRouteInCurrentTab;
      },
      child: Scaffold(
        body: Stack(
          children: _navigatorKeys.map((navigatorKey) {
            int index = _navigatorKeys.indexOf(navigatorKey);
            return Offstage(
              offstage: _selectedIndex != index,
              child: Navigator(
                key: navigatorKey,
                onGenerateRoute: (routeSettings) {
                  switch (index) {
                    case 0:
                      return MaterialPageRoute(
                        builder: (BuildContext context) => const MainScreen(),
                      );
                    case 1:
                      return MaterialPageRoute(
                        builder: (BuildContext context) => CartScreen(),
                      );
                    case 2:
                      return MaterialPageRoute(
                        builder: (BuildContext context) => PlaceholderScreen(title: 'My Mail'),
                      );
                    case 3:
                      return MaterialPageRoute(
                        builder: (BuildContext context) => const UserProfile(),
                      );
                    default:
                      return MaterialPageRoute(
                        builder: (BuildContext context) => const MainScreen(),
                      );
                  }
                },
              ),
            );
          }).toList(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'My Cart'),
            BottomNavigationBarItem(icon: Icon(Icons.mail), label: 'My Mail'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

// Placeholder Screen
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Text('This is the $title screen'),
      ),
    );
  }
}
