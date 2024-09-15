import 'package:flutter/material.dart';
import 'package:flutter_gradient_app_bar/flutter_gradient_app_bar.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GradientAppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 35,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      gradient: const LinearGradient(
        colors: [Colors.black, Colors.red],
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/calendar');
          },
          icon: const Icon(Icons.calendar_today_outlined),
          color: Colors.white,
        ),
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/deleted_tasks');
          },
          icon: const Icon(Icons.access_time_outlined),
          color: Colors.white,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
