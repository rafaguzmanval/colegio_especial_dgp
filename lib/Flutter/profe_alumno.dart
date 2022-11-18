/*
*   Archivo: loginpage.dart
*
*   Descripción:
*   Pagina que consulta el alumno para ver la lista de tareas pendientes
*   Includes:
*   main.dart : Usar metodos que estan definidos.
*   passport_method.dart : Enumeracion de los metodos de acceso.
*   password_login.dart: Redirigirse a la pagina de password.
*   flutter_local_notifications.dart : Notificaciones.
*   notificacion.dart : Clase para construir las notificaciones.
*   firebase_auth.dart : Acceso a la firebase para autentificación.
*   sesion.dart : Contiene los datos de la sesion actual (sirve de puntero a la página actual donde se encuentra el usuario)
*   acceso_bd.dart: Metodos de acceso a la base de datos.
*   material.dart: Se utiliza para dar colores y diseño a la aplicacion.
* */

import 'package:colegio_especial_dgp/Dart/main.dart';
import 'package:colegio_especial_dgp/Dart/passport_method.dart';
import 'package:colegio_especial_dgp/Flutter/loginpage.dart';
import 'package:colegio_especial_dgp/Flutter/myhomepage.dart';
import 'package:colegio_especial_dgp/Flutter/password_login.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../Dart/notificacion.dart';
import '../Dart/sesion.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:flutter/material.dart';

class ProfeAlumno extends StatefulWidget {
  @override
  ProfeAlumnoState createState() => ProfeAlumnoState();
}

class ProfeAlumnoState extends State<ProfeAlumno> {


  FlutterLocalNotificationsPlugin notificaciones =
  new FlutterLocalNotificationsPlugin();

  var homeController;

  @override
  void initState() {
    super.initState();

    Notificacion.initialize(flutterLocalNotificationsPlugin);
    //Notificacion.showBigTextNotification(title: "Bienvenio", body: "LA gran notificacion", fln: flutterLocalNotificationsPlugin);

  }


// Contructor de la estructura de la pagina
@override
Widget build(BuildContext context) {
  return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('TuCole')),
    body: Center(
  child:
    Row(

    mainAxisAlignment: MainAxisAlignment.spaceEvenly,

    //crossAxisAlignment: CrossAxisAlignment.center,

    children: [
      ElevatedButton(
      child: Text('Profesores'),
      onPressed: () {
        Sesion.argumentos.add("profesores");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      },
    ),
      ElevatedButton(
      child: Text('Alumnos'),
      onPressed: () {
      Sesion.argumentos.add("alumnos");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
      },
      ),
  ],
  ),
    ),
  );
}

}

        

/*
class LoginPageState extends State<LoginPage> {
  AccesoBD base = new AccesoBD();
  var usuarios;
  var imagenUgr;
  var maxUsuariosPorFila = 2;
  double offSetActual = 0;

  bool verBotonAbajo = false, verBotonArriba = false;

  FlutterLocalNotificationsPlugin notificaciones =
      new FlutterLocalNotificationsPlugin();

  var homeController;

  @override
  void initState() {
    super.initState();
    obtenerAutenticacion();
    inicializar();
    Notificacion.initialize(flutterLocalNotificationsPlugin);
    //Notificacion.showBigTextNotification(title: "Bienvenio", body: "LA gran notificacion", fln: flutterLocalNotificationsPlugin);
    Sesion.reload();
    Sesion.paginaActual = this;
    homeController = new ScrollController();
    homeController.addListener(_scrollListener);
  }

  _scrollListener() {
    if (homeController.position.maxScrollExtent > 0) {
      if (homeController.offset >= homeController.position.maxScrollExtent &&
          !homeController.position.outOfRange) {
        setState(() {
          //Cuando llega al fondo del scroll
          verBotonAbajo = false;
          verBotonArriba = true;
        });
      }
      if (homeController.offset <= homeController.position.minScrollExtent &&
          !homeController.position.outOfRange) {
        setState(() {
          //Cuando está al empezar el scroll
          verBotonArriba = false;
          verBotonAbajo = true;
        });
      }

      if (homeController.offset > homeController.position.minScrollExtent &&
          homeController.offset < homeController.position.maxScrollExtent) {
        setState(() {
          verBotonArriba = true;
          verBotonAbajo = true;
        });
      }
    } else {
      verBotonArriba = false;
      verBotonAbajo = false;
    }
  }

  // Metodo para acceder a la autenticacion
  obtenerAutenticacion() async {
    try {
      Sesion.credenciales = await FirebaseAuth.instance.signInAnonymously();
      print("Signed in with temporary account.");
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          print("Anonymous auth hasn't been enabled for this project.");
          break;
        default:
          print("Unknown error.");
      }
    }
  }

  // Contructor de la estructura de la pagina
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: Text('TuCole')),
        body: Stack(children: [
          ListaUsuarios(),
          Visibility(
            visible: verBotonArriba,
            child: Container(
              alignment: FractionalOffset(0.98, 0.01),
              child: FloatingActionButton(
                  heroTag: "botonUp",
                  child: Icon(Icons.arrow_upward),
                  elevation: 1.0,
                  onPressed: () {
                    offSetActual -= 150.0;
                    if (offSetActual <=
                        homeController.position.minScrollExtent) {
                      offSetActual = homeController.position.minScrollExtent;
                    } else {
                      verBotonAbajo = true;
                    }

                    _actualizar();

                    homeController.animateTo(
                      offSetActual, // change 0.0 {double offset} to corresponding widget position
                      duration: Duration(seconds: 1),
                      curve: Curves.easeOut,
                    );
                  }),
            ),
          ),
          Visibility(
            visible: verBotonAbajo,
            child: Container(
              alignment: FractionalOffset(0.98, 0.99),
              child: FloatingActionButton(
                  heroTag: "botonDown",
                  child: Icon(Icons.arrow_downward),
                  elevation: 1.0,
                  onPressed: () {
                    offSetActual += 150;

                    if (offSetActual >=
                        homeController.position.maxScrollExtent) {
                      offSetActual = homeController.position.maxScrollExtent;
                    } else {
                      verBotonArriba = true;
                    }

                    _actualizar();

                    homeController.animateTo(
                      offSetActual, // change 0.0 {double offset} to corresponding widget position
                      duration: Duration(seconds: 1),
                      curve: Curves.easeOut,
                    );
                  }),
            ),
          ),
        ]));
  }

  // Metodo para inicializar y cargar los datos necesarios
  inicializar() async {
    usuarios = await base.consultarTodosUsuarios();
    imagenUgr = await lecturaImagen("AppStorage/ugr.png");
    if (usuarios.length > 10) verBotonAbajo = true;
    _actualizar();
  }

  SeleccionUsuario() async {

    if(Sesion.metodoLogin == "free")
    {
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => MyHomePage()));
    }
    else
      {
        await Navigator.push(
            context, MaterialPageRoute(builder: (context) => PasswordLogin()));
      }


    inicializar();
  }

  // Widget para cargar las imagenes que van en los creditos
  Widget ImagenUGR() {
    return Container(
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      if (imagenUgr != null) ...[
        Image.network(
          imagenUgr,
          width: 100,
          height: 100,
          fit: BoxFit.fill,
        ),
      ],
      Image.asset("assets/mochileros.png", width: 100, height: 100)
    ]));
  }

  // Devuelve la lista de usuarios
  Widget ListaUsuarios() {
    if (usuarios == null)
      return Column(children: [
        ImagenUGR(),
        Text('Créditos: Los mochileros'),
        Text(
            'Rafael Guzmán , Blanca Abril , Javier Mesa , José Paneque , Hicham Bouchemma , Emilio Vargas'),
      ]);
    else {
      return OrientationBuilder(
        builder: (context, orientation) => orientation == Orientation.portrait
            ? buildPortrait()
            : buildLandscape(),
      );
    }
  }

  buildLandscape() {
    maxUsuariosPorFila = 5;
    return SingleChildScrollView(
        controller: homeController, child: buildLista());
  }

  buildPortrait() {
    maxUsuariosPorFila = 2;
    return SingleChildScrollView(
        controller: homeController, child: buildLista());
  }

  // Construye la lista de usuarios
  buildLista() {
    return Column(children: [
      for (int i = 0; i < usuarios.length / maxUsuariosPorFila; i++)
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (int j = i * maxUsuariosPorFila;
              j < (i * maxUsuariosPorFila) + maxUsuariosPorFila &&
                  j < usuarios.length;
              j++)
            Container(
                alignment: Alignment.center,
                margin: EdgeInsets.all(20),
                child: ElevatedButton(
                  child: Container(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Column(
                        children: [
                          Text(
                            usuarios[j].nombre,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          Image.network(
                            usuarios[j].foto,
                            width: 70,
                            height: 70,
                            fit: BoxFit.fill,
                          ),
                        ],
                      )),
                  onPressed: () {
                    Sesion.id = usuarios[j].id;
                    Sesion.nombre = usuarios[j].nombre;
                    Sesion.rol = usuarios[j].rol;
                    if(usuarios[j].metodoLogeo == Passportmethod.free.toString())
                      {
                        Sesion.metodoLogin = "free";
                      }
                    else
                      {
                        Sesion.metodoLogin =
                        usuarios[j].metodoLogeo == Passportmethod.pin.toString()
                            ? Passportmethod.pin.toString()
                            : Passportmethod.text.toString();
                      }
                    SeleccionUsuario();
                  },
                ))
        ]),
    ]);
  }

  // Metodo para leer la imagen
  lecturaImagen(path) async {
    return await base.leerImagen(path);
  }

  // Metodo para actualizar la pagina
  void _actualizar() async {
    //maxUsuariosPorFila = MediaQuery.of(this.context).orientation == Orientation.portrait? 2 : 4;
    setState(() {});
  }
}
*/