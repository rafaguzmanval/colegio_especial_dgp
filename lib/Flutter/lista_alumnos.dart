/*
*   Archivo: lista_alumnos.dart
*
*   Descripción:
*   Pagina para consultar la lista de alumnos y acceder a sus perfiles
*   Includes:
*   cloud_firestore.dart : Necesario para implementar los métodos que acceden a la base de datos
*   sesion.dart : Contiene los datos de la sesion actual (sirve de puntero a la página actual donde se encuentra el usuario)
*   rol.dart : Enumerado con los roles de usuarios que existen en la aplicacion.
*   acceso_bd.dart: Metodos de acceso a la base de datos.
*   material.dart: Se utiliza para dar colores y diseño a la aplicacion.
*   perfil_alumno.dart: Para redireccionar a la pagina de perfil del alumno
* */

import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/guardado_local.dart';
import 'package:colegio_especial_dgp/Flutter/perfil_alumno.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:flutter/material.dart';
import 'package:colegio_especial_dgp/Flutter/search_alumno.dart';

class ListaAlumnos extends StatefulWidget {
  @override
  ListaAlumnosState createState() => ListaAlumnosState();
}

class ListaAlumnosState extends State<ListaAlumnos> {
  double offSetActual = 0;
  ScrollController homeController = new ScrollController();
  bool esAlumnoEliminandose = false;
  int alumnoEliminandose = 0;

  @override
  void initState() {
    super.initState();

    Sesion.paginaActual = this;
    Sesion.seleccion = "";
    Sesion.tareas = [];
    Sesion.alumnos = [];

    if (Sesion.rol != Rol.alumno.toString()) {
      cargarAlumnos();
    }
  }

  /// Este es el build de la clase MyHomePage que devuelve toda la vista génerica más la vista especial de cada usuario.
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: GuardadoLocal.colores[2]),
              onPressed: () {
                Navigator.pop(context);
              }),
          actions: [
            IconButton(
              onPressed: () async{
                //await showSearch(context: context, delegate: CustomSearchDelegate(),);
                //setState(() {});
              },
              icon: Icon(Icons.search,color: GuardadoLocal.colores[2],),
            ),
          ],
          title: Center(
            child: Text(
              'LISTA DE ALUMNOS',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold,color: GuardadoLocal.colores[2], fontSize: 30),
            ),
          )),
      body: Stack(children: [
        OrientationBuilder(
          builder: (context, orientation) => orientation == Orientation.portrait
              ? buildPortrait()
              : buildLandscape(),
        ),
        Container(
          alignment: FractionalOffset(0.98, 0.01),
          child: FloatingActionButton(
              heroTag: "botonUp",
              child: Icon(
                Icons.arrow_upward,
                color: GuardadoLocal.colores[2],
              ),
              elevation: 1.0,
              onPressed: () {
                offSetActual -= 100.0;
                if (offSetActual < homeController.position.minScrollExtent)
                  offSetActual = homeController.position.minScrollExtent;

                homeController.animateTo(
                  offSetActual, // change 0.0 {double offset} to corresponding widget position
                  duration: Duration(seconds: 1),
                  curve: Curves.easeOut,
                );
              }),
        ),
        Container(
          alignment: FractionalOffset(0.98, 0.99),
          child: FloatingActionButton(
              heroTag: "botonDown",
              child: Icon(
                Icons.arrow_downward,
                color: GuardadoLocal.colores[2],
              ),
              elevation: 1.0,
              onPressed: () {
                offSetActual += 100;

                if (offSetActual > homeController.position.maxScrollExtent)
                  offSetActual = homeController.position.maxScrollExtent;

                homeController.animateTo(
                  offSetActual, // change 0.0 {double offset} to corresponding widget position
                  duration: Duration(seconds: 1),
                  curve: Curves.easeOut,
                );
              }),
        ),
      ]),
    );
  }

  ///Este método devuelve toda la vista que va a ver el profesor en un Widget.
  Widget VistaProfesor() {
    return _listaAlumnos();
  }

  ///Este método devuelve toda la vista que va a ver el alumno en un Widget.
  Widget VistaAlumno() {
    Navigator.pop(context);
    return Container();
  }

  ///Este método devuelve toda la vista que va a ver el administrador en un Widget.
  Widget VistaAdministrador() {
    return _listaAlumnos();
  }

  // Metodo que muestra la lista de los alumnos
  Widget _listaAlumnos() {
    return Container(
      alignment: Alignment.center,
      //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
      child: Column(children: [
        for (int i = 0; i < Sesion.alumnos.length; i++) ...[
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
                margin: EdgeInsets.all(10),
                alignment: Alignment.center,
                child: Container(width: 170, child:ElevatedButton(
                  child: Column(
                    children: [
                      Text(
                        Sesion.alumnos[i].nombre.toString().toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold,
                          color: GuardadoLocal.colores[2],
                          fontSize: 25,
                        ),
                      ),
                      if(Sesion.alumnos[i].foto is String)...[
                      Image.network(
                        Sesion.alumnos[i].foto,
                        width: 120,
                        height: 120,
                        fit: BoxFit.fill,
                      ),
                        SizedBox(height: 10,),
    ]
                    ],
                  ),
                  onPressed: () async {
                    Sesion.seleccion = Sesion.alumnos[i];
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PerfilAlumno()));
                    cargarAlumnos();
                  },
                ))),
            if(Sesion.rol == Rol.administrador.toString())...[
              IconButton(
                  onPressed: () async {
                      _onEliminate(context, i);
                    },
                  icon: Icon(
                    Icons.delete,
                    color: GuardadoLocal.colores[0],
                  )),
            ],
            if (esAlumnoEliminandose && i == alumnoEliminandose) ...[
              new CircularProgressIndicator(),
            ]
          ])
        ],
      ]),
    );
  }

  // Vista programador. No uso

  Widget VistaProgramador() {
    return Container(
      //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
      child: Column(
        children: [],
      ),
    );
  }

  // Obtiene la lista de alumnos y actualiza la pagina
  cargarAlumnos() async {
    Sesion.alumnos = await Sesion.db.consultarTodosAlumnos();
    actualizar();
  }

  buildLandscape() {
    return SingleChildScrollView(
      controller: homeController,
      child: lista(),
    );
  }

  buildPortrait() {
    return SingleChildScrollView(
      controller: homeController,
      child: lista(),
    );
  }

  // dependiendo del rol, adapta la vida
  lista() {
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

  Future<bool?> _onEliminate(BuildContext context,i) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: GuardadoLocal.colores[1],
            title:  Text('¿SEGURO?',style: TextStyle(color: GuardadoLocal.colores[0],fontSize: 25),),
            content: Text('¿QUIERES ELIMINAR A ${Sesion.alumnos[i].nombre}?',style: TextStyle(color: GuardadoLocal.colores[0],fontSize: 25),),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('NO',style: TextStyle(color: GuardadoLocal.colores[2],fontSize: 25),)),

              ElevatedButton(
                  onPressed: () async{
                    await Sesion.db
                        .eliminarAlumno(Sesion.alumnos[i].id)
                        .then((e) {
                    esAlumnoEliminandose = true;
                    alumnoEliminandose = i;
                    cargarAlumnos();
                    Navigator.pop(context);
                  }
                 );},
                  child: Text('SÍ',style: TextStyle(color: GuardadoLocal.colores[2],fontSize: 25))
                )
            ],
          );
        });
  }

  // Actualizar
  void actualizar() async {
    setState(() {});
    esAlumnoEliminandose = false;
  }
}
