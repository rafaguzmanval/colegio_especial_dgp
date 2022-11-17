/*
*   Archivo: tablon_comunicacion.dart
*
*   Descripción:
*   Tablón de comunicacion de los alumnos a profesores con botones que emiten sonidos con significado.
*   Includes:
*   cloud_firestore.dart : Necesario para implementar los métodos que acceden a la base de datos
*   sesion.dart : Contiene los datos de la sesion actual (sirve de puntero a la página actual donde se encuentra el usuario)
*   rol.dart : Enumerado con los roles de usuarios que existen en la aplicacion.
*   acceso_bd.dart: Metodos de acceso a la base de datos.
*   material.dart: Se utiliza para dar colores y diseño a la aplicacion.
*   flutter_tts.dart : Convertir un string en audio
* */

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:flutter/material.dart';
import "package:flutter_tts/flutter_tts.dart";

class TablonComunicacion extends StatefulWidget {
  @override
  TablonComunicacionState createState() => TablonComunicacionState();
}

class TablonComunicacionState extends State<TablonComunicacion> {
  var indiceTextos = 0;
  var indiceImagenes = 0;
  bool verFlechaIzquierda = true;
  bool verFlechaDerecha = true;
  double offSetActual = 0;
  ScrollController homeController = new ScrollController();
  double offSetActual2 = 0;
  ScrollController homeController2 = new ScrollController();
  double offSetActual3 = 0;
  ScrollController homeController3 = new ScrollController();

  var nombres = ["hola", "carne", "caca", "ayuda"];
  var imagenes = [
    "https://firebasestorage.googleapis.com/v0/b/colegioespecialdgp.appspot.com/o/Im%C3%A1genes%2Fpictogramas%2Fhola.png?alt=media&token=8985d5de-d0a5-4c53-a427-32f9241917d3",
    "https://firebasestorage.googleapis.com/v0/b/colegioespecialdgp.appspot.com/o/Im%C3%A1genes%2Fpictogramas%2Fcarne.png?alt=media&token=842b044f-a900-4a19-a697-df8799eba89c",
    "https://firebasestorage.googleapis.com/v0/b/colegioespecialdgp.appspot.com/o/Im%C3%A1genes%2Fpictogramas%2Fcaca.png?alt=media&token=f838fb98-bb18-43de-b27f-09dd5fa038a2",
    "https://firebasestorage.googleapis.com/v0/b/colegioespecialdgp.appspot.com/o/Im%C3%A1genes%2Fpictogramas%2Fayuda.png?alt=media&token=8c7910ed-7885-475b-92c0-7d3fb8d24584"
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

  // Este metodo inicializa el text to speech con sus caracteristicas
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
      body: SingleChildScrollView(
          child: Container(
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
              ))),
    );
  }

  ///Este método devuelve toda la vista que va a ver el profesor en un Widget.
  Widget VistaProfesor() {
    return Container();
  }

  ///Este método devuelve toda la vista que va a ver el alumno en un Widget.
  Widget VistaAlumno() {
    return Column(children: [
      SizedBox(
        height: 10,
      ),
      Stack(alignment: Alignment.center, children: [
        SingleChildScrollView(
          controller: homeController,
          scrollDirection: Axis.horizontal,
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.amberAccent,
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  for (int i = 0; i < 4; i++)
                    //TAREA
                    Container(
                      margin: EdgeInsets.all(10),
                      child: ElevatedButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18.0)))),
                          child: Container(
                            constraints:
                                BoxConstraints(maxWidth: 100, minWidth: 60),
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
                    ),
                ],
              )),
        ),
        Container(
            margin: EdgeInsets.only(left: 10),
            alignment: Alignment.topLeft,
            child: FittedBox(
              child: Visibility(
                child: FloatingActionButton(
                    elevation: 1.0,
                    heroTag: "flechaDerecha",
                    onPressed: () {
                      offSetActual -= 100.0;
                      if (offSetActual <
                          homeController.position.minScrollExtent)
                        offSetActual = homeController.position.minScrollExtent;

                      homeController.animateTo(
                        offSetActual, // change 0.0 {double offset} to corresponding widget position
                        duration: Duration(seconds: 1),
                        curve: Curves.easeOut,
                      );
                    },
                    child: const Icon(Icons.arrow_left)),
                visible: verFlechaDerecha,
              ),
            )),
        Container(
            margin: EdgeInsets.only(right: 10),
            alignment: Alignment.topRight,
            child: FittedBox(
              child: Visibility(
                child: FloatingActionButton(
                    elevation: 1.0,
                    heroTag: "flechaDerecha",
                    onPressed: () {
                      offSetActual += 100;

                      if (offSetActual >
                          homeController.position.maxScrollExtent)
                        offSetActual = homeController.position.maxScrollExtent;

                      homeController.animateTo(
                        offSetActual, // change 0.0 {double offset} to corresponding widget position
                        duration: Duration(seconds: 1),
                        curve: Curves.easeOut,
                      );
                    },
                    child: const Icon(Icons.arrow_right)),
                visible: verFlechaDerecha,
              ),
            )),
      ]),
      SizedBox(
        height: 10,
      ),
      Stack(alignment: Alignment.center, children: [
        SingleChildScrollView(
          controller: homeController2,
          scrollDirection: Axis.horizontal,
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  for (int i = 0; i < 4; i++)
                    //TAREA
                    Container(
                      margin: EdgeInsets.all(10),
                      child: ElevatedButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18.0)))),
                          child: Container(
                            constraints:
                                BoxConstraints(maxWidth: 100, minWidth: 60),
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
                    ),
                ],
              )),
        ),
        Container(
            margin: EdgeInsets.only(left: 10),
            alignment: Alignment.topLeft,
            child: FittedBox(
              child: Visibility(
                child: FloatingActionButton(
                    elevation: 1.0,
                    heroTag: "flechaDerecha",
                    onPressed: () {
                      offSetActual2 -= 100.0;
                      if (offSetActual2 <
                          homeController2.position.minScrollExtent)
                        offSetActual2 =
                            homeController2.position.minScrollExtent;

                      homeController2.animateTo(
                        offSetActual, // change 0.0 {double offset} to corresponding widget position
                        duration: Duration(seconds: 1),
                        curve: Curves.easeOut,
                      );
                    },
                    child: const Icon(Icons.arrow_left)),
                visible: verFlechaDerecha,
              ),
            )),
        Container(
            margin: EdgeInsets.only(right: 10),
            alignment: Alignment.topRight,
            child: FittedBox(
              child: Visibility(
                child: FloatingActionButton(
                    elevation: 1.0,
                    heroTag: "flechaDerecha",
                    onPressed: () {
                      offSetActual2 += 100;

                      if (offSetActual2 >
                          homeController2.position.maxScrollExtent)
                        offSetActual2 =
                            homeController2.position.maxScrollExtent;

                      homeController2.animateTo(
                        offSetActual2, // change 0.0 {double offset} to corresponding widget position
                        duration: Duration(seconds: 1),
                        curve: Curves.easeOut,
                      );
                    },
                    child: const Icon(Icons.arrow_right)),
                visible: verFlechaDerecha,
              ),
            )),
      ]),
      SizedBox(
        height: 10,
      ),
      Stack(alignment: Alignment.center, children: [
        SingleChildScrollView(
          controller: homeController3,
          scrollDirection: Axis.horizontal,
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.deepOrangeAccent,
                  borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  for (int i = 0; i < 4; i++)
                    //TAREA
                    Container(
                      margin: EdgeInsets.all(10),
                      child: ElevatedButton(
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(18.0)))),
                          child: Container(
                            constraints:
                                BoxConstraints(maxWidth: 100, minWidth: 60),
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
                    ),
                ],
              )),
        ),
        Container(
            margin: EdgeInsets.only(left: 10),
            alignment: Alignment.topLeft,
            child: FittedBox(
              child: Visibility(
                child: FloatingActionButton(
                    elevation: 1.0,
                    heroTag: "flechaDerecha",
                    onPressed: () {
                      offSetActual3 -= 100.0;
                      if (offSetActual3 <
                          homeController3.position.minScrollExtent)
                        offSetActual3 =
                            homeController3.position.minScrollExtent;

                      homeController3.animateTo(
                        offSetActual, // change 0.0 {double offset} to corresponding widget position
                        duration: Duration(seconds: 1),
                        curve: Curves.easeOut,
                      );
                    },
                    child: const Icon(Icons.arrow_left)),
                visible: verFlechaDerecha,
              ),
            )),
        Container(
            margin: EdgeInsets.only(right: 10),
            alignment: Alignment.topRight,
            child: FittedBox(
              child: Visibility(
                child: FloatingActionButton(
                    elevation: 1.0,
                    heroTag: "flechaDerecha",
                    onPressed: () {
                      offSetActual3 += 100;

                      if (offSetActual3 >
                          homeController3.position.maxScrollExtent)
                        offSetActual3 =
                            homeController3.position.maxScrollExtent;

                      homeController3.animateTo(
                        offSetActual3, // change 0.0 {double offset} to corresponding widget position
                        duration: Duration(seconds: 1),
                        curve: Curves.easeOut,
                      );
                    },
                    child: const Icon(Icons.arrow_right)),
                visible: verFlechaDerecha,
              ),
            )),
      ]),
    ]);
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

  // Este metodo actualiza la pagina
  void actualizar() async {
    setState(() {});
  }

  // Este metodo lee el texto y que se escuche por los altavoces
  void _speak(text) async {
    await tts.speak(text);
  }
}
