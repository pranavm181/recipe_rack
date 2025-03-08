// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_rack/utils/custombuttons.dart';
import 'dart:io';

import 'package:recipe_rack/utils/customtext.dart';

class AddRecipeScreen extends StatefulWidget {
  final String? recipeId;
  final Map<String, dynamic>? initialRecipe;
  const AddRecipeScreen({super.key, this.recipeId, this.initialRecipe});

  @override
  AddRecipeScreenState createState() => AddRecipeScreenState();
}

class AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _cookingTimeController = TextEditingController();
  final _servingsController = TextEditingController();
  File? _image;
  String? _selectedCategory;

  final List<String> _categories = [
    'Main Course',
    'Appetizers',
    'Desserts',
    'Snacks',
    'Drinks'
  ];

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _addRecipe() async {
    if (!_formKey.currentState!.validate() ||
        _image == null ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields & select an image')),
      );
      return;
    }

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }
      String imageUrl = '';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('recipe_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await storageRef.putFile(_image!);
      imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('recipes').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'ingredients': _ingredientsController.text.trim().split('\n'),
        'instructions': _instructionsController.text.trim().split('\n'),
        'cookingTime': _cookingTimeController.text.trim(),
        'servings': _servingsController.text.trim(),
        'category': _selectedCategory,
        'imageUrl': imageUrl,
        'createdAt': Timestamp.now(),
        'userId': userId,
        'ratings': [],
        'reviews': [],
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Recipe added successfully!')));
      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add recipe: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        title: Customtext(
          text: 'Add Recipe',
          color: Colors.white,
          weight: FontWeight.bold,
        ),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black)),
                  child: _image == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo,
                                size: 50, color: Colors.purple),
                            Customtext(
                              text: 'Select an Photo',
                              color: Colors.purple,
                            )
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        ),
                ),
              ),
              SizedBox(height: 16),
              _buildTextField(_titleController, 'Title'),
              _buildTextField(_descriptionController, 'Description'),
              _buildTextField(
                  _ingredientsController, 'Ingredients (one per line)',
                  maxLines: 3),
              _buildTextField(
                  _instructionsController, 'Instructions (one per line)',
                  maxLines: 5),
              _buildTextField(
                  _cookingTimeController, 'Cooking Time (e.g., 30 mins)'),
              _buildTextField(
                  _servingsController, 'Servings (e.g., 4 servings)'),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                    labelText: 'Category', border: OutlineInputBorder()),
                items: _categories
                    .map((category) => DropdownMenuItem(
                        value: category, child: Text(category)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCategory = value),
                validator: (value) =>
                    value == null ? 'Please select a category' : null,
              ),
              SizedBox(height: 20),
              Custombutton(
                ontap: _addRecipe,
                color: Colors.purple,
                height: 40,
                width: double.infinity,
                child: Center(
                  child: Customtext(
                    text: 'Add Recipe',
                    size: 17,
                    color: Colors.white,
                    weight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        maxLines: maxLines,
        validator: (value) =>
            value == null || value.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }
}
