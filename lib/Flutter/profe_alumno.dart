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
import '../Dart/background.dart';
import '../Dart/guardado_local.dart';
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

  @override
  void initState() {
    super.initState();
    obtenerAutenticacion();
    Sesion.db = new AccesoBD();

    Sesion.argumentos.clear();
    //Notificacion.showBigTextNotification(title: "Bienvenio", body: "LA gran notificacion", fln: flutterLocalNotificationsPlugin);
  }

// Contructor de la estructura de la pagina
  @override
  Widget build(BuildContext context) {
    double media = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          title: Center(child: Text(
        'TuCole',textAlign: TextAlign.center,
        style: TextStyle(fontSize:30,color: GuardadoLocal.colores[2],fontWeight: FontWeight.normal),
      ))),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              flex: 1,
              fit: FlexFit.tight,

              child:
              media > 600 ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    //margin: EdgeInsets.all(10),
                    child: Container(
                      margin: EdgeInsets.only(
                          bottom: 40, top: 40, right: 30, left: 30),
                      child: ElevatedButton(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Alumnos".toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30,
                                color: GuardadoLocal.colores[2],
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
                          Sesion.argumentos.add("alumnos");

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Container(
                      margin: EdgeInsets.only(
                          bottom: 40, top: 40, right: 30, left: 30),
                      child: ElevatedButton(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Profesores".toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30,
                                color: GuardadoLocal.colores[2],
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
                          Sesion.argumentos.add("profesores");

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ):Container(
                alignment: Alignment.center,

              child:
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    //margin: EdgeInsets.all(10),
                    child: Container(
                      margin: EdgeInsets.only(
                          bottom: 40, top: 40, right: 30, left: 30),
                      child: ElevatedButton(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Alumnos".toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30,
                                color: GuardadoLocal.colores[2],
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
                          Sesion.argumentos.add("alumnos");

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: Container(
                      margin: EdgeInsets.only(
                          bottom: 40, top: 40, right: 30, left: 30),
                      child: ElevatedButton(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Profesores".toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 30,
                                color: GuardadoLocal.colores[2],
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
                          Sesion.argumentos.add("profesores");

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginPage()),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              )



            )
          ]),
    );
  }
}

