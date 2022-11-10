
/*
*   Archivo: main.dart
*
*   Descripción: 
*   Inicia flutter con los colores de la paleta de colores.
*   
*   Includes:
*   material.dart : Se utiliza para dar colores y diseño a la aplicacion.
*   firebase_core.dart : Se utiliza para acceder a los servicios del servidor. 
*   flutter_local_notifications.dart : Se utiliza para inicializar notificaciones.
*   firebase_options.dart : Se utiliza para acceder con nuestro token a nuestro servidor. 
*   notificacion.dart : Se utiliza para crear notificaciones y que aparezcan en el dispositivo.
*   flutter_localizations.dart : Se utiliza para traducir widgets al español.
* */

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import '../Flutter/loginpage.dart';
import 'notificacion.dart';
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
      debugShowCheckedModeBanner: false,

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
