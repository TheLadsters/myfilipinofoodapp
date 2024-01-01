import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:accordion/accordion.dart';
import 'package:myfilipinofoodapp/data/ingredientMetrics.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:myfilipinofoodapp/models/meal.dart';
import 'package:myfilipinofoodapp/screens/layouts/home_screen.dart';

class EditFoodScreen extends StatefulWidget {
  const EditFoodScreen({this.id, super.key});

  final String? id;
  @override
  State<EditFoodScreen> createState() => _EditFoodScreenState();
}

class _EditFoodScreenState extends State<EditFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  List<String> ingredientList = [];
  String instructionsList = "";
  bool isSuccessful = false;
  bool isLoading = false;
  bool isInitiating = false;
  String imageUrl = "";
  XFile? _image;
  final storageRef = FirebaseStorage.instance.ref('images');
  final db = FirebaseFirestore.instance;
  late Meal currentMeal;
  final TextEditingController _dishNameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _dropdownController = TextEditingController();
  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _instructionController = TextEditingController();

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    getCurrentFood();
    super.initState();
  }

  void getCurrentFood() async {
    setState(() {
      isInitiating = true;
    });
    try {
      final currentFood =
          await db.collection("favoriteFood").doc(widget.id).get();
      if (currentFood.data() != null) {
        var foodInfo = currentFood.data();
        _dishNameController.text = foodInfo!['name'];
        setState(() {
          ingredientList = List<String>.from(foodInfo['ingredients']);
          instructionsList = foodInfo['instructions'];
          imageUrl = foodInfo['imgUrl'];
        });
      }
      print(currentFood.data());

      // currentMeal = Meal(
      //   name: foodInfo!['name'],
      //   ingredients: List<String>.from(foodInfo['ingredients']),
      //   imgUrl: foodInfo['imgUrl'],
      //   instructions: foodInfo['instructions'],
      // );
    } catch (e) {
      print(e);
    }

    setState(() {
      isInitiating = false;
    });
  }

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
    }
  }

  Future<void> _uploadAndSubmit() async {
    setState(() {
      isLoading = true;
    });
    try {
      if (_formKey.currentState!.validate()) {
        if (_image != null) {
          try {
            String filePath = _image!.path;
            File file = File(filePath);
            // Check if the file exists before attempting to upload
            if (file.existsSync()) {
              final storageRef =
                  FirebaseStorage.instance.ref('images/${_image!.name}');
              await storageRef.putFile(file);

              String downloadURL = await storageRef.getDownloadURL();

              setState(() {
                imageUrl = downloadURL;
              });

              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).clearSnackBars();
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Successfully added your food.'),
                ),
              );
            } else {
              print('File does not exist: $filePath');
            }
          } catch (e) {
            print('Error uploading image: $e');
          }
        }

        try {
          db.collection("favoriteFood").doc(widget.id).update({
            "name": _dishNameController.text,
            "ingredients": ingredientList,
            "imgUrl": imageUrl,
            "instructions": instructionsList
          });

// ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).clearSnackBars();
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully updated your food.'),
            ),
          );
          // ignore: use_build_context_synchronously
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
              (route) => false);
        } catch (e) {
          print(e);
        }
      }
    } catch (e) {
      print(e);
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _dishNameController.dispose();
    _quantityController.dispose();
    _dropdownController.dispose();
    _ingredientController.dispose();
    _instructionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: isInitiating
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _formKey,
              child: Center(
                child: SizedBox(
                  height: 800,
                  width: 400,
                  child: ListView(
                    children: [
                      Column(
                        children: [
                          // FILIPINO DISH TITLE
                          const Text(
                            'Edit Your Filipino Dish',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          // DISH NAME INPUT FIELD
                          TextFormField(
                            controller: _dishNameController,
                            decoration: const InputDecoration(
                              label: Text('Dish Name'),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a name for your dish.';
                              }
                            },
                          ),
                          const SizedBox(
                            height: 13,
                          ),
                          const Text(
                            'Dish Image',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 13,
                          ),
                          // CHOOSE DISH IMAGE
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _image == null
                                  ? const Text('No image selected')
                                  : Image.file(
                                      File(_image!.path),
                                      width: 100,
                                      height: 100,
                                    ),
                              TextButton.icon(
                                onPressed: () {
                                  _getImage(ImageSource.gallery);
                                },
                                icon: const Icon(
                                  Icons.camera_alt,
                                ),
                                label: const Text(
                                  'Choose an image',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 13,
                          ),
                          const Text(
                            'Ingredient List',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 14,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Flexible(
                                flex: 1,
                                // QUANTITY INPUT FIELD
                                child: TextFormField(
                                  controller: _quantityController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    label: Text('Quantity'),
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (ingredientList.isEmpty) {
                                      return 'Please enter a quantity.';
                                    }
                                  },
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                // METRICS DROPDOWN FIELD
                                child: DropdownMenu(
                                  initialSelection: menuEntries[0].value,
                                  controller: _dropdownController,
                                  menuHeight: 300,
                                  dropdownMenuEntries: menuEntries,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Flexible(
                                flex: 3,
                                // INGREDIENt NAME FIELD
                                child: TextFormField(
                                  controller: _ingredientController,
                                  decoration: const InputDecoration(
                                    label: Text('Ingredient Name'),
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (ingredientList.isEmpty) {
                                      return 'Please enter at least one ingredient.';
                                    }
                                  },
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                // ADD INGREDIENT BUTTON
                                child: isLoading
                                    ? const CircularProgressIndicator()
                                    : IconButton(
                                        onPressed: () {
                                          var quantity =
                                              _quantityController.text;
                                          var metric = _dropdownController.text;
                                          var ingredient =
                                              _ingredientController.text;
                                          bool isSuccessful = false;

                                          if (quantity.isNotEmpty &&
                                              ingredient.isNotEmpty) {
                                            setState(() {
                                              ingredientList.add(
                                                  '$quantity $metric $ingredient');
                                            });
                                            _quantityController.clear();
                                            _dropdownController.text =
                                                menuEntries[0].value;
                                            _ingredientController.clear();
                                            isSuccessful = true;
                                          }
                                          ScaffoldMessenger.of(context)
                                              .removeCurrentSnackBar();

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(isSuccessful
                                                  ? "Added Ingredient Successfully."
                                                  : "Please enter ingredient details."),
                                            ),
                                          );

                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                        },
                                        icon: const Icon(
                                          Icons.add_box_outlined,
                                        ),
                                        iconSize: 36,
                                      ),
                              ),
                            ],
                          ),
                          // INGREDIENT LIST ACCORDION
                          Accordion(
                            headerPadding: const EdgeInsets.all(8),
                            leftIcon: const Icon(
                              Icons.shopping_bag_sharp,
                              color: Colors.white,
                            ),
                            children: [
                              AccordionSection(
                                header: const Text(
                                  'Current Ingredients List',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                content: SizedBox(
                                  height: 100,
                                  child: GridView.count(
                                    primary: false,
                                    crossAxisCount: 2,
                                    padding: EdgeInsets.zero,
                                    mainAxisSpacing: 0.0,
                                    crossAxisSpacing: 0.0,
                                    childAspectRatio: ingredientList.isNotEmpty
                                        ? ingredientList.length.toDouble()
                                        : 1, // Adjust the aspect ratio as needed

                                    children: [
                                      for (final ingredient in ingredientList)
                                        Text(ingredient),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          const Text(
                            'Instructions List',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                // INSTRUCTION INPUT FIELD
                                child: TextFormField(
                                  controller: _instructionController,
                                  keyboardType: TextInputType.multiline,
                                  minLines: 1,
                                  maxLines: 5,
                                  decoration: const InputDecoration(
                                    label: Text('Instruction'),
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (instructionsList.isEmpty) {
                                      return 'Please enter a single instruction.';
                                    }
                                  },
                                ),
                              ),
                              Expanded(
                                // ADD INSTRUCTION
                                child: isLoading
                                    ? const CircularProgressIndicator()
                                    : IconButton(
                                        onPressed: () {
                                          if (_instructionController
                                              .text.isNotEmpty) {
                                            setState(() {
                                              instructionsList +=
                                                  " ${_instructionController.text}";
                                            });

                                            setState(() {
                                              isSuccessful = true;
                                            });
                                            _instructionController.clear();
                                          }

                                          ScaffoldMessenger.of(context)
                                              .removeCurrentSnackBar();

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(isSuccessful
                                                  ? "Added Instruction Successfully."
                                                  : "Please enter instruction details."),
                                            ),
                                          );

                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();

                                          setState(() {
                                            isSuccessful = true;
                                          });
                                        },
                                        icon: const Icon(
                                          Icons.add_box_outlined,
                                        ),
                                        iconSize: 36,
                                      ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          // CURRENT INSTRUCTIONS LIST
                          Accordion(
                            headerPadding: const EdgeInsets.all(8),
                            leftIcon: const Icon(
                              Icons.note_alt_sharp,
                              color: Colors.white,
                            ),
                            children: [
                              AccordionSection(
                                header: const Text(
                                  'Current Instructions',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                content: SizedBox(
                                  height: 100,
                                  child: ListView(
                                    children: [
                                      Text(
                                        instructionsList,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          // SUBMIT BUTTON
                          isLoading
                              ? const CircularProgressIndicator()
                              : ElevatedButton.icon(
                                  style: const ButtonStyle(
                                    minimumSize: MaterialStatePropertyAll(
                                      Size(
                                        300,
                                        50,
                                      ),
                                    ),
                                  ),
                                  onPressed: _uploadAndSubmit,
                                  icon: const Icon(
                                    Icons.add_rounded,
                                  ),
                                  label: const Text('Submit'),
                                ),
                          const SizedBox(
                            height: 24,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
