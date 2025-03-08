import 'package:flutter/material.dart';

class WishlistProvider with ChangeNotifier {
  final List<String> _wishlist = [];

  List<String> get wishlist => _wishlist;

  void addToWishlist(String recipeId) {
    if (!_wishlist.contains(recipeId)) {
      _wishlist.add(recipeId);
      notifyListeners();
    }
  }

  void removeFromWishlist(String recipeId) {
    if (_wishlist.contains(recipeId)) {
      _wishlist.remove(recipeId);
      notifyListeners();
    }
  }

  bool isInWishlist(String recipeId) {
    return _wishlist.contains(recipeId);
  }
}