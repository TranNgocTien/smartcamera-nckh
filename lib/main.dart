import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'screen/smart-camera.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: AnimatedSplashScreen(
        splash: Column(
          children: [
            Container(
              child: Image.asset('assets/image/FCE-Site-logo.png'),
            ),
            Text(
              'Welcome to SoC Lab',
              style: TextStyle(
                  fontFamily: "RobotoCondensed",
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5),
            ),
          ],
        ),
        splashIconSize: 300,
        duration: 3000,
        splashTransition: SplashTransition.fadeTransition,
        nextScreen: ImageApp(),
      ),

      //   Center(
      //   child: Container(
      //     child: Text(
      //       'Splash Screen',
      //       style: TextStyle(
      //         fontSize: 24,
      //         fontWeight: FontWeight.bold,
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}
