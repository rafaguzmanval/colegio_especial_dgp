import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/discapacidad.dart';
import 'package:colegio_especial_dgp/Flutter/crear_tarea.dart';
import 'package:colegio_especial_dgp/Flutter/loginpage.dart';
import 'package:colegio_especial_dgp/Flutter/perfil_alumno.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/clase.dart';
import 'package:colegio_especial_dgp/Dart/usuario.dart';

import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:colegio_especial_dgp/Flutter/registro_usuarios.dart';
import 'package:colegio_especial_dgp/Flutter/tablon_comunicacion.dart';
import 'package:colegio_especial_dgp/Flutter/ver_tareas.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:video_player/video_player.dart';

import "package:image_picker/image_picker.dart";

import "package:flutter_tts/flutter_tts.dart";

import 'lista_alumnos.dart';
import 'lista_profesores.dart';

enum SeleccionImagen { camara, galeria }

class MyHomePage extends StatefulWidget {
  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  var db = FirebaseFirestore.instance;
  AccesoBD base = new AccesoBD();
  var maxUsuariosPorFila = 2;
  double offSetActual = 0;
  ScrollController homeController = new ScrollController();

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
  }

  /// Este es el build de la clase MyHomePage que devuelve toda la vista génerica más la vista especial de cada usuario.
  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      child: new Scaffold(
          appBar: AppBar(
            leading: IconButton(
                icon: Icon(Icons.settings_power, color: Colors.white),
                onPressed: () => _onBackPressed(context)),
            title: Column(children: [
              Text('Menú principal'),
            ]),
            automaticallyImplyLeading: false,
          ),
          body: Stack(alignment: Alignment.center, children: [
            OrientationBuilder(
              builder: (context, orientation) =>
                  orientation == Orientation.portrait
                      ? Center(child:buildPortrait())
                      : Center(child:buildLandscape()),
            ),
          ])),
      onWillPop: () async {
        final pop = await _onBackPressed(context);
        return pop ?? false;
      },
    );
  }

  ///Este método devuelve toda la vista que va a ver el profesor en un Widget.
  Widget VistaProfesor() {
    return Container(
      alignment: Alignment.center,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(160, 100), //////// HERE
          ),
          child: Column(
            children: [
              Text(
                "Lista de alumnos",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              Image.asset(
                "assets/companeros.png",
                width: 130,
                height: 80,
                fit: BoxFit.fill,
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ListaAlumnos()));
          },
        ),
      ]),
    );
  }

  ///Este método devuelve toda la vista que va a ver el alumno en un Widget.
  Widget VistaAlumno() {
    return Container(
      alignment: Alignment.center,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(160, 100), //////// HERE
          ),
          child: Column(
            children: [
              Text(
                "Tablon de Comunicacion",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              Image.asset(
                "assets/tableroDeComunicacion.png",
                width: 130,
                height: 80,
                fit: BoxFit.fill,
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => TablonComunicacion()));
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: Size(160, 100), //////// HERE
          ),
          child: Column(
            children: [
              Text(
                "Lista de Tareas",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              Image.asset(
                "assets/lectoescritura.png",
                width: 130,
                height: 80,
                fit: BoxFit.fill,
              ),
            ],
          ),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => VerTareas()));
          },
        ),
      ]),
    );
  }

  ///Este método devuelve toda la vista que va a ver el administrador en un Widget.
  Widget VistaAdministrador() {
    return Column(children: [
      Container(
          alignment: Alignment.center,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(160, 100), //////// HERE
              ),
              child: Column(
                children: [
                  Text(
                    "Lista de alumnos",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  Image.asset(
                    "assets/companeros.png",
                    width: 130,
                    height: 80,
                    fit: BoxFit.fill,
                  ),
                ],
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ListaAlumnos()));
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(160, 100), //////// HERE
              ),
              child: Column(
                children: [
                  Text(
                    "Lista de Profesores",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  Image.asset(
                    "assets/profesor.png",
                    width: 130,
                    height: 80,
                    fit: BoxFit.fill,
                  ),
                ],
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ListaProfesores()));
              },
            ),
          ])),
      Container(
        padding: EdgeInsets.only(top: 50),
        alignment: Alignment.center,
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(160, 100), //////// HERE
            ),
            child: Column(
              children: [
                Text(
                  "Registro de Usuario",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                Image.asset(
                  "assets/madurez.png",
                  width: 130,
                  height: 80,
                  fit: BoxFit.fill,
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => RegistroUsuarios()));
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(160, 100), //////// HERE
            ),
            child: Column(
              children: [
                Text(
                  "Crear Tarea",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                Image.asset(
                  "assets/correcto.png",
                  width: 130,
                  height: 80,
                  fit: BoxFit.fill,
                ),
              ],
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CrearTarea()));
            },
          ),
        ]),
      ),
    ]);
  }

  /*
  *
  * */

  Widget VistaProgramador() {
    return Container(
      //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
      child: Column(
        children: [],
      ),
    );
  }

  //Método para cambiar la funcionalidad del botón de volver atrás

  Future<bool?> _onBackPressed(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('¿Seguro?'),
            content: Text('¿Quieres cerrar sesión?'),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text('No')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: Text('Sí')),
            ],
          );
        });
  }

  vistaMenu() {
    if (Sesion.rol == Rol.alumno.toString()) {
      return VistaAlumno();
    } else if (Sesion.rol == Rol.profesor.toString()) {
      return VistaProfesor();
    } else if (Sesion.rol == Rol.administrador.toString()) {
      return VistaAdministrador();
    } else if (Sesion.rol == Rol.programador.toString()) {
      return VistaProgramador();
    }
  }

  buildLandscape() {
    maxUsuariosPorFila = 3;
    return SingleChildScrollView(
        controller: homeController, child: vistaMenu());
  }

  buildPortrait() {
    maxUsuariosPorFila = 2;
    return SingleChildScrollView(
        controller: homeController, child: vistaMenu());
  }

  void actualizar() async {
    setState(() {});
  }
}
