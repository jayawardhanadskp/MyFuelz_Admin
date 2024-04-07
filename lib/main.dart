import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:myfuelz_admin/views/home_page.dart';
import 'package:myfuelz_admin/views/screens/login_screen.dart';
import 'package:myfuelz_admin/views/screens/splash_screen.dart';


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: 'AIzaSyAosr6CAEfgwMW4l8etzz1Sgyo6DTkxVKY',
          appId: '1:298003809430:web:0b33ca29c2b630ed636eb7',
          messagingSenderId: '298003809430',
          projectId: 'myfuelz',
        authDomain: "myfuelz.firebaseapp.com",
        databaseURL: "https://myfuelz-default-rtdb.asia-southeast1.firebasedatabase.app",
        storageBucket: "myfuelz.appspot.com",
      ),
    );
  }  else {
    await Firebase.initializeApp();
  }




  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      initialRoute: SplashScreen.id,

      routes: {
    SplashScreen.id : (context) => SplashScreen(),
    LoginScreen.id :(context) => LoginScreen()
    },

    debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: Container(child: Text("Welcome to flutter web",
          style: TextStyle(fontSize: 30, color: Colors.blue),),),
        ),
      ),
    );
  }
}

