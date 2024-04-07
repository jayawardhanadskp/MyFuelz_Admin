import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  static const String id ="login-screen";

  @override
 Widget build(BuildContext context) {
    return Scaffold(
    body: Center(child: Text("Login Screen",style: TextStyle(fontSize: 30, color: Colors.blue),),),
    );
}
}