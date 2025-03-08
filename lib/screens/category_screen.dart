// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_rack/utils/customtext.dart';
import 'recipe_detail_screen.dart';

class CategoryRecipesScreen extends StatelessWidget {
  final String category;

  const CategoryRecipesScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.purple,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              )),
          title: Customtext(
            text: category,
            color: Colors.white,
            weight: FontWeight.bold,
          )),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('recipes')
            .where('category', isEqualTo: category)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final recipes = snapshot.data!.docs;

          if (recipes.isEmpty) {
            return Center(child: Text('No recipes found in this category.'));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index].data() as Map<String, dynamic>;
              return GestureDetector(
                onTap: () {
                 
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailScreen(
                        recipe: recipe,
                        recipeId: recipes[index].id,
                      ),
                    ),
                  );
                },
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
                            Customtext(
                              text: recipe['title'],
                              size: 18,
                              color: Colors.purple,
                              weight: FontWeight.bold,
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
              );
            },
          );
        },
      ),
    );
  }
}
