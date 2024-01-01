import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:myfilipinofoodapp/models/generalMealInfo.dart';
import 'package:myfilipinofoodapp/screens/details/food_details_screen.dart';

class BrowseFoodScreen extends StatefulWidget {
  const BrowseFoodScreen({super.key});

  @override
  State<BrowseFoodScreen> createState() => _BrowseFoodScreenState();
}

class _BrowseFoodScreenState extends State<BrowseFoodScreen> {
  bool isLoading = false;
  bool isError = false;
  List<GeneralMealInfo> mealInfoList = [];

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void getFilipinoFood() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    var url = Uri.https(
        'www.themealdb.com', '/api/json/v1/1/filter.php', {'a': 'Filipino'});
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
      var mealsList = jsonResponse['meals'];

      for (final meal in mealsList) {
        var generalMeal = GeneralMealInfo(
            strMeal: meal['strMeal'],
            strMealThumb: meal['strMealThumb'],
            idMeal: meal['idMeal']);
        setState(() {
          mealInfoList.add(generalMeal);
        });
      }
    } else {
      setState(() {
        isError = true;
      });

      print('Request failed with status: ${response.statusCode}.');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    getFilipinoFood();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : isError
                ? const Center(
                    child: Text(
                        'There was an error in the response. Please try again later.'),
                  )
                : Column(
                    children: [
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                        child: Text(
                          'Common Pinoy Food',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: mealInfoList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(6),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FoodDetailsScreen(
                                        foodMealId: mealInfoList[index].idMeal,
                                      ),
                                    ),
                                  );
                                },
                                contentPadding: const EdgeInsets.all(8),
                                textColor: Colors.white,
                                tileColor:
                                    const Color.fromARGB(255, 94, 63, 32),
                                leading: Image.network(
                                  mealInfoList[index].strMealThumb,
                                ),
                                title: Text(
                                  mealInfoList[index].strMeal,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
