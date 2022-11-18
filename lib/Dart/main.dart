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
*   http.dart : Se usa para acceder a webs y concretamente para acceder a la API de emailjs que se encarga de enviar los emails
*   covert: Se usa para codificar los JSON
* */

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../Flutter/profe_alumno.dart';
import 'background.dart';
import 'firebase_options.dart';
import '../Flutter/loginpage.dart';
import 'notificacion.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


var user = "";

bool cambioColor = true;

final FlutterLocalNotificationsPlugin notificaciones =
    FlutterLocalNotificationsPlugin();

// Establecer los colores de la pagina siguiendo la paleta de color
Map<int, Color> color = {
  50: Color.fromRGBO(143, 125, 178, .1),
  100: Color.fromRGBO(143, 125, 178, .2),
  200: Color.fromRGBO(143, 125, 178, .3),
  300: Color.fromRGBO(143, 125, 178, .4),
  400: Color.fromRGBO(143, 125, 178, .5),
  500: Color.fromRGBO(143, 125, 178, .6),
  600: Color.fromRGBO(143, 125, 178, .7),
  700: Color.fromRGBO(143, 125, 178, .8),
  800: Color.fromRGBO(143, 125, 178, .9),
  900: Color.fromRGBO(143, 125, 178, 1),
};

MaterialColor colorCustom =
    MaterialColor(Color.fromRGBO(143, 125, 178, 1).value, color);

// Inicializar la app
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(App());
}

//Función para mandar un email.
Future sendEmail(String name, String email, String message) async {
  final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
  const serviceId = 'servicioCorreo';
  const templateId = 'template_xxh3jhv';
  const userId = 'cQtG7913Sa6aZX2Xz';
  final response = await http.post(url,
      headers: {
        'Content-Type': 'application/json'
      }, //This line makes sure it works for all platforms.
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': {
          'from_name': name,
          'to_email': email,
          'message': message
        }
      }));
  return response.statusCode;
}


// Inicializa la aplicacion indicando el idioma soportado
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Notificacion.initialize(notificaciones);

    Background.inicializarBackground();

    return MaterialApp(
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      debugShowCheckedModeBanner: false,
      supportedLocales: [Locale('es', 'ES'), Locale('en', 'US')],
      title: 'Proyecto Colegio Especial',

      theme:
          ThemeData(primarySwatch: cambioColor?colorCustom:Colors.orange,fontFamily: "Escolar",textTheme: TextTheme(bodyText2: TextStyle(fontSize: 30))),
      home: ProfeAlumno(),
    );
  }
}
