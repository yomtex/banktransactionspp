import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool isFirstTimeUser = true;

  @override
  void initState() {
    super.initState();
    _checkFirstTimeUser();
  }

  void _checkFirstTimeUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool firstTime = prefs.getBool('firstTime') ?? true;
    setState(() {
      isFirstTimeUser = firstTime;
    });

    if (firstTime) {
      prefs.setBool('firstTime', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return isFirstTimeUser ? FirstTimeUserSplash() : ReturningUserSplash();
  }
}

class FirstTimeUserSplash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Welcome! First Time User'),
      ),
    );
  }
}

class ReturningUserSplash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Welcome Back!'),
      ),
    );
  }
}
