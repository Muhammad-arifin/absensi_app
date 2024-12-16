import 'package:absensi_app/absensiadmin.dart';
import 'package:absensi_app/catatanadmin.dart';
import 'package:absensi_app/cutiadmin.dart';
import 'package:flutter/material.dart';
import 'LoginPage.dart';

class AdminHomePage extends StatefulWidget {
  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0; // Keeps track of the selected section

  // List of sections (Absence, Leave, Notes)
  final List<Widget> _pages = [
    AdminPage(),
    AdminCutiPage(),
    AdminCatatanPage(),
  ];
  

  // Handles tab selection for bottom navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    // Perform logout logic here, such as clearing session, removing authentication tokens, etc.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),  // Navigate to the LoginPage
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/absen.png', // Logo
              height: 45,  // Adjust size of the logo
              width: 45,
            ),
            SizedBox(width: 10),  // Space between logo and text
            Text(
              'Admin Dashboard',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade600,
        elevation: 5.0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),  // Logout Icon
            onPressed: _logout, // Call the logout method
            tooltip: 'Logout',  // Tooltip for logout
          ),
        ],
      ),
      body: _pages[_selectedIndex], // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Display the active tab
        onTap: _onItemTapped, // Handle tap events on tabs
        backgroundColor: Colors.blue.shade600, // Matching background color
        selectedItemColor: Colors.white, // Icon and text color when tab is active
        unselectedItemColor: Colors.white70, // Icon and text color when tab is not active
        showUnselectedLabels: true, // Show labels when tab is not active
        type: BottomNavigationBarType.fixed, // Fixed design for cleaner look
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.access_alarm),
            label: 'Absensi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.beach_access),
            label: 'Cuti',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notes),
            label: 'Catatan',
          ),
        ],
      ),
    );
  }
}
