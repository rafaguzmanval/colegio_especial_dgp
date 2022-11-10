import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Flutter/loginpage.dart';
import 'package:colegio_especial_dgp/Flutter/myhomepage.dart';
import 'package:colegio_especial_dgp/Flutter/perfil_alumno.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/aula.dart';
import 'package:colegio_especial_dgp/Dart/usuario.dart';

import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';

import "package:image_picker/image_picker.dart";

import "package:flutter_tts/flutter_tts.dart";

class TablonComunicacion extends StatefulWidget {
  @override
  TablonComunicacionState createState() => TablonComunicacionState();
}

class TablonComunicacionState extends State<TablonComunicacion> {
  var indiceTextos = 0;
  var indiceImagenes = 0;

  var nombres = ["hola", "carne", "caca"];
  var imagenes = [
    "https://firebasestorage.googleapis.com/v0/b/colegioespecialdgp.appspot.com/o/Im%C3%A1genes%2Fpictogramas%2Fhola.png?alt=media&token=8985d5de-d0a5-4c53-a427-32f9241917d3",
    "https://firebasestorage.googleapis.com/v0/b/colegioespecialdgp.appspot.com/o/Im%C3%A1genes%2Fpictogramas%2Fcarne.png?alt=media&token=842b044f-a900-4a19-a697-df8799eba89c",
    "https://firebasestorage.googleapis.com/v0/b/colegioespecialdgp.appspot.com/o/Im%C3%A1genes%2Fpictogramas%2Fcaca.png?alt=media&token=f838fb98-bb18-43de-b27f-09dd5fa038a2"
  ];

  var db = FirebaseFirestore.instance;

  AccesoBD base = new AccesoBD();

  var lenguajes;

  FlutterTts tts = new FlutterTts();

  ///Cuándo se pasa de página es necesario que todos los controladores de los formularios y de los reproductores de vídeo se destruyan.
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    Sesion.paginaActual = this;

    Sesion.seleccion = "";
    Sesion.tareas = [];

    initTTS();
  }

  void initTTS() async {
    lenguajes = List<String>.from(await tts.getLanguages);
    await tts.setVolume(1.0);
    await tts.setPitch(1.0);
    await tts.setLanguage("es-ES");
    actualizar();
  }

  /// Este es el build de la clase MyHomePage que devuelve toda la vista génerica más la vista especial de cada usuario.
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('Tareas'),
      ),
      body: Container(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          child: Column(
            children: [
              if (Sesion.rol == Rol.alumno.toString()) ...[
                VistaAlumno(),
              ] else if (Sesion.rol == Rol.profesor.toString()) ...[
                VistaProfesor()
              ] else if (Sesion.rol == Rol.administrador.toString()) ...[
                VistaAdministrador()
              ] else if (Sesion.rol == Rol.programador.toString()) ...[
                VistaProgramador()
              ]
            ],
          )),
    );
  }

  ///Este método devuelve toda la vista que va a ver el profesor en un Widget.
  Widget VistaProfesor() {
    return Container();
  }

  ///Este método devuelve toda la vista que va a ver el alumno en un Widget.
  Widget VistaAlumno() {
    return Container(
      padding: EdgeInsets.all(10),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (int i = 0; i < 3; i++)
            //TAREA
            ElevatedButton(
              style: ButtonStyle(shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder( borderRadius: BorderRadius.circular(18.0))
              )),
                child: Container(
                  constraints: BoxConstraints(maxWidth: 100, minWidth: 60),
                  width: 10,
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: Colors.lightGreenAccent,
                      borderRadius: BorderRadius.circular(20)),
                  alignment: Alignment.center,
                  child: Column(children: [
                    Image(image: NetworkImage(imagenes[i])),
                    Text(
                      nombres[i],
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ]),
                ),
                onPressed: () {
                  _speak(nombres[i]);
                }),
        ],
      ),
    );
  }

  ///Este método devuelve toda la vista que va a ver el administrador en un Widget.
  Widget VistaAdministrador() {
    return Container();
  }

  Widget VistaProgramador() {
    return Container(
      //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
      child: Column(
        children: [],
      ),
    );
  }

  void actualizar() async {
    setState(() {});
  }

  void _speak(text) async {
    await tts.speak(text);
  }
}
