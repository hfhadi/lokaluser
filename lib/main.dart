import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lokaluser/InfoHandler/app_info.dart';
import 'package:lokaluser/salam/justmap.dart';
import 'package:lokaluser/salam/mymap.dart';
import 'package:lokaluser/send_fcm.dart';
import 'package:lokaluser/splashScreen/splash_screen.dart';
import 'package:lokaluser/widgets/fetch_data.dart';
import 'package:lokaluser/widgets/home_screen.dart';
import 'package:lokaluser/widgets/zone_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDbkI8uwv1xVSlIVV3I2dILxs9-foMdNgY",
          authDomain: "geetaxi-15c74.firebaseapp.com",
          databaseURL: "https://geetaxi-15c74.firebaseio.com",
          projectId: "geetaxi-15c74",
          storageBucket: "geetaxi-15c74.appspot.com",
          messagingSenderId: "242720635019",
          appId: "1:242720635019:web:c2781e12c5e3b516363c8e"),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(
    MyApp(
      child: ChangeNotifierProvider(
        create: ((context) => AppInfo()),
        child: MaterialApp(
          title: 'Drivers App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home:
              //JustMap(),
              //const MySplashScreen(),
              // const SendFcm(),
              // const ZoneWidget(),
              // FetchData(),
              const MyMap(),
          // HomeScreen(),
          debugShowCheckedModeBanner: false,
        ),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final Widget? child;

  MyApp({this.child});

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_MyAppState>()!.restartApp();
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child!,
    );
  }
}
