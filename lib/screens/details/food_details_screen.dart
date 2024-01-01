import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myfilipinofoodapp/models/meal.dart';

class FoodDetailsScreen extends StatefulWidget {
  FoodDetailsScreen({super.key, required this.foodMealId});

  late final String foodMealId;

  @override
  State<FoodDetailsScreen> createState() => _FoodDetailsScreenState();
}

class _FoodDetailsScreenState extends State<FoodDetailsScreen> {
  late Meal currentPinoyMeal;
  bool isLoading = false;
  bool isError = false;

  void getMealDetails() async {
    setState(() {
      isLoading = true;
    });
    var url = Uri.https(
      'www.themealdb.com',
      '/api/json/v1/1/lookup.php',
      {'i': widget.foodMealId},
    );
    var response = await http.get(url);
    if (response.statusCode == 200) {
      int ctr = 1;
      List<String> ingredientList = [];
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      var mealDetails = jsonResponse['meals'][0];

      for (; mealDetails['strMeasure$ctr'] != " "; ctr++);

      for (var i = 1; i < ctr; i++) {
        ingredientList.add(
            mealDetails['strMeasure$i'] + ' ' + mealDetails['strIngredient$i']);
      }

      currentPinoyMeal = Meal(
        name: mealDetails['strMeal'],
        ingredients: ingredientList,
        imgUrl: mealDetails['strMealThumb'],
        instructions: mealDetails['strInstructions'],
      );
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    getMealDetails();
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
                padding: EdgeInsets.all(12),
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currentPinoyMeal.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Image.network(
                        currentPinoyMeal.imgUrl,
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
                      for (var ingredient in currentPinoyMeal.ingredients)
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
                      Text(currentPinoyMeal.instructions),
                      const SizedBox(height: 12),
                    ],
                  )
                ],
              ),
            ),
    );
  }
}
