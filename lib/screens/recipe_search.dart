// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recipe_rack/utils/customtext.dart';
import 'recipe_detail_screen.dart';

class RecipeSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return Center(
        child: Text('Enter a search term to find recipes.'),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('recipes')
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan: '${query}z')
          .snapshots(),
      builder: (context, titleSnapshot) {
        if (titleSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (titleSnapshot.hasError) {
          return Center(child: Text('Error: ${titleSnapshot.error}'));
        }

        final titleRecipes = titleSnapshot.data!.docs;

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('recipes')
              .where('ingredients', arrayContains: query)
              .snapshots(),
          builder: (context, ingredientSnapshot) {
            if (ingredientSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (ingredientSnapshot.hasError) {
              return Center(child: Text('Error: ${ingredientSnapshot.error}'));
            }

            final ingredientRecipes = ingredientSnapshot.data!.docs;
            final allRecipes = [...titleRecipes, ...ingredientRecipes];
            final uniqueRecipes = allRecipes.toSet().toList();

            if (uniqueRecipes.isEmpty) {
              return Center(child: Text('No recipes found.'));
            }

            return ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: uniqueRecipes.length,
              itemBuilder: (context, index) {
                final recipe =
                    uniqueRecipes[index].data() as Map<String, dynamic>;
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RecipeDetailScreen(recipe: recipe),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
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
                                color: Colors.black,
                                weight: FontWeight.bold,
                              ),
                              SizedBox(height: 4),
                              Text(
                                recipe['description'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
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
        );
      },
    );
  }
}
