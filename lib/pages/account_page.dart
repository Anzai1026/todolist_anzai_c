import 'package:flutter/material.dart';
import '../custom_app_bar.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'PowerFocus'),
      body: Column(
        children: [
          // Profile header
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
              color: Colors.white,
            ),
            child: Row(
              children: [
                // Profile picture
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('lib/images/power.png'), // Replace with the actual image asset
                ),
                const SizedBox(width: 16),
                // Profile details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username
                      Text(
                        'Username', // Replace with actual username
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      // User info (e.g., number of posts, followers, following)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStat('Posts', '0'), // Replace with actual data
                          _buildStat('Followers', '0'), // Replace with actual data
                          _buildStat('Following', '0'), // Replace with actual data
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Bio
                      Text(
                        '',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Edit Profile button
          // Additional sections if needed
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }
}
