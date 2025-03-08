// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:recipe_rack/utils/customtext.dart';
import 'package:recipe_rack/utils/fade_in.dart';
import 'package:recipe_rack/utils/slide.dart';
import 'recipe_detail_screen.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: SlideDownAppBar(
        child: AppBar(
          backgroundColor: Colors.purple,
          automaticallyImplyLeading: false,
          title: Customtext(
            text: 'Favorites',
            color: Colors.white,
            weight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: userId != null
            ? FirebaseFirestore.instance
                .collection('wishlist')
                .where('userId', isEqualTo: userId)
                .snapshots()
            : null,
        builder: (context, wishlistSnapshot) {
          if (userId == null) {
            return Center(
              child: Text('Please log in to view your favorites.'),
            );
          }

          if (wishlistSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (wishlistSnapshot.hasError) {
            return Center(child: Text('Error: ${wishlistSnapshot.error}'));
          }

          final wishlistItems = wishlistSnapshot.data!.docs;

          if (wishlistItems.isEmpty) {
            return Center(child: Text('No favorites found.'));
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('recipes')
                .where('title',
                    whereIn: wishlistItems.map((doc) => doc['title']).toList())
                .snapshots(),
            builder: (context, recipesSnapshot) {
              if (recipesSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (recipesSnapshot.hasError) {
                return Center(child: Text('Error: ${recipesSnapshot.error}'));
              }

              final recipes = recipesSnapshot.data!.docs;

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
                          builder: (context) =>
                              RecipeDetailScreen(recipe: recipe),
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
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
