import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myfilipinofoodapp/models/meal.dart';

class MyFoodDetailsScreen extends StatefulWidget {
  const MyFoodDetailsScreen({this.id, super.key});
  final String? id;

  @override
  State<MyFoodDetailsScreen> createState() => _MyFoodDetailsScreenState();
}

class _MyFoodDetailsScreenState extends State<MyFoodDetailsScreen> {
  bool isLoading = false;
  bool isError = false;
  late Meal mealInfo;
  final db = FirebaseFirestore.instance;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void getMyFilipinoFood() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      await db
          .collection("favoriteFood")
          .doc(widget.id)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          Map<String, dynamic> mealSpecifics =
              documentSnapshot.data() as Map<String, dynamic>;

          setState(() {
            mealInfo = Meal(
              name: mealSpecifics['name'],
              ingredients: List<String>.from(mealSpecifics['ingredients']),
              imgUrl: mealSpecifics['imgUrl'],
              instructions: mealSpecifics['instructions'],
            );
          });
        } else {
          print("Document does not exist");
        }
      });
    } catch (e) {
      print(e);
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    getMyFilipinoFood();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SizedBox(
              width: 400,
              height: 800,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        mealInfo.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Image.network(
                        mealInfo.imgUrl,
                        height: 250,
                        width: 250,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Ingredients',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (var ingredient in mealInfo.ingredients)
                        Text(ingredient),
                      const SizedBox(height: 12),
                      const Text(
                        'Instructions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(mealInfo.instructions),
                      const SizedBox(height: 12),
                    ],
                  )
                ],
              ),
            ),
    );
  }
}
