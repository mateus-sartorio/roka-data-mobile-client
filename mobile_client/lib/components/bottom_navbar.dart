import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class BottomNavbar extends StatelessWidget {
  final Function(int)? onTabChange;

  const BottomNavbar({Key? key, required this.onTabChange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GNav(
          padding: const EdgeInsets.all(15),
          color: Colors.grey,
          activeColor: Colors.black,
          tabActiveBorder: Border.all(color: Colors.grey[200]!),
          tabBackgroundColor: Colors.grey[200]!,
          mainAxisAlignment: MainAxisAlignment.center,
          onTabChange: (value) => onTabChange!(value),
          tabBorderRadius: 15,
          tabs: const [
            GButton(
              icon: Icons.shopping_bag_rounded,
              text: " Coleta",
            ),
            GButton(
              icon: Icons.cloud_sync,
              text: " Sincronizar",
            ),
            GButton(
              icon: Icons.monetization_on_rounded,
              text: " Moeda",
            ),
          ]),
    );
  }
}
