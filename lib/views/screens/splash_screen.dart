import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myfuelz_admin/views/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String id ="splash-screen";

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {


  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () => Navigator.pushReplacementNamed(context, LoginScreen.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
        height: 500,
        width: 500,
        child: Image.asset("assets/images/webadmin.png")),
      ),
    );
  }
}
