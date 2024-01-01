import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(alignment: AlignmentDirectional.center, children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20.0), //add border radius
          child: Image.asset(
            "assets/beefsteak.jpg",
            height: 100.0,
            width: 300.0,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          'MY FILIPINO FOOD APP',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black, // Choose the color of the shadow
                blurRadius: 2.0, // Adjust the blur radius for the shadow effect
                offset: Offset(2.0,
                    2.0), // Set the horizontal and vertical offset for the shadow
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
