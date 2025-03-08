// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:recipe_rack/screens/authentication/login_page.dart';
import 'package:recipe_rack/screens/home_page.dart';
import 'package:recipe_rack/utils/customtext.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.forward();

    getloggedData().whenComplete(() {
      if (finalData == true) {
        Future.delayed(
            Duration(seconds: 2),
            () => Navigator.push(
                context, MaterialPageRoute(builder: (context) => HomePage())));
      } else {
        Future.delayed(Duration(seconds: 3), () {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginScreen()));
        });
      }
    });
  }

  bool? finalData;
  Future getloggedData() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    var getData = preferences.getBool('islogged');
    setState(() {
      finalData = getData;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple, Colors.deepPurple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             
              ScaleTransition(
                scale: _animation,
                child:
                    Icon(Icons.restaurant_menu, color: Colors.white, size: 100),
              ),
              SizedBox(height: 20),
              
              FadeTransition(
                opacity: _animation,
                child: Customtext(
                  text: 'RECIPE-RACK',
                  color: Colors.white,
                  size: 24,
                  weight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
             
              CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
