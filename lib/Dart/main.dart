import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import '../Flutter/myhomepage.dart';
import '../Flutter/loginpage.dart';
import 'notificacion.dart';
import 'package:localization/localization.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

var user = "";

var color = Colors.orange[200];

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(App());
}

class App extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    Notificacion.initialize(flutterLocalNotificationsPlugin);

    return MaterialApp(

      localizationsDelegates:GlobalMaterialLocalizations.delegates,


      supportedLocales: [
        Locale('es','ES'),
        Locale('en','US')
      ],
      title: 'Proyecto Colegio Especial',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: LoginPage(),
    );
  }

}
