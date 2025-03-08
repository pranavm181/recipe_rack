// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recipe_rack/screens/add_recipe.dart';
import 'package:recipe_rack/screens/recipe_detail_screen.dart';
import 'package:recipe_rack/utils/customtext.dart';
import 'package:recipe_rack/utils/fade_in.dart';
import 'package:recipe_rack/utils/slide.dart';

class Myrecipe extends StatelessWidget {
  Myrecipe({super.key});
  final userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SlideDownAppBar(
        child: AppBar(
          automaticallyImplyLeading: false,
          leading: Icon(
            Icons.restaurant_menu,
            size: 27,
            color: Colors.white,
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddRecipeScreen()),
                );
              },
              icon: Icon(
                Icons.add,
                size: 25,
                color: Colors.white,
              ),
            ),
          ],
          title: Customtext(
            text: 'My Recipes',
            color: Colors.white,
            weight: FontWeight.bold,
          ),
          backgroundColor: Colors.purple,
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: userId != null
            ? FirebaseFirestore.instance
                .collection('recipes')
                .where('userId', isEqualTo: userId)
                .snapshots()
            : null,
        builder: (context, snapshot) {
          if (userId == null) {
            return Center(
              child: Text('Please log in to view your recipes.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final recipes = snapshot.data!.docs;

          if (recipes.isEmpty) {
            return Center(child: Text('No recipes found.'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index].data() as Map<String, dynamic>;
              final recipeId = recipes[index].id;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailScreen(
                        recipe: recipe,
                        recipeId: recipeId,
                      ),
                    ),
                  );
                },
                child: FadeInRecipeCard(
                  child: Card(
                    elevation: 10,
                    color: Colors.white,
                    margin: EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.network(
                            recipe['imageUrl'],
                            fit: BoxFit.cover,
                            height: 150,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/img/th.jpeg',
                                fit: BoxFit.cover,
                                height: 150,
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Customtext(
                                    text: recipe['title'],
                                    size: 18,
                                    color: Colors.purple,
                                    weight: FontWeight.bold,
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          _editRecipe(
                                              context, recipeId, recipe);
                                        },
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.purple,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          _deleteRecipe(context, recipeId);
                                        },
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Text(
                                recipe['description'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _editRecipe(
      BuildContext context, String recipeId, Map<String, dynamic> recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddRecipeScreen(
          recipeId: recipeId,
          initialRecipe: recipe,
        ),
      ),
    );
  }

  void _deleteRecipe(BuildContext context, String recipeId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Recipe'),
          content: Text('Are you sure you want to delete this recipe?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('recipes')
                      .doc(recipeId)
                      .delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Recipe deleted successfully!')),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete recipe: $e')),
                  );
                }
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
