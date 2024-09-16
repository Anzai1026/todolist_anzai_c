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
    // Initialize the PersistentTabController here
    _controller = PersistentTabController(initialIndex: 0);
  }

  List<Widget> _buildScreens() {
    return [
      const HomePage(),
      const TodoChecklistPage(),
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
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      // Return a placeholder widget until _controller is initialized
      return Scaffold(
        body: Center(child: CircularProgressIndicator()), // Or any placeholder widget
      );
    }

    return Scaffold(
      body: PersistentTabView(
        context,
        controller: _controller!,
        screens: _buildScreens(),
        items: _navBarsItems(),
        backgroundColor: Colors.black, // 背景色
        handleAndroidBackButtonPress: true, // Androidの戻るボタンを処理
        resizeToAvoidBottomInset: true,
        stateManagement: true,
        decoration: NavBarDecoration(
          borderRadius: BorderRadius.circular(10.0),
          colorBehindNavBar: Colors.black,
        ),
        navBarStyle: NavBarStyle.style12, // ナビゲーションバーのスタイル
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // Center the FAB
    );
  }
}
