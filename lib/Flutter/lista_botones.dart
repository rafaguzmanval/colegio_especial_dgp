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

import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/guardado_local.dart';
import 'package:colegio_especial_dgp/Flutter/perfil_boton.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:flutter/material.dart';
import 'package:colegio_especial_dgp/Flutter/search_boton.dart';

class ListaBotones extends StatefulWidget {
  @override
  ListaBotonesState createState() => ListaBotonesState();
}

class ListaBotonesState extends State<ListaBotones> {

  double offSetActual = 0;
  ScrollController homeController = new ScrollController();
  bool esBotonEliminandose = false;
  int botonEliminandose = 0;

  @override
  void initState() {
    super.initState();

    Sesion.paginaActual = this;

    Sesion.seleccion = "";
    Sesion.tablon = [];

    if (Sesion.rol != Rol.alumno.toString()) {
      cargarTablon();
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
                await showSearch(context: context, delegate: CustomSearchDelegate(),);
                setState(() {});
              },
              icon: const Icon(Icons.search),
            ),
          ],
          title: Center(
              child: Text(
                'Lista de botones'.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(color: GuardadoLocal.colores[2], fontSize: 30),
              )),
        ),
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
                child:
                Icon(Icons.arrow_downward, color: GuardadoLocal.colores[2]),
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
    return _listaBotones();
  }

  ///Este método devuelve toda la vista que va a ver el alumno en un Widget.
  Widget VistaAlumno() {
    Navigator.pop(context);
    return Container();
  }

  ///Este método devuelve toda la vista que va a ver el administrador en un Widget.
  Widget VistaAdministrador() {
    return _listaBotones();
  }

  // Este metodo devuelve una lista con todos los profesores
  Widget _listaBotones() {
    return Container(
      alignment: Alignment.center,
      //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < Sesion.tablon.length; i++) ...[
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: 200,
                      height: 220,
                      margin: EdgeInsets.all(20),
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        child: Column(
                          children: [
                            Text(
                              Sesion.tablon[i].nombres.toString().toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 25,
                                color: GuardadoLocal.colores[2],
                              ),
                            ),
                            if (!Sesion.tablon[i].imagenes.isEmpty) ...[
                              Image.network(
                                Sesion.tablon[i].imagenes,
                                width: 150,
                                height: 150,
                                fit: BoxFit.fill,
                              ),
                            ]
                          ],
                        ),
                        onPressed: () async {
                          Sesion.seleccion = Sesion.tablon[i];
                          await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Perfilboton()));
                          cargarTablon();
                        },
                      )),
                  IconButton(
                      onPressed: () async {

                        await Sesion.db.eliminarTablon(Sesion.tablon[i].id).then(
                                (e){
                              esBotonEliminandose = true;
                              botonEliminandose = i;
                              cargarTablon();
                            }
                        );


                      },
                      icon: Icon(
                        Icons.delete,
                        color: GuardadoLocal.colores[0],
                      )),
                  if (esBotonEliminandose && i == botonEliminandose) ...[
                    new CircularProgressIndicator(),
                  ]
                ])
          ]
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
      child: cargando(),
    );
  }

  buildPortrait() {
    return SingleChildScrollView(
      controller: homeController,
      child: cargando(),
    );
  }

  Widget cargando() {
    if (Sesion.tablon == null)
      return Center(
        child: Text(
          '\nCARGANDO LOS BOTONES',
          textAlign: TextAlign.center,
        ),
      );
    else {
      return lista();
    }
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
  cargarTablon() async {
    Sesion.tablon = await Sesion.db.consultarTodosTablon();
    actualizar();
  }

  // metodo para actualizar la pagina
  void actualizar() async {
    setState(() {});
    esBotonEliminandose = false;
  }
}
