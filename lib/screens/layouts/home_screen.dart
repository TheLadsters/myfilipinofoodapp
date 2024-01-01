import 'package:flutter/material.dart';
import 'package:myfilipinofoodapp/routes/destinations.dart';
import 'package:myfilipinofoodapp/routes/pages.dart';
import 'package:myfilipinofoodapp/screens/add_food_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: currentPageIndex == 0
          ? AppBar(
              actions: [
                IconButton(
                  style: const ButtonStyle(
                    iconSize: MaterialStatePropertyAll(34),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AddFoodScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline),
                ),
                const SizedBox(width: 10),
              ],
            )
          : null,
      backgroundColor: Colors.white,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.amber,
        selectedIndex: currentPageIndex,
        destinations: destinations,
      ),
      body: Center(
        child: pages[currentPageIndex],
      ),
    );
  }
}
