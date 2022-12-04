/*
*   Archivo: lista_profesores.dart
*
*   Descripción:
*   Pagina para consultar la lista de profesores y acceder a sus perfiles
*   Includes:
*   cloud_firestore.dart : Necesario para implementar los métodos que acceden a la base de datos
*   sesion.dart : Contiene los datos de la sesion actual (sirve de puntero a la página actual donde se encuentra el usuario)
*   rol.dart : Enumerado con los roles de usuarios que existen en la aplicacion.
*   acceso_bd.dart: Metodos de acceso a la base de datos.
*   material.dart: Se utiliza para dar colores y diseño a la aplicacion.
*   perfil_profesor.dart : Para acceder al perfil del profeosr
* */


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/guardado_local.dart';
import 'package:colegio_especial_dgp/Flutter/perfil_profesor.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:flutter/material.dart';
import 'package:colegio_especial_dgp/Flutter/search_prof.dart';

class ListaProfesores extends StatefulWidget {
  @override
  ListaProfesoresState createState() => ListaProfesoresState();
}

class ListaProfesoresState extends State<ListaProfesores> {

  double offSetActual = 0;
  ScrollController homeController = new ScrollController();


  @override
  void initState() {
    super.initState();

    Sesion.paginaActual = this;

    Sesion.seleccion = "";
    Sesion.tareas = [];
    Sesion.profesores = [];

    if (Sesion.rol != Rol.alumno.toString()) {
      cargarProfesores();
    }
  }

  /// Este es el build de la clase MyHomePage que devuelve toda la vista génerica más la vista especial de cada usuario.
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: GuardadoLocal.colores[2]),
              onPressed: (){Navigator.pop(context);}),
            actions: [
              IconButton(
                onPressed: (){
                  showSearch(context: context, delegate: CustomSearchDelegate(),);
                },
                icon: const Icon(Icons.search),
              ),
            ],
          title: Center(child: Text('Lista de Profesores'.toUpperCase(),textAlign: TextAlign.center,style: TextStyle(color: GuardadoLocal.colores[2],fontSize: 30),),
        )),
        body: Stack(children: [
          OrientationBuilder(
            builder: (context, orientation) =>
                orientation == Orientation.portrait
                    ? buildPortrait()
                    : buildLandscape(),
          ),
          Container(
            alignment: FractionalOffset(0.98, 0.01),
            child: FloatingActionButton(
                heroTag: "botonUp",
                child: Icon(Icons.arrow_upward,color: GuardadoLocal.colores[2],),
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
                child: Icon(Icons.arrow_downward, color: GuardadoLocal.colores[2]),
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
        ]));
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

  // Este metodo devuelve una lista con todos los profesores
  Widget _listaProfesores() {
    return Container(
      alignment: Alignment.center,
      //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
      child: Column(
        children: [
          for (int i = 0; i < Sesion.profesores.length; i++)
            Container(
                width: 130,
                height: 150,
                margin: EdgeInsets.all(10),
                alignment: Alignment.center,
                child: ElevatedButton(
                  child: Column(
                    children: [
                      Text(
                        Sesion.profesores[i].nombre.toString().toUpperCase(),
                        style: TextStyle(
                          color: GuardadoLocal.colores[2],
                          fontSize: 25
                        ),
                      ),
                      Image.network(
                        Sesion.profesores[i].foto,
                        width: 100,
                        height: 100,
                        fit: BoxFit.fill,
                      ),
                    ],
                  ),
                  onPressed: () {
                    Sesion.seleccion = Sesion.profesores[i];
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PerfilProfesor()));
                    cargarProfesores();
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

  // segun el tipo de usuario devuelve diferentes tipos de listas
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

  // metodo para cargar la lista de profesores
  cargarProfesores() async {
    Sesion.profesores = await Sesion.db.consultarTodosProfesores();
    actualizar();
  }

  // metodo para actualizar la pagina
  void actualizar() async {
    setState(() {});
  }
}
