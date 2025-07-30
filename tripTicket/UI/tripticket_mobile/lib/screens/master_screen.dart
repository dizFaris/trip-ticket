import 'package:flutter/material.dart';
import 'package:tripticket_mobile/app_colors.dart';
import 'package:tripticket_mobile/screens/bookmarks_screen.dart';
import 'package:tripticket_mobile/screens/purchases_screen.dart';
import 'package:tripticket_mobile/screens/trips_screen.dart';
import 'package:tripticket_mobile/screens/user_screen.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({super.key});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    TripsScreen(),
    BookmarksScreen(),
    PurchasesScreen(),
    UserScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: SizedBox(
          height: 90,
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            backgroundColor: AppColors.primaryGreen,
            selectedItemColor: AppColors.primaryYellow,
            unselectedItemColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            iconSize: 30,
            onTap: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Trips'),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark),
                label: 'Bookmarks',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: 'Purchases',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
            ],
          ),
        ),
      ),
    );
  }
}
