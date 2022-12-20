// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:colegio_especial_dgp/Dart/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  test_gestion_alumnos();
  test_lista_profesores();
  test_editar_tarea();
  test_chat();
}

/************************ INICIALIZACIÓN **************************************/

void inicializacion() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await cargarPreajustes();
}

/********************* INICIO DE SESION ***************************************/
/*
Historias probadas:
- Inicio de sesión
- Dividir Login Page en profesor y alumno
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

      await Future.delayed(const Duration(seconds: 2), (){});

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

      await Future.delayed(const Duration(seconds: 2), (){});

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

      await Future.delayed(const Duration(seconds: 2), (){});

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

      await Future.delayed(const Duration(seconds: 2), (){});

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

-Enviar retroalimentación por completar tarea (Profesor)
-Recibir retroalimentación por completar tarea (Alumno)

-Historial del alumno (Alumno/Profesor/Admin)
*/

void test_gestion_alumnos(){
  group('Gestión de alumnos como administrador/profesor', () {
    testWidgets('Test de carga de alumnos', (WidgetTester tester) async {

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton Profesores
      var tipo = find.text("PROFESORES");
      await tester.tap(tipo);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton
      var boton = find.text("EMILIO");
      await tester.tap(boton);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 1), (){});

      //Introducimos la contraseña
      var contrasenia = "123";
      await tester.enterText(find.byKey(Key("campoContraseña")), contrasenia);

      var botonEnviar = find.text("ENVIAR");
      await tester.tap(botonEnviar);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 3), (){});

      //Pulsamos el boton alumnos
      await tester.tap(find.text("LISTA DE ALUMNOS"),warnIfMissed: false);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});
      await tester.scrollUntilVisible(find.text("JAIME"), 500);

      expect(find.text("JAIME"),findsOneWidget);
    });

    testWidgets('Test de añadir tarea', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton Profesores
      var tipo = find.text("PROFESORES");
      await tester.tap(tipo);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton
      var boton = find.text("EMILIO");
      await tester.tap(boton);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 1), (){});

      //Introducimos la contraseña
      var contrasenia = "123";
      await tester.enterText(find.byKey(Key("campoContraseña")), contrasenia);

      var botonEnviar = find.text("ENVIAR");
      await tester.tap(botonEnviar);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton alumnos
      var botonA = find.text("LISTA DE ALUMNOS");
      await tester.tap(botonA,warnIfMissed: false);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton antonio
      var botonAn = find.text("JAIME");
      await tester.tap(botonAn);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 1), (){});

      //Pulsamos el boton antonio
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      await Future.delayed(const Duration(seconds: 1), (){});

      //Pulsamos el boton tarea
      var botonT = find.byKey(Key("Multiselección"));
      await tester.tap(botonT);
      await tester.pumpAndSettle();

      //Pulsamos el boton hacer fotocopia
      await tester.tap(find.text("HAZ UNA FOTOCOPIA").last,warnIfMissed: false);
      await tester.pumpAndSettle();

      //Pulsamos el boton añadir tarea
      var botonAT = find.text("AÑADIR TAREA");
      await tester.tap(botonAT);
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 1), (){});

      expect(find.text("HAZ UNA FOTOCOPIA"),findsOneWidget);
    });

    testWidgets('Comprobar tarea en alumno', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton Profesores
      var tipo = find.text("ALUMNOS");
      await tester.tap(tipo);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton
      var boton = find.text("JAIME");
      await tester.tap(boton);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 1), (){});

      //Introducimos la contraseña
      var contrasenia = "123";
      await tester.enterText(find.byKey(Key("campoContraseña")), contrasenia);

      var botonEnviar = find.text("ENVIAR");
      await tester.tap(botonEnviar);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton tareas
      var botonT = find.text("LISTA DE TAREAS");
      await tester.tap(botonT);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      expect(find.text("\nHAZ UNA FOTOCOPIA\n"),findsOneWidget);

      var botonAceptar = find.byKey(Key('aceptarTarea'));

      //Pulsamos el boton aceptar
      await tester.tap(botonAceptar);
      await tester.pump();

      await Future.delayed(const Duration(milliseconds: 500), (){});

      //Introducimos un comentario
      await tester.enterText(find.byKey(Key("comentarioRetroalimentacion")), 'Test');

      //Pulsamos el boton enviar
      await tester.tap(find.text("\nENVIAR"));
      await tester.pump();
    });

    testWidgets('Test de enviar retroalimentacion', (WidgetTester tester) async {

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton Profesores
      var tipo = find.text("PROFESORES");
      await tester.tap(tipo);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton
      var boton = find.text("EMILIO");
      await tester.tap(boton);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 1), (){});

      //Introducimos la contraseña
      var contrasenia = "123";
      await tester.enterText(find.byKey(Key("campoContraseña")), contrasenia);

      var botonEnviar = find.text("ENVIAR");
      await tester.tap(botonEnviar);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton alumnos
      var botonA = find.text("LISTA DE ALUMNOS");
      await tester.tap(botonA);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton antonio
      var botonAn = find.text("JAIME");
      await tester.tap(botonAn);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton hacer fotocopia
      await tester.tap(find.text("HAZ UNA FOTOCOPIA"));
      await tester.pumpAndSettle();

      //Comprobar comentario alumno
      expect(find.text("TEST"),findsOneWidget);

      //Pulsamos boton enviar retroalimentacion
      await tester.scrollUntilVisible(find.text("ENVIAR RETROALIMENTACIÓN"), 500);
      await tester.tap(find.text("ENVIAR RETROALIMENTACIÓN"));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 1), (){});

      //Introducimos un comentario
      await tester.enterText(find.byKey(Key("profesorRetroalimentacion")), 'Bien hecho');

      //Pulsamos el boton enviar
      await tester.tap(find.text("\nENVIAR"));
      await tester.pump();
    });

    testWidgets('Comprobar retroalimentacion en alumno', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton Profesores
      var tipo = find.text("ALUMNOS");
      await tester.tap(tipo);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton
      var boton = find.text("JAIME");
      await tester.tap(boton);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 1), (){});

      //Introducimos la contraseña
      var contrasenia = "123";
      await tester.enterText(find.byKey(Key("campoContraseña")), contrasenia);

      var botonEnviar = find.text("ENVIAR");
      await tester.tap(botonEnviar);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton tareas
      var botonT = find.text("HISTORIAL");
      await tester.tap(botonT);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 5), (){});

      expect(find.text("BIEN HECHO\n"),findsAtLeastNWidgets(1));
    });

    testWidgets('Test de eliminar tarea', (WidgetTester tester) async {

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton Profesores
      var tipo = find.text("PROFESORES");
      await tester.tap(tipo);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton
      var boton = find.text("EMILIO");
      await tester.tap(boton);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 1), (){});

      //Introducimos la contraseña
      var contrasenia = "123";
      await tester.enterText(find.byKey(Key("campoContraseña")), contrasenia);

      var botonEnviar = find.text("ENVIAR");
      await tester.tap(botonEnviar);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton alumnos
      var botonA = find.text("LISTA DE ALUMNOS");
      await tester.tap(botonA);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton antonio
      var botonAn = find.text("JAIME");
      await tester.tap(botonAn);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton hacer fotocopia
      await tester.tap(find.byType(IconButton).first,warnIfMissed: false);
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 1), (){});

      expect(find.text("HAZ UNA FOTOCOPIA"),findsNothing);
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

      //Pulsamos el boton Profesores
      var tipo = find.text("PROFESORES");
      await tester.tap(tipo);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton
      var boton = find.text("ADMIN");
      await tester.tap(boton);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 1), (){});

      //Introducimos la contraseña
      var contrasenia = "admin";
      await tester.enterText(find.byKey(Key("campoContraseña")), contrasenia);

      var botonEnviar = find.text("ENVIAR");
      await tester.tap(botonEnviar);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 3), (){});

      //Pulsamos el boton profesores
      var botonP = find.text("LISTA DE PROFESORES");
      await tester.tap(botonP);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      expect(find.text("ANGELA"),findsOneWidget);
    });

    testWidgets('Datos correctos', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton Profesores
      var tipo = find.text("PROFESORES");
      await tester.tap(tipo);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton
      var boton = find.text("ADMIN");
      await tester.tap(boton);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 1), (){});

      //Introducimos la contraseña
      var contrasenia = "admin";
      await tester.enterText(find.byKey(Key("campoContraseña")), contrasenia);

      var botonEnviar = find.text("ENVIAR");
      await tester.tap(botonEnviar);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 3), (){});

      //Pulsamos el boton profesores
      var botonP= find.text("LISTA DE PROFESORES");
      await tester.tap(botonP);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton antonio
      var botonF = find.text("ANGELA");
      await tester.tap(botonF);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      expect(find.text("ANGELA"),findsOneWidget);
      expect(find.text("CAMELA"),findsOneWidget);
      expect(find.text("2/12/2022"),findsOneWidget);
    });

  });
}

/*************************** EDICIÓN DE TAREA *********************************/
/*
Historias probadas:
- Edición de tarea (Admin)
*/

void test_editar_tarea(){

  group('Editar tarea', () {
    testWidgets('Test de edición de tareas', (WidgetTester tester) async {

      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton Profesores
      var tipo = find.text("PROFESORES");
      await tester.tap(tipo);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton
      var boton = find.text("ADMIN");
      await tester.tap(boton);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Introducimos la contraseña
      var contrasenia = "admin";
      await tester.enterText(find.byKey(Key("campoContraseña")), contrasenia);

      var botonEnviar = find.text("ENVIAR");
      await tester.tap(botonEnviar);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 3), (){});

      //Pulsamos el boton profesores
      var botonP = find.text("LISTA DE TAREAS");
      await tester.tap(botonP);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton hacer fotocopia
      await tester.tap(find.text("HAZ UNA FOTOCOPIA"));
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Cambiamos las instrucciones
      await tester.tap(find.byKey(Key("instrucciones")));
      await tester.pump();
      for(int i = 0; i<'VE A LA SALA DE LA IMPERSORA E IMPRIME'.length;i++){
        await tester.sendKeyDownEvent(LogicalKeyboardKey.delete);
      }
      await tester.enterText(find.byKey(Key("instrucciones")), 'TEST');

      final gesture = await tester.startGesture(Offset.zero);
      await gesture.moveBy(const Offset(0, 200));
      await tester.pump();

      await tester.tap(find.byKey(Key("Guardar")),warnIfMissed: false);
      await tester.pump();

      //Pulsamos el boton hacer fotocopia
      await tester.tap(find.text("HAZ UNA FOTOCOPIA"));
      await tester.pump();

      expect(find.text('TEST'),findsOneWidget);

      //Ponemos las instrucciones como estaban
      await tester.tap(find.byKey(Key("instrucciones")));
      await tester.pump();
      for(int i = 0; i<'TEST'.length;i++){
        await tester.sendKeyDownEvent(LogicalKeyboardKey.delete);
      }
      await tester.enterText(find.byKey(Key("instrucciones")),
          'VE A LA SALA DE LA IMPERSORA E IMPRIME');

      final gesture2 = await tester.startGesture(Offset.zero);
      await gesture2.moveBy(const Offset(0, 200));
      await tester.pump();

      await tester.tap(find.byKey(Key("Guardar")),warnIfMissed: false);
      await tester.pump();
    });
  });
}

/****************************** CHAT ******************************************/
/*
Historias probadas:
- Chat entre alumno y profesor(alumnos/profesores)
*/

void test_chat() {
  group('Intercambio de mensajes', () {

    testWidgets('Test de envío de mensaje', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton Profesores
      var tipo = find.text("PROFESORES");
      await tester.tap(tipo);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton
      var boton = find.text("ADMIN");
      await tester.tap(boton);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 1), (){});

      //Introducimos la contraseña
      var contrasenia = "admin";
      await tester.enterText(find.byKey(Key("campoContraseña")), contrasenia);

      var botonEnviar = find.text("ENVIAR");
      await tester.tap(botonEnviar);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 3), (){});

      //Pulsamos el boton chats
      var botonC = find.byIcon(Icons.chat);
      await tester.tap(botonC);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      var chatBlanca = find.text("BLANCA");
      print(chatBlanca);
      //Si existe el chat entro
      if(chatBlanca.toString()!="zero widgets with text \"BLANCA\" (ignoring offstage widgets)"){
        await tester.tap(chatBlanca);
        await tester.pump();
      }//Si no, lo creo
      else{
        await tester.tap(find.byIcon(Icons.search));
        await tester.pump();

        await Future.delayed(const Duration(seconds: 2), (){});

        await tester.enterText(find.byType(TextField),"BLANC");

        await tester.tap(find.text("BLANCA"),warnIfMissed: false);
        await tester.pumpAndSettle();
      }

      await Future.delayed(const Duration(seconds: 2), (){});

      //Introducimos un mensaje
      await tester.enterText(find.byKey(Key("CampoMensaje")), 'Hola');

      //Pulsamos el boton enviar
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      expect(find.text("HOLA"),findsAtLeastNWidgets(1));
    });

    testWidgets('Test de recepción de mensaje', (WidgetTester tester) async {
      await tester.pumpWidget(App());
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 2), (){});

      //Pulsamos el boton Profesores
      var tipo = find.text("ALUMNOS");
      await tester.tap(tipo);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

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

      //Pulsamos el boton chats
      var botonC = find.byIcon(Icons.chat);
      await tester.tap(botonC);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      var chatAdmin = find.text("ADMIN");
      await tester.tap(chatAdmin);
      await tester.pump();

      await Future.delayed(const Duration(seconds: 2), (){});

      expect(find.text("HOLA"),findsAtLeastNWidgets(1));
    });
  });
}