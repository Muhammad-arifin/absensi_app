import 'package:flutter/material.dart';
import 'absensi.dart';    // Import Absence section
import 'cuti.dart';       // Import Leave section
import 'catatan.dart';    // Import Notes section
import 'LoginPage.dart';  // Import Login Page (or your actual login page)

class UserDashboardPage extends StatefulWidget {
  @override
  _UserDashboardPageState createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage> {
  int _selectedIndex = 0;  // Keeps track of the selected section

  // List of sections (Absence, Leave, Notes)
  final List<Widget> _pages = [
    UserPage(),
    UserCutiPage(),
    UserCatatanPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Logout method that clears the session and redirects to login page
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
              'assets/images/absen.png',  // Ensure your logo is in the assets folder and specified in pubspec.yaml
              height: 45,  // Adjust size of the logo as needed
              width: 45,
            ),
            SizedBox(width: 10),  // Space between logo and text
            Text(
              'Absence',
              style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade600, // Teal-like color for consistency
        elevation: 5.0, // Gives a slight shadow effect to AppBar
        actions: [
          IconButton(
            icon: Icon(Icons.logout),  // Logout Icon
            onPressed: _logout, // Call the logout method
            tooltip: 'Logout',  // Tooltip for logout
          ),
        ],
      ),
      body: _pages[_selectedIndex], // Displaying the selected screen
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
