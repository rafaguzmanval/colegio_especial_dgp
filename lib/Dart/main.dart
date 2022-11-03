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


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Map<int, Color> color = {
  50: Color.fromRGBO(143, 125, 178,.1),
  100: Color.fromRGBO(143, 125, 178,.2),
  200: Color.fromRGBO(143, 125, 178,.3),
  300: Color.fromRGBO(143, 125, 178,.4),
  400: Color.fromRGBO(143, 125, 178,.5),
  500: Color.fromRGBO(143, 125, 178,.6),
  600: Color.fromRGBO(143, 125, 178,.7),
  700: Color.fromRGBO(143, 125, 178,.8),
  800: Color.fromRGBO(143, 125, 178,.9),
  900: Color.fromRGBO(143, 125, 178,1),
};

MaterialColor colorCustom = MaterialColor(Color.fromRGBO(143, 125, 178, 1).value,color );

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
      theme: ThemeData(primarySwatch: colorCustom, bottomAppBarColor: colorCustom),
      home: LoginPage(),
    );
  }

}
