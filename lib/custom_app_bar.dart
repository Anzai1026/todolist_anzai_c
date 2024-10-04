import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  const CustomAppBar({
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: Center(
        child: Transform.translate(
          offset: Offset(-100, 25), // Adjust vertical offset
          child: ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [Colors.black, Colors.red],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            child: Text(
              title,
              style: GoogleFonts.rockSalt(
                fontSize: 24, // Adjusted font size
                fontWeight: FontWeight.bold,
                color: Colors.white, // Color will be overridden by gradient
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pushNamed('/calendar');
          },
          icon: const Icon(Icons.calendar_today_outlined),
          color: Colors.black,
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pushNamed('/deleted_tasks');
          },
          icon: const Icon(Icons.access_time_outlined),
          color: Colors.black,
        ),
        IconButton(
          onPressed: signUserOut, icon: Icon(Icons.exit_to_app),
          color: Colors.black,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70.0); // Adjust height as needed
}
