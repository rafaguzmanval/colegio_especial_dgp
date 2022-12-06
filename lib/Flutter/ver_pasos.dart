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
      appBar: AppBar(title: Text("PASOS",style: TextStyle(fontSize:25, color: GuardadoLocal.colores[2],fontWeight: FontWeight.w800), textAlign: TextAlign.center,)),
      body: SingleChildScrollView(
          child: Column(
        children: [
          for (int i = 0; i < tarea.textos.length; i++)...[
            SizedBox(height: 10,),
            Container(
                child: Column(children: [
              Container(
                  decoration: BoxDecoration(border: Border.all(width: 1)),
                  padding: EdgeInsets.all(5),
                  child:Text("PASO " + (i + 1).toString().toUpperCase(),style: TextStyle(fontSize:25, color: GuardadoLocal.colores[0],fontWeight: FontWeight.w800))),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(tarea.textos[i].toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold,fontSize:25, color: GuardadoLocal.colores[0])),
                  Image.network(tarea.imagenes[i]),
                ],
              )
            ]))
        ]],
      )),
    );
  }
}
