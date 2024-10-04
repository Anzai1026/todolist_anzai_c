import 'package:Power_Focus/pages/account_page.dart';
import 'package:Power_Focus/pages/home_page.dart';
import 'package:Power_Focus/pages/todo_checklist_page.dart';
import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  PersistentTabController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = PersistentTabController(initialIndex: 0);
  }

  List<Widget> _buildScreens() {
    return [
      const HomePage(),
      const TodoChecklistPage(),
      const AccountPage(), // Add AccountPage here
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.home),
        title: "Tasks",
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.grey,
        activeColorSecondary: Colors.redAccent,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.check_box),
        title: "Checklist",
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.grey,
        activeColorSecondary: Colors.redAccent,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.person_pin),
        title: "Account",
        activeColorPrimary: Colors.white,
        inactiveColorPrimary: Colors.grey,
        activeColorSecondary: Colors.redAccent,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PersistentTabView(
        context,
        controller: _controller!,
        screens: _buildScreens(),
        items: _navBarsItems(),
        backgroundColor: Colors.black,
        handleAndroidBackButtonPress: true,
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(10.0),
          colorBehindNavBar: Colors.black,
        ),
        navBarStyle: NavBarStyle.style12,
      ),
    );
  }
}
