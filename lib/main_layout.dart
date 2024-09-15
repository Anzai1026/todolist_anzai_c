import 'package:PowerTask/pages/home_page.dart';
import 'package:PowerTask/pages/todo_checklist_page.dart';
import 'package:flutter/material.dart';
import "package:google_nav_bar/google_nav_bar.dart";

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0; // Track the selected index

  // List of pages for the navigation
  final List<Widget> _pages = [
    const HomePage(),
    const TodoChecklistPage(),
  ];

  // Titles for the app bar based on the selected index

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
          child: GNav(
            backgroundColor: Colors.black,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.grey.shade800,
            gap: 8,
            padding: const EdgeInsets.all(16),
            tabs: const [
              GButton(
                icon: Icons.home,
                text: 'Tasks',
              ),
              GButton(
                icon: Icons.check_box,
                text: 'Checklist',
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: _onItemTapped, // Handle tab change
          ),
        ),
      ),
    );
  }
}
