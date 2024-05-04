import 'package:flutter/material.dart';
import 'mainscreen.dart';
import 'package:fresh_harvest/screen/buyer/userprofile.dart'; // Import UserProfile page

class PersistentBottomNav extends StatefulWidget {
  const PersistentBottomNav({super.key});

  @override
  _PersistentBottomNavState createState() => _PersistentBottomNavState();
}

class _PersistentBottomNavState extends State<PersistentBottomNav> {
  int _selectedIndex = 0;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  static final List<Widget> _screens = [
    const MainScreen(),
    const UserProfile(), // Added UserProfile page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _navigatorKey.currentState?.popUntil((route) => route.isFirst);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fresh Harvest')),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
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
    );
  }
}
