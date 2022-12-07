import 'package:flutter/material.dart';

import '../Dart/sesion.dart';
import '../Dart/guardado_local.dart';

class VerPasos extends StatefulWidget {
  @override
  VerPasosState createState() => VerPasosState();
}

// Clase que construye la pagina
class VerPasosState extends State<VerPasos> {
  var tarea;
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
        style: TextStyle(
            fontSize: 25,
            color: GuardadoLocal.colores[2],
            fontWeight: FontWeight.w800),
        textAlign: TextAlign.center,
      ))),
      body: SingleChildScrollView(
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
                          fontWeight: FontWeight.w800))),
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
      )),
    );
  }
}
