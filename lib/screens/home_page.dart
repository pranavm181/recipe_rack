// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:recipe_rack/screens/account.dart';
import 'package:recipe_rack/screens/category_screen.dart';
import 'package:recipe_rack/screens/favorites.dart';
import 'package:recipe_rack/screens/myrecipe.dart';
import 'package:recipe_rack/screens/recipe_search.dart';
import 'package:recipe_rack/utils/customtext.dart';
import 'package:recipe_rack/utils/fade_in.dart';
import 'package:recipe_rack/utils/slide.dart';
import 'package:recipe_rack/utils/staggered.dart';
import 'recipe_detail_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {
      'id': '1',
      'name': 'Main Course',
      'imageUrl': 'assets/img/main_course.jpg',
    },
    {
      'id': '2',
      'name': 'Appetizers',
      'imageUrl': 'assets/img/Appetizer.jpg',
    },
    {
      'id': '3',
      'name': 'Desserts',
      'imageUrl': 'assets/img/dessert.jpg',
    },
    {
      'id': '4',
      'name': 'Drinks',
      'imageUrl': 'assets/img/Drinks.jpeg',
    },
    {
      'id': '5',
      'name': 'Snacks',
      'imageUrl': 'assets/img/snacks.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 0
          ? SlideDownAppBar(
              child: AppBar(
                elevation: 10,
                backgroundColor: Colors.purple,
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    SizedBox(width: 10),
                    Icon(
                      Icons.restaurant_menu,
                      size: 30,
                      color: Colors.white,
                    ),
                    SizedBox(width: 20),
                    Customtext(
                      text: 'RECIPE RACK',
                      color: Colors.white,
                      size: 20,
                      weight: FontWeight.bold,
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      showSearch(
                        context: context,
                        delegate: RecipeSearchDelegate(),
                      );
                    },
                    icon: Icon(
                      Icons.search,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            )
          : null,
      body: _buildBody(),
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Colors.purple,
        style: TabStyle.flip,
        initialActiveIndex: _selectedIndex,
        activeColor: Colors.white,
        color: Colors.white,
        elevation: 10,
        items: [
          TabItem(icon: Icons.home, title: 'Home'),
          TabItem(icon: Icons.favorite, title: 'Favorites'),
          TabItem(icon: Icons.restaurant_menu, title: 'My Recipes'),
          TabItem(icon: Icons.account_circle, title: 'Account'),
        ],
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Customtext(
                  text: 'Popular Recipes',
                  color: Colors.purple,
                  size: 20,
                  weight: FontWeight.bold,
                ),
                SizedBox(height: 10),
                _buildPopularRecipesSection(),
                SizedBox(height: 15),
                Customtext(
                  text: 'Categories',
                  color: Colors.purple,
                  size: 20,
                  weight: FontWeight.bold,
                ),
                SizedBox(height: 10),
                _buildCategoriesSection(),
              ],
            ),
          ),
        );
      case 1:
        return FavoritesPage();
      case 2:
        return Myrecipe();
      case 3:
        return AccountPage();
      default:
        return Center(child: Text('Invalid Selection'));
    }
  }

  Widget _buildPopularRecipesSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('recipes').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final recipes = snapshot.data!.docs;

        return SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index].data() as Map<String, dynamic>;
              return FadeInRecipeCard(
                duration: Duration(milliseconds: 300 * index),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(recipe: recipe),
                      ),
                    );
                  },
                  child: Container(
                    width: 150,
                    height: 150,
                    margin: EdgeInsets.only(right: 16),
                    child: Card(
                      elevation: 10,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Image.network(
                                recipe['imageUrl'],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/img/th.jpeg',
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Customtext(
                                text: recipe['title'],
                                size: 17,
                                color: Colors.black,
                                weight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            return StaggeredCategoryCard(
              delay: Duration(milliseconds: 200 * index),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryRecipesScreen(
                        category: category['name'],
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 150,
                  margin: EdgeInsets.only(right: 16),
                  child: Card(
                    elevation: 10,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: Image.asset(
                              category['imageUrl'],
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/placeholder.jpg',
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Customtext(
                              text: category['name'],
                              size: 17,
                              color: Colors.black,
                              weight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}