import 'package:flutter/material.dart';
import 'package:myfuelz_admin/views/home_page.dart';

class LoginScreen extends StatelessWidget {
  static const String id = "login-screen";
  final _formKey = GlobalKey<FormState>();

  final _emailTextController = TextEditingController(text: "testing@gmail.com");
  final _passwordTextController = TextEditingController(text: "2001115");

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 500,
                width: 500,
                child: Image.asset("assets/images/webadmin.png"),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email),
                    labelText: "Email Address",
                    contentPadding: EdgeInsets.zero,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 3,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    focusColor: Theme.of(context).primaryColor,
                  ),
                  controller: _emailTextController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter your email";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    value = _emailTextController.text;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: TextFormField(
                  keyboardType: TextInputType.visiblePassword,
                  maxLength: 10,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.password),
                    labelText: "Password",
                    contentPadding: EdgeInsets.zero,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 3,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    focusColor: Theme.of(context).primaryColor,
                  ),
                  controller: _passwordTextController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Enter your password";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    value = _passwordTextController.text;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 60,
                ),
                child: MaterialButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Navigator.pushReplacementNamed(context, HomePage.id);
                    }
                  },
                  color: Colors.blue,
                  height: 50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      "Login",
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
