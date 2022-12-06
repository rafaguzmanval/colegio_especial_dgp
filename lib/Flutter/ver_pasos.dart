

import 'package:flutter/material.dart';

import '../Dart/sesion.dart';

class VerPasos extends StatefulWidget {
  @override
  VerPasosState createState() => VerPasosState();
}

// Clase que construye la pagina
class VerPasosState extends State<VerPasos> {

  var tarea;
  @override
  void initState() {
    // TODO: implement initState
    tarea = Sesion.argumentos[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(title:Text("Pasos")),
      body: Column(children: [
        for(int i = 0; i < tarea.textos.length;i++)
          Container(child:Column(children:[
            Row(children: [
              Text("Paso " + (i+1).toString()),
              Text(tarea.textos[i]),
              Image.network(tarea.imagenes[i]),
            ],)

          ]))
      ],)
      ,

    );
  }


}