// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:recipe_rack/screens/aboutus.dart';
import 'package:recipe_rack/screens/authentication/login_page.dart';
import 'package:recipe_rack/screens/privacy.dart';
import 'package:recipe_rack/screens/terms.dart';
import 'package:recipe_rack/utils/customtext.dart';
import 'package:recipe_rack/utils/slide.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  File? _image;
  String? _userName;
  String? _profileUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _userName = doc['name'] ?? 'User';
          _profileUrl = doc['profileUrl'];
        });
      } else {
        await _firestore.collection('users').doc(user.uid).set({
          'name': 'User',
          'profileUrl': '',
          'userId': user.uid,
        });
        setState(() {
          _userName = 'User';
          _profileUrl = '';
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    final user = _auth.currentUser;
    if (user == null || _image == null) return;

    try {
      final storageRef =
          _storage.ref().child('profile_pictures/${user.uid}.jpg');
      await storageRef.putFile(_image!);
      final downloadUrl = await storageRef.getDownloadURL();

      await _firestore.collection('users').doc(user.uid).update({
        'profileUrl': downloadUrl,
      });

      setState(() {
        _profileUrl = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile picture updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image: $e')),
      );
    }
  }

  void _editName() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController nameController =
            TextEditingController(text: _userName);
        return AlertDialog(
          title: Text('Edit Name'),
          content: TextField(controller: nameController),
          actions: [
            TextButton(
              onPressed: () async {
                final user = _auth.currentUser;
                if (user != null) {
                  await _firestore
                      .collection('users')
                      .doc(user.uid)
                      .update({'name': nameController.text});
                  setState(() {
                    _userName = nameController.text;
                  });
                }
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SlideDownAppBar(
        child: AppBar(
          leading: Icon(Icons.person, color: Colors.white),
          title: Customtext(
              text: 'Account', color: Colors.white, weight: FontWeight.bold),
          backgroundColor: Colors.purple,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _profileUrl != null
                        ? NetworkImage(_profileUrl!)
                        : _image != null
                            ? FileImage(_image!) as ImageProvider
                            : AssetImage('assets/img/user.jpg')
                                as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        shape: CircleBorder(),
                      ),
                      child: Icon(Icons.edit, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _userName ?? 'User',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                TextButton(onPressed: _editName, child: Text('Edit')),
              ],
            ),
            SizedBox(height: 20),
            Divider(),
            ListTile(
              leading: Icon(Icons.info, color: Colors.purple),
              title: Text('About Us'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutUsPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.privacy_tip, color: Colors.purple),
              title: Text('Privacy Policy'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Privacy()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment, color: Colors.purple),
              title: Text('Terms & Conditions'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Terms()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () async {
                await _auth.signOut();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ));
              },
            ),
          ],
        ),
      ),
    );
  }
}

