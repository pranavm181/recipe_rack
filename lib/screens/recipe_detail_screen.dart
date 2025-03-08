// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'package:recipe_rack/providers/wish_list_provider.dart';
import 'package:recipe_rack/utils/custombuttons.dart';
import 'package:recipe_rack/utils/customtext.dart';
import 'package:share_plus/share_plus.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Map<String, dynamic> recipe;
  final String? recipeId;

  const RecipeDetailScreen({super.key, required this.recipe, this.recipeId});

  @override
  RecipeDetailScreenState createState() => RecipeDetailScreenState();
}

class RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final _ratingController = TextEditingController();
  final _reviewController = TextEditingController();

  @override
  void dispose() {
    _ratingController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  void _shareRecipe() {
    final recipe = widget.recipe;

    final shareText = '''
🌟 ${recipe['title']} 🌟

📝 Description:
${recipe['description']}

⏱️ Cooking Time: ${recipe['cookingTime']}
👥 Servings: ${recipe['servings']}

🥗 Ingredients:
${(recipe['ingredients'] as List<dynamic>).map((ingredient) => '- $ingredient').join('\n')}

📜 Instructions:
${(recipe['instructions'] as List<dynamic>).map((instruction) => '- $instruction').join('\n')}

🍽️ Enjoy your meal! 🍽️
''';

    Share.share(shareText);
  }

  Future<void> _submitRating() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to submit a rating.')),
      );
      return;
    }

    final rating = double.tryParse(_ratingController.text);
    if (rating == null || rating < 1 || rating > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.red,
            content: Text('Please enter a valid rating between 1 and 5.')),
      );
      return;
    }

    try {
      final recipeRef =
          FirebaseFirestore.instance.collection('recipes').doc(widget.recipeId);

      final docSnapshot = await recipeRef.get();
      if (!docSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.red, content: Text('Recipe not found.')),
        );
        return;
      }

      await recipeRef.update({
        'ratings': FieldValue.arrayUnion([rating]),
      });

      setState(() {
        widget.recipe['ratings'].add(rating);
        _ratingController.clear();
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit rating: $error')),
      );
    }
  }

  Future<void> _submitReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to submit a review.')),
      );
      return;
    }

    final reviewText = _reviewController.text.trim();
    if (reviewText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please write a review before submitting.')),
      );
      return;
    }

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userName = userDoc['name'] ?? 'Anonymous';
      final userProfileUrl = userDoc['profileUrl'] ?? '';

      final reviewRef = FirebaseFirestore.instance
          .collection('recipes')
          .doc(widget.recipeId)
          .collection('reviews');

      await reviewRef.add({
        'userId': user.uid,
        'userName': userName,
        'userProfileUrl': userProfileUrl,
        'review': reviewText,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _ratingController.clear();
      _reviewController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.green,
            content: Text('Review submitted successfully!')),
      );

      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit review: $error')),
      );
    }
  }

  double _calculateAverageRating() {
    if (widget.recipe['ratings'].isEmpty) return 0.0;
    final total = widget.recipe['ratings'].reduce((a, b) => a + b);
    return total / widget.recipe['ratings'].length;
  }

  Stream<QuerySnapshot> _fetchReviews() {
    return FirebaseFirestore.instance
        .collection('recipes')
        .doc(widget.recipeId)
        .collection('reviews')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final averageRating = _calculateAverageRating();
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final isInWishlist = wishlistProvider.isInWishlist(widget.recipeId ?? '');

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
          ),
        ),
        title: Customtext(
          text: widget.recipe['title'],
          color: Colors.white,
          weight: FontWeight.bold,
        ),
        actions: [
         
          IconButton(
            onPressed: _shareRecipe,
            icon: Icon(
              Icons.share,
              color: Colors.white,
            ),
          ),
          
          IconButton(
            onPressed: () {
              if (isInWishlist) {
                wishlistProvider.removeFromWishlist(widget.recipeId ?? '');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Customtext(
                      text: 'Removed from wishlist!',
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                wishlistProvider.addToWishlist(widget.recipeId ?? '');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Customtext(
                      text: 'Added to wishlist!',
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            icon: Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: isInWishlist ? Colors.red : Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.recipe['imageUrl'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.recipe['imageUrl'],
                  fit: BoxFit.cover,
                  height: 200,
                  width: double.infinity,
                ),
              ),
            SizedBox(height: 16),
            Center(
              child: Customtext(
                text: widget.recipe['title'],
                color: Colors.purple,
                size: 24,
                weight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            if (widget.recipe['description'] != null)
              Text(
                widget.recipe['description'],
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.timer, size: 20, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  widget.recipe['cookingTime'],
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
                SizedBox(width: 16),
                Icon(Icons.people, size: 20, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  widget.recipe['servings'],
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Average Rating: ${averageRating.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Ingredients:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            SizedBox(height: 8),
            if (widget.recipe['ingredients'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (widget.recipe['ingredients'] as List<dynamic>)
                    .map((ingredient) {
                  return Text('- $ingredient',
                      style: TextStyle(fontSize: 15, color: Colors.black));
                }).toList(),
              ),
            SizedBox(height: 16),
            Text(
              'Instructions:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            SizedBox(height: 8),
            if (widget.recipe['instructions'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: (widget.recipe['instructions'] as List<dynamic>)
                    .map((instruction) {
                  return Text(
                    '- $instruction',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  );
                }).toList(),
              ),
            SizedBox(height: 16),
            Text(
              'User Reviews:',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple),
            ),
            SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: _fetchReviews(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text('No reviews yet.');
                }

                final reviews = snapshot.data!.docs;
                return Column(
                  children: reviews.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      color: Colors.white,
                      elevation: 10,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: data['userProfileUrl'] != null &&
                                  data['userProfileUrl'].isNotEmpty
                              ? NetworkImage(data['userProfileUrl'])
                              : AssetImage('assets/img/user.jpg')
                                  as ImageProvider,
                        ),
                        title: Text(
                          data['userName'] ?? 'Anonymous',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(data['review']),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            SizedBox(height: 15),
            Text(
              'Submit Your Review:',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _reviewController,
              decoration: InputDecoration(
                labelText: 'Write a Review',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _ratingController,
              decoration: InputDecoration(
                labelText: 'Enter rating (1 to 5, e.g., 4.8)',
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.purple),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 8),
            Custombutton(
                ontap: () {
                  _submitRating();
                  if (_reviewController.text.trim().isNotEmpty) {
                    _submitReview();
                  }
                },
                color: Colors.purple,
                width: double.infinity,
                height: 35,
                child: Center(
                  child: Customtext(
                      text: 'Submit Review',
                      color: Colors.white,
                      size: 16,
                      weight: FontWeight.bold),
                )),
          ],
        ),
      ),
    );
  }
}
