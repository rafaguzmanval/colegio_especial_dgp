import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/discapacidad.dart';
import 'package:colegio_especial_dgp/Flutter/loginpage.dart';
import 'package:colegio_especial_dgp/Flutter/myhomepage.dart';
import 'package:colegio_especial_dgp/Flutter/perfil_alumno.dart';
import 'package:colegio_especial_dgp/Flutter/perfil_profesor.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/clase.dart';
import 'package:colegio_especial_dgp/Dart/usuario.dart';

import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';

import "package:image_picker/image_picker.dart";

import "package:flutter_tts/flutter_tts.dart";

class ListaProfesores extends StatefulWidget {
  @override
  ListaProfesoresState createState() => ListaProfesoresState();
}

class ListaProfesoresState extends State<ListaProfesores> {
  var profesores = [];

  var db = FirebaseFirestore.instance;
  double offSetActual = 0;
  ScrollController homeController = new ScrollController();

  AccesoBD base = new AccesoBD();

  @override
  void initState() {
    super.initState();

    Sesion.paginaActual = this;

    Sesion.seleccion = "";
    Sesion.tareas = [];

    if (Sesion.rol != Rol.alumno.toString()) {
      cargarProfesores();
    }
  }

  /// Este es el build de la clase MyHomePage que devuelve toda la vista génerica más la vista especial de cada usuario.
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: Text('Lista de Profesores'),
      ),
      body: Stack(
          children: [
            OrientationBuilder(builder: (context,orientation)=>
            orientation == Orientation.portrait
                ? buildPortrait()
                : buildLandscape(),

            ),

            Container(
              alignment: FractionalOffset(0.98,0.01),
              child: FloatingActionButton(
                  child: Icon(Icons.arrow_upward),
                  elevation: 1.0,
                  onPressed: (){

                    offSetActual -= 100.0;
                    if(offSetActual < homeController.position.minScrollExtent)
                      offSetActual = homeController.position.minScrollExtent;

                    homeController.animateTo(
                      offSetActual, // change 0.0 {double offset} to corresponding widget position
                      duration: Duration(seconds: 1),
                      curve: Curves.easeOut,
                    );

                  }),
            ),

            Container(
              alignment: FractionalOffset(0.98,0.99),
              child: FloatingActionButton(
                  child: Icon(Icons.arrow_downward),
                  elevation: 1.0,
                  onPressed: (){
                    offSetActual += 100;

                    if(offSetActual > homeController.position.maxScrollExtent)
                      offSetActual = homeController.position.maxScrollExtent;


                    homeController.animateTo(
                      offSetActual, // change 0.0 {double offset} to corresponding widget position
                      duration: Duration(seconds: 1),
                      curve: Curves.easeOut,
                    );

                  }),
            ),
          ]
      )
    );
  }

  ///Este método devuelve toda la vista que va a ver el profesor en un Widget.
  Widget VistaProfesor() {
    return _listaProfesores();
  }

  ///Este método devuelve toda la vista que va a ver el alumno en un Widget.
  Widget VistaAlumno() {
    Navigator.pop(context);
    return Container();
  }

  ///Este método devuelve toda la vista que va a ver el administrador en un Widget.
  Widget VistaAdministrador() {
    return _listaProfesores();
  }

  Widget _listaProfesores() {
    return Container(
      alignment: Alignment.center,
      //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
      child: Column(
        children: [
          for (int i = 0; i < profesores.length; i++)
            Container(
                width:100,
                height: 100,
                margin: EdgeInsets.all(10),
                alignment: Alignment.center,
                child: ElevatedButton(
                  child: Column(
                    children: [
                      Text(
                        profesores[i].nombre,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      Image.network(
                        profesores[i].foto,
                        width: 100,
                        height: 70,
                        fit: BoxFit.fill,
                      ),
                    ],
                  ),
                  onPressed: () {
                    Sesion.seleccion = profesores[i];
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PerfilProfesor()));
                  },
                ))
        ],
      ),
    );
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

  buildLandscape()
  {
    return
      SingleChildScrollView(
        controller: homeController,
        child: lista(),
      );
  }


  buildPortrait()
  {
    return
      SingleChildScrollView(
        controller: homeController,
        child: lista(),
      );

  }

  lista()
  {
    if(Sesion.rol == Rol.alumno.toString()) {
      return VistaAlumno();
    }
    else if(Sesion.rol == Rol.profesor.toString()) {
      return VistaProfesor();
    }
    else if(Sesion.rol == Rol.administrador.toString()) {
      return  VistaAdministrador();
    }
    else if(Sesion.rol == Rol.programador.toString()) {
      return VistaProgramador();
    }
  }

  cargarProfesores() async {
    profesores = await base.consultarTodosProfesores();
    actualizar();
  }

  void actualizar() async {
    setState(() {});
  }
}
