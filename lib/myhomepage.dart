import 'dart:io';
import 'dart:typed_data';

import 'package:colegio_especial_dgp/AccesoBD.dart';

import 'package:flutter/material.dart';



class MyHomePage extends StatefulWidget{

  @override
  MyHomePageState createState() => MyHomePageState();



}

class MyHomePageState extends State<MyHomePage>{

  var msg = "null";
  var imagen = null;
  AccesoBD base = new AccesoBD();




  @override
  void initState(){
    super.initState();
    lecturaDatos();
    lecturaImagen();


  }

  @override
  Widget build(BuildContext context){



    //base.escribirDatos();

    return Scaffold(
      appBar:AppBar(
        title: const Text('AppEspecial')
      ),
      body: Container(
        child: Column(
          children: [
            if(imagen != null)...[
              Image.memory(imagen)
            ]else...[
              Text("No se ha cargado la imagen")
            ],
            Text(msg),
          ],
        )


      ),
    );
  }

  lecturaImagen()
  {
    var future = base.leerImagen();

    future.then((value){
      imagen = value;
      _actualizar();

    });
  }

  lecturaDatos()
  {
    var future = base.leerDatos();

    future.then((value){
      msg = value;
      _actualizar();

    });
  }



  void _actualizar() async
  {
    //var reloj = 1;
    //await Future.delayed(Duration(seconds:reloj));
    setState(() {

    });
  }

}








