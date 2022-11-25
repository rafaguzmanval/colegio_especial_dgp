// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:colegio_especial_dgp/Dart/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:colegio_especial_dgp/Dart/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:integration_test/integration_test.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  if (binding is LiveTestWidgetsFlutterBinding) {
    binding.framePolicy = LiveTestWidgetsFlutterBindingFramePolicy.fullyLive;
  }

  inicializacion();
  test_inicio_sesion();
  //test_gestion_alumnos();
  //test_lista_profesores();
}

/************************ INICIALIZACIÓN **************************************/

void inicializacion() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

/********************* INICIO DE SESION ***************************************/
/*
Historias probadas:
- Inicio de sesión
*/

void test_inicio_sesion(){
  group('Inicio de sesión', () {
    testWidgets('Test de carga de usuarios', (WidgetTester tester) async {

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton Profesores
      var boton = find.text("PROFESORES");
      await tester.tap(boton);
      await tester.pump();

      expect(find.text("EMILIO"),findsOneWidget);
    });

    testWidgets('Test de seleccion de usuario', (WidgetTester tester) async {

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton Profesores
      var boton = find.text("PROFESORES");
      await tester.tap(boton);
      await tester.pump();

      //Pulsamos el boton
      var boton1 = find.text("EMILIO");
      await tester.tap(boton1);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 1), (){});

      expect(find.text("ENVIAR"),findsOneWidget);
    });


    testWidgets('Test de inicio de usuario', (WidgetTester tester) async {

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton Profesores
      var boton = find.text("PROFESORES");
      await tester.tap(boton);
      await tester.pump();

      //Pulsamos el boton
      var boton1 = find.text("EMILIO");
      await tester.tap(boton1);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 1), (){});

      //Introducimos la contraseña
      var contrasenia = "123";
      await tester.enterText(find.byKey(Key("campoContraseña")), contrasenia);

      var botonEnviar = find.text("ENVIAR");
      await tester.tap(botonEnviar);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      expect(find.text("LISTA DE ALUMNOS"),findsOneWidget);
    });

    testWidgets('Test de inicio de usuario con pin', (WidgetTester tester) async {

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton Profesores
      var boton = find.text("ALUMNOS");
      await tester.tap(boton);
      await tester.pump();

      //Pulsamos el boton
      var boton1 = find.text("BLANCA");
      await tester.tap(boton1);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Introducimos el pin
      var botonP = find.byType(ElevatedButton).at(0);
      await tester.tap(botonP);
      await tester.pump();

      botonP = find.byType(ElevatedButton).at(2);
      await tester.tap(botonP);
      await tester.pump();

      botonP = find.byType(ElevatedButton).at(3);
      await tester.tap(botonP);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      expect(find.text("LISTA DE TAREAS"),findsOneWidget);
    });
  });
}

/************************ GESTIÓN DE ALUMNOS **********************************/
/*
Historias probadas:
-Asignación de tareas (Profesor)
-Lista de tareas (Alumno)
-Lista de tareas (Profesor/Admin)
-Tareas asignadas a un Alumno (Admin/Profesor)
-Lista de estudiantes matriculados (Admin)
-Videotutorial en tarea (Alumno)
*/

void test_gestion_alumnos(){
  group('Gestión de alumnos como administrador/profesor', () {
    testWidgets('Test de carga de alumnos', (WidgetTester tester) async {

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton
      var boton = find.text("Emilio");
      await tester.tap(boton);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 1), (){});

      //Introducimos la contraseña
      var contrasenia = "123";
      await tester.enterText(find.byKey(Key("campoContraseña")), contrasenia);

      var botonEnviar = find.text("Enviar");
      await tester.tap(botonEnviar);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton alumnos
      var botonA = find.text("Lista de alumnos");
      await tester.tap(botonA);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      expect(find.text("Jaime"),findsOneWidget);
    });

    testWidgets('Test de añadir tarea', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton
      var boton = find.text("Emilio");
      await tester.tap(boton);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 1), (){});

      //Introducimos la contraseña
      var contrasenia = "123";
      await tester.enterText(find.byKey(Key("campoContraseña")), contrasenia);

      var botonEnviar = find.text("Enviar");
      await tester.tap(botonEnviar);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton alumnos
      var botonA = find.text("Lista de alumnos");
      await tester.tap(botonA);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton antonio
      var botonAn = find.text("Jaime");
      await tester.tap(botonAn);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 1), (){});

      //Pulsamos el boton tarea
      var botonT = find.byKey(Key("Multiselección"));
      await tester.tap(botonT);
      await tester.pumpAndSettle();

      //Pulsamos el boton hacer fotocopia
      await tester.tap(find.text("Hacer fotocopia").last,warnIfMissed: false);
      await tester.pumpAndSettle();

      //Pulsamos el boton añadir tarea
      var botonAT = find.text("Añadir Tarea");
      await tester.tap(botonAT);
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 1), (){});

      expect(find.text("Hacer fotocopia"),findsAtLeastNWidgets(2));
    });

    testWidgets('Comprobar tarea en alumno', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton
      var boton = find.text("Jaime");
      await tester.tap(boton);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 1), (){});

      //Introducimos la contraseña
      var contrasenia = "123";
      await tester.enterText(find.byKey(Key("campoContraseña")), contrasenia);

      var botonEnviar = find.text("Enviar");
      await tester.tap(botonEnviar);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton tareas
      var botonT = find.text("Lista de Tareas");
      await tester.tap(botonT);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      expect(find.text("\nHacer fotocopia\n"),findsOneWidget);

      //Pulsamos el boton play
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      await Future.delayed(const Duration(seconds: 4), (){});
      
      expect(find.byIcon(Icons.pause), findsOneWidget);
    });

    testWidgets('Test de eliminar tarea', (WidgetTester tester) async {

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton
      var boton = find.text("Emilio");
      await tester.tap(boton);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 1), (){});

      //Introducimos la contraseña
      var contrasenia = "123";
      await tester.enterText(find.byKey(Key("campoContraseña")), contrasenia);

      var botonEnviar = find.text("Enviar");
      await tester.tap(botonEnviar);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton alumnos
      var botonA = find.text("Lista de alumnos");
      await tester.tap(botonA);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton antonio
      var botonAn = find.text("Jaime");
      await tester.tap(botonAn);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton hacer fotocopia
      await tester.tap(find.byType(IconButton).first,warnIfMissed: false);
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 1), (){});

      expect(find.text("Hacer fotocopia"),findsOneWidget);
    });
  });
}

/************************ LISTA DE PROFESORES *********************************/
/*
Historias probadas:
- Lista de profesores(Admin)
*/

void test_lista_profesores(){

  group('Gestión de profesores como administrador/profesor', () {

    testWidgets('Test de carga de profesores', (WidgetTester tester) async {

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton
      var boton = find.text("Emilio");
      await tester.tap(boton);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 1), (){});

      //Introducimos la contraseña
      var contrasenia = "123";
      await tester.enterText(find.byKey(Key("campoContraseña")), contrasenia);

      var botonEnviar = find.text("Enviar");
      await tester.tap(botonEnviar);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton profesores
      var botonP = find.text("Lista de Profesores");
      await tester.tap(botonP);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      expect(find.text("Flavia"),findsOneWidget);
    });

    testWidgets('Datos correctos', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton
      var boton = find.text("Emilio");
      await tester.tap(boton);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 1), (){});

      //Introducimos la contraseña
      var contrasenia = "123";
      await tester.enterText(find.byKey(Key("campoContraseña")), contrasenia);

      var botonEnviar = find.text("Enviar");
      await tester.tap(botonEnviar);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton profesores
      var botonP= find.text("Lista de Profesores");
      await tester.tap(botonP);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton antonio
      var botonF = find.text("Flavia");
      await tester.tap(botonF);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      expect(find.text("Nombre: Flavia\n"),findsOneWidget);
      expect(find.text("Apellidos: Viño\n"),findsOneWidget);
      expect(find.text("Fecha de nacimiento: 3/7/1986\n"),findsOneWidget);
    });

  });
}

