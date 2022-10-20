import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lokaluser/authentication/login_screen.dart';
import 'package:lokaluser/global/global.dart';
import 'package:lokaluser/mainScreens/main_screen.dart';
import 'package:lokaluser/salam/main_screen2.dart';

import '../assistants/assistant_methods.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  _MySplashScreenState createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  startTimer() {
    gFirebaseAuth.currentUser != null ? AssistantMethods.readCurrentOnlineUserInfo() : null;

    Timer(const Duration(seconds: 1), () async {
      if (gFirebaseAuth.currentUser != null) {
        gCurrentFirebaseUser = gFirebaseAuth.currentUser;
        Navigator.push(context, MaterialPageRoute(builder: (c) => MainScreen()));
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (c) => LoginScreen()));
      }
    });
  }

  @override
  void initState() {
    super.initState();

    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("images/logo.png"),
              const SizedBox(
                height: 10,
              ),
              const Text(
                "User App",
                style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
