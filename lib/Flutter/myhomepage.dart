/*
*   Archivo: myhomepage.dart
*
*   Descripción:
*   Muestra el menú principal de la aplicacion
*   Includes:
*   cloud_firestore.dart : Necesario para implementar los métodos que acceden a la base de datos
*   sesion.dart : Contiene los datos de la sesion actual (sirve de puntero a la página actual donde se encuentra el usuario)
*   video_player.dart : Necesario para cargar los videos del storage y cargarlos en el controlador de los reproductores de video. 
*   rol.dart : Enumerado con los roles de usuarios que existen en la aplicacion.
*   acceso_bd.dart: Metodos de acceso a la base de datos.
*   material.dart: Se utiliza para dar colores y diseño a la aplicacion.
*   crear_tarea.dart : Redirecciona al formulario de crear tarea.
*   registro_usuarios.dart : Redirecciona al formulario de registro de usuarios.
*   tablon_comunicacion.dart : Redirecciona a la pagina del tablon de comunicacion.
*   ver_tareas.dart : Redirecciona a la pagina de lista de tareas.
*   lista_alumnos.dart: Redirecciona a la pagina de lista de alumnos.
*   lista_profesores.dart :  Redirecciona a la pagina de lista de profesores.
*   image_picker.dart : Libreria para acceder a la cámara y a la galería de imagenes del dispositivo.
* */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Flutter/crear_tarea.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:colegio_especial_dgp/Flutter/gestion_tablon.dart';
import 'package:colegio_especial_dgp/Flutter/registro_usuarios.dart';
import 'package:colegio_especial_dgp/Flutter/tablon_comunicacion.dart';
import 'package:colegio_especial_dgp/Flutter/ver_tareas.dart';
import 'package:flutter/material.dart';
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
              Text('Menú principal'.toUpperCase()),
            ]),
            automaticallyImplyLeading: false,
          ),
          body: Container(margin: EdgeInsets.all(5), child: vistaMenu())),
      onWillPop: () async {
        final pop = await _onBackPressed(context);
        return pop ?? false;
      },
    );
  }

  ///Este método devuelve toda la vista que va a ver el profesor en un Widget.
  Widget VistaProfesor() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                        Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        //margin: EdgeInsets.all(10),
                        child: Container(
                          margin: EdgeInsets.all(50),
                          child: ElevatedButton(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Lista de alumnos".toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.white,
                                  ),
                                ),
                                Flexible(
                                    flex: 1,
                                    child: Image.asset(
                                      "assets/companeros.png",
                                    )),
                              ],
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ListaAlumnos()));
                            },
                          ),
                        ),
                      ),

                  ]))
        ]);
  }

  ///Este método devuelve toda la vista que va a ver el alumno en un Widget.
  Widget VistaAlumno() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  //margin: EdgeInsets.all(10),
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child: ElevatedButton(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Tablon de Comunicación".toUpperCase(),
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                            ),
                          ),
                          Flexible(
                              flex: 1,
                              child: Image.asset(
                                "assets/tableroDeComunicacion.png",
                              )),
                        ],
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TablonComunicacion()));
                      },
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child: ElevatedButton(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Lista de Tareas".toUpperCase(),
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                            ),
                          ),
                          Flexible(
                              flex: 1,
                              child: Image.asset(
                                "assets/lectoescritura.png",
                              )),
                        ],
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VerTareas()));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]);
  }

  ///Este método devuelve toda la vista que va a ver el administrador en un Widget.
  Widget VistaAdministrador() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    //margin: EdgeInsets.all(10),
                    child: Container(
                      margin: EdgeInsets.all(10),
                      child: ElevatedButton(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Lista de alumnos".toUpperCase(),
                              style: TextStyle(
                                fontSize: 30,
                                color: Colors.white,
                              ),
                            ),
                            Flexible(
                                flex: 1,
                                child: Image.asset(
                                  "assets/companeros.png",
                                )),
                          ],
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ListaAlumnos()));
                        },
                      ),
                    ),
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child: ElevatedButton(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Lista de Profesores".toUpperCase(),
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                            ),
                          ),
                          Flexible(
                              flex: 1,
                              child: Image.asset(
                                "assets/profesor.png",
                              )),
                        ],
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ListaProfesores()));
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child: ElevatedButton(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Registrar Usuarios".toUpperCase(),
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                            ),
                          ),
                          Flexible(
                              flex: 1,
                              child: Image.asset(
                                "assets/madurez.png",
                              )),
                        ],
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => RegistroUsuarios()));
                      },
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child: ElevatedButton(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Crear Tareas".toUpperCase(),
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                            ),
                          ),
                          Flexible(
                              flex: 1,
                              child: Image.asset(
                                "assets/correcto.png",
                              )),
                        ],
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CrearTarea()));
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
          //GESTION DEL TABLON
          Flexible(
            flex: 1,
            fit: FlexFit.tight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child: ElevatedButton(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "GESTION DEL TABLON",
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                            ),
                          ),
                          Flexible(
                              flex: 1,
                              child: Image.asset(
                                "assets/tableroDeComunicacion.png",
                              )),
                        ],
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GestionTablon()));
                      },
                    ),
                  ),
                ),
                ///EDICION DE TAREAS
                Flexible(
                  flex: 1,
                  fit: FlexFit.tight,
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child: ElevatedButton(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "LISTA DE TAREAS",
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                            ),
                          ),
                          Flexible(
                              flex: 1,
                              child: Image.asset(
                                "assets/lista.png",
                              )),
                        ],
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CrearTarea()));
                      },
                    ),
                  ),
                )
              ],
            ),
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
            title: const Text('¿SEGURO?'),
            content: Text('¿QUIERES CERRAR SESIÓN?'),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: Text('NO')),
              ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: Text('SÍ')),
            ],
          );
        });
  }

  // Vista del menu dependiendo del rol
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

  // Vista horizontal
  buildLandscape() {
    maxUsuariosPorFila = 3;
    return SingleChildScrollView(
        controller: homeController, child: vistaMenu());
  }

  // Vista vertical
  buildPortrait() {
    maxUsuariosPorFila = 2;
    return SingleChildScrollView(
        controller: homeController, child: vistaMenu());
  }

  // Metodo para actualizar la pagina
  void actualizar() async {
    setState(() {});
  }
}
