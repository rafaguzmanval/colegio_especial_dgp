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
  int pasoActual = 0;
  bool verFlechaIzquierda = false;
  bool verFlechaDerecha = true;
  var tarea;
  double offSetActual = 0;
  ScrollController homeController = new ScrollController();

  @override
  void initState() {
    tarea = Sesion.argumentos[0];
    super.initState();
    if(tarea.textos.length>0) verFlechaDerecha = true;
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
          builder: (context, orientation) =>
          orientation == Orientation.portrait
              ? buildPortrait()
              : buildLandscape(),
        ),

        ///FLECHA IZQUIERDA
        Align(
          alignment: FractionalOffset(0.01, 0.5),
          child: Visibility(
            child: FloatingActionButton(
                elevation: 1.0,
                heroTag: "flechaIzquierda",
                onPressed: () {
                  desplazarIzquierda();
                  actualizar();
                },
                child: Icon(
                  Icons.arrow_left,
                  color: GuardadoLocal.colores[2],
                )),
            visible: verFlechaIzquierda,
          ),
        ),

        ///FLECHA DERECHA
        Align(
          alignment: FractionalOffset(0.99, 0.5),
          child: Visibility(
            child: FloatingActionButton(
                elevation: 1.0,
                heroTag: "flechaDerecha",
                onPressed: () {
                  desplazarDerecha();
                  actualizar();
                },
                child: Icon(
                  Icons.arrow_right,
                  color: GuardadoLocal.colores[2],
                )),
            visible: verFlechaDerecha,
          ),
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
    else if (Sesion.rol == Rol.administrador.toString())
      return VistaAdministrador();
  }

  Widget _listaPasos() {
    return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Container(
                  height: MediaQuery.of(context).size.height-75,
                  margin: EdgeInsets.only(right: 100, left: 100,top: 10,bottom: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: Border.all(
                          width: 2, color: GuardadoLocal.colores[2]),
                      color: GuardadoLocal.colores[0]),
                  child: Column(children: [
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              decoration: BoxDecoration(border: Border.all(width: 1,color: GuardadoLocal.colores[2]), color: GuardadoLocal.colores[0]),
                              padding: EdgeInsets.all(5),
                              child: Text(
                                "PASO " + (pasoActual).toString().toUpperCase() + ": ",
                                style: TextStyle(
                                fontSize: 40,
                                color: GuardadoLocal.colores[2],
                                fontWeight: FontWeight.bold,))),
                            SizedBox(
                              height: 20,
                            ),
                            Expanded(child: Container(
                                decoration: BoxDecoration(border: Border.all(width: 1,color: GuardadoLocal.colores[2])),
                                margin: EdgeInsets.all(20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                        flex: 1,
                                        child: Container(
                                          margin: EdgeInsets.only(left: 10),
                                          child: Text(tarea.textos[pasoActual].toUpperCase(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 30,
                                                  color: GuardadoLocal.colores[2])),
                                        )),
                                    Expanded(
                                        flex: 1,
                                        child: Container(
                                            margin: EdgeInsets.only(right: 10),
                                            child: Image.network(tarea.imagenes[pasoActual]))),
                                  ],
                                )))
                  ]))
          ],
        ));
  }

  actualizar() {
    if (Sesion.tareas.length > 1 && pasoActual == 0) {
      verFlechaDerecha = true;
    } else if (Sesion.tareas.length > 2 &&
        pasoActual > 0 &&
        pasoActual < Sesion.tareas.length - 1) {
      verFlechaIzquierda = true;
      verFlechaDerecha = true;
    } else if (Sesion.tareas.length > 1 &&
        pasoActual == Sesion.tareas.length - 1) {
      verFlechaIzquierda = true;
    }

    setState(() {});
  }

  desplazarDerecha() {
    if (pasoActual < tarea.textos.length - 1) {
      pasoActual++;
      verFlechaIzquierda = true;

      verFlechaDerecha = (pasoActual != tarea.textos.length - 1);
    }
  }

  desplazarIzquierda() {
    if (pasoActual > 0) {
      pasoActual--;

      verFlechaDerecha = true;

      verFlechaIzquierda = pasoActual != 0;
    }
  }
}


