import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myfilipinofoodapp/models/meal.dart';
import 'package:myfilipinofoodapp/screens/details/my_food_details_screen.dart';
import 'package:myfilipinofoodapp/screens/edit_food_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Meal> mealList = [];
  final db = FirebaseFirestore.instance;
  bool isLoading = false;

  void getAllFavoriteFood() async {
    setState(() {
      isLoading = true;
    });

    try {
      await db.collection("favoriteFood").get().then((event) {
        for (var food in event.docs) {
          var newMeal = Meal(
            id: food.id,
            name: food.data()['name'],
            ingredients: List<String>.from(food.data()['ingredients']),
            imgUrl: food.data()['imgUrl'],
            instructions: food.data()['instructions'],
          );
          mealList.add(newMeal);
        }
      });
    } catch (e) {
      print(e);
    }

    setState(() {
      isLoading = false;
    });
  }

  void _deleteFavoriteFood(currentIdx) async {
    setState(() {
      isLoading = true;
    });
    try {
      await db
          .collection("favoriteFood")
          .doc(mealList[currentIdx].id)
          .delete()
          .then(
        (doc) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully deleted your food.'),
            ),
          );

          Navigator.popAndPushNamed(context, '/homepage');
        },
        onError: (e) => print("Error updating document $e"),
      );
    } catch (e) {
      print(e);
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    getAllFavoriteFood();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: width,
            maxHeight: height,
          ),
          child: Column(
            children: [
              const SizedBox(
                height: 18,
              ),
              const Text(
                'Your Filipino Food',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : mealList.isEmpty
                        ? const Center(
                            child: Text(
                                'You have no saved favorite Filipino food.'),
                          )
                        : ListView.builder(
                            itemCount: mealList.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            MyFoodDetailsScreen(
                                                id: mealList[index].id),
                                      ),
                                    );
                                  },
                                  contentPadding: const EdgeInsets.all(8),
                                  textColor: Colors.white,
                                  tileColor:
                                      const Color.fromARGB(255, 94, 63, 32),
                                  leading: Image.network(
                                    mealList[index].imgUrl,
                                  ),
                                  title: Text(
                                    mealList[index].name,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  EditFoodScreen(
                                                id: mealList[index].id,
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.edit,
                                          color:
                                              Color.fromARGB(255, 83, 134, 245),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          _deleteFavoriteFood(index);
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color:
                                              Color.fromARGB(255, 226, 89, 89),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
