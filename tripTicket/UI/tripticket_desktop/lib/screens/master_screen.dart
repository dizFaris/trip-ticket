import 'package:flutter/material.dart';
import 'package:tripticket_desktop/models/menu_model.dart';
import 'package:tripticket_desktop/providers/auth_provider.dart';
import 'package:tripticket_desktop/screens/countries_screen.dart';
import 'package:tripticket_desktop/screens/purchases_screen.dart';
import 'package:tripticket_desktop/screens/statistics_screen.dart';
import 'package:tripticket_desktop/screens/ticket_activation_screen.dart';
import 'package:tripticket_desktop/screens/trips_screen.dart';
import 'package:tripticket_desktop/screens/users_screen.dart';

final GlobalKey<MasterScreenState> masterScreenKey =
    GlobalKey<MasterScreenState>();

class MasterScreen extends StatefulWidget {
  const MasterScreen({super.key});

  @override
  State<MasterScreen> createState() => MasterScreenState();
}

final List<DrawerItem> drawerItems = [
  DrawerItem(title: 'Trips Overview', screen: TripsScreen()),
  DrawerItem(title: 'Activate Tickets', screen: TicketActivationScreen()),
  DrawerItem(title: 'Edit Countries and Cities', screen: CountriesScreen()),
  DrawerItem(title: 'Purchases', screen: PurchasesScreen()),
  DrawerItem(title: 'Users', screen: UsersScreen()),
  DrawerItem(title: 'Reports', screen: StatisticsScreen()),
];

class MasterScreenState extends State<MasterScreen> {
  Widget _selectedScreen = TripsScreen();
  int _selectedIndex = 0;

  void _changeScreen(int index) {
    setState(() {
      _selectedIndex = index;
      _selectedScreen = drawerItems[index].screen;
    });
    Navigator.pop(context);
  }

  void navigateTo(Widget screen) {
    setState(() {
      _selectedIndex = -1;
      _selectedScreen = screen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TripTicket"),
        actions: [
          Row(
            children: [
              Text(
                AuthProvider.username ?? "Guest",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              SizedBox(width: 8),
              Icon(Icons.person),
              SizedBox(width: 32),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            Container(
              height: 70,
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Menu",
                style: TextStyle(fontSize: 22, color: Colors.white),
              ),
            ),
            ...drawerItems.asMap().entries.map((entry) {
              int index = entry.key;
              DrawerItem item = entry.value;

              return ListTile(
                title: Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: _selectedIndex == index
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                selected: _selectedIndex == index,
                onTap: () => _changeScreen(index),
              );
            }),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text("Logout"),
              onTap: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _selectedScreen,
    );
  }
}
