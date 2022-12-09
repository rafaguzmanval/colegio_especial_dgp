import 'package:flutter/material.dart';

import '../Dart/sesion.dart';
import '../Dart/guardado_local.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';

class VerPasos extends StatefulWidget {
  @override
  VerPasosState createState() => VerPasosState();
}

// Clase que construye la pagina
class VerPasosState extends State<VerPasos> {
  var tarea;
  double offSetActual = 0;
  ScrollController homeController = new ScrollController();

  @override
  void initState() {
    tarea = Sesion.argumentos[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Center(
              child: Text(
        "PASOS",
        style: TextStyle(fontWeight: FontWeight.bold,
            fontSize: 25,
            color: GuardadoLocal.colores[2],
            ),
        textAlign: TextAlign.center,
      ))),
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
                offSetActual -= 200.0;
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
                offSetActual += 200;

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

  Widget VistaAlumno() {
    return _listaPasos();
  }

  ///Este método devuelve toda la vista que va a ver el administrador en un Widget.
  Widget VistaAdministrador() {
    return _listaPasos();
  }

  buildLandscape() {
    return SingleChildScrollView(
      controller: homeController,
      child: Pasos(),
    );
  }

  buildPortrait() {
    return SingleChildScrollView(
      controller: homeController,
      child: Pasos(),
    );
  }

  // dependiendo del rol, adapta la vida
  Pasos() {
    if (Sesion.rol == Rol.alumno.toString())
      return VistaAlumno();
    else if(Sesion.rol == Rol.administrador.toString())
      return VistaAdministrador();
  }

  Widget _listaPasos() {
    return SingleChildScrollView(
        child: Column(
          children: [
            for (int i = 0; i < tarea.textos.length; i++) ...[
              SizedBox(
                height: 10,
              ),
              Container(
                  child: Column(children: [
                    Container(
                        decoration: BoxDecoration(border: Border.all(width: 1)),
                        padding: EdgeInsets.all(5),
                        child: Text("PASO " + (i + 1).toString().toUpperCase() + ": ",
                            style: TextStyle(
                                fontSize: 40,
                                color: GuardadoLocal.colores[0],
                              fontWeight: FontWeight.bold,))),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                        decoration: BoxDecoration(border: Border.all(width: 1)),
                        margin: EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                                flex: 1,
                                child: Container(
                                  margin: EdgeInsets.only(left: 10),
                                  child: Text(tarea.textos[i].toUpperCase(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 30,
                                          color: GuardadoLocal.colores[0])),
                                )),
                            Flexible(
                                flex: 1,
                                child: Container(
                                    margin: EdgeInsets.only(right: 10),
                                    child: Image.network(tarea.imagenes[i]))),
                          ],
                        ))
                  ]))
            ]
          ],
        ));
  }
}


