import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/discapacidad.dart';
import 'package:colegio_especial_dgp/Flutter/loginpage.dart';
import 'package:colegio_especial_dgp/Flutter/myhomepage.dart';
import 'package:colegio_especial_dgp/Flutter/perfil_alumno.dart';
import 'package:colegio_especial_dgp/Flutter/perfil_profesor.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/clase.dart';
import 'package:colegio_especial_dgp/Dart/usuario.dart';

import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';

import "package:image_picker/image_picker.dart";

import "package:flutter_tts/flutter_tts.dart";



class ListaProfesores extends StatefulWidget{

  @override
  ListaProfesoresState createState() => ListaProfesoresState();

}

class ListaProfesoresState extends State<ListaProfesores>{


  var profesores = [];

  var db = FirebaseFirestore.instance;

  AccesoBD base = new AccesoBD();


  @override
  void initState(){
    super.initState();

    Sesion.paginaActual = this;

    Sesion.seleccion = "";
    Sesion.tareas = [];
    Sesion.controladoresVideo = [];

    if(Sesion.rol != Rol.alumno.toString())
    {
      cargarProfesores();
    }

  }



  /// Este es el build de la clase MyHomePage que devuelve toda la vista génerica más la vista especial de cada usuario.
  @override
  Widget build(BuildContext context){

    return

      new Scaffold(

        appBar:AppBar(

          title: Text('Lista de Profesores'),
        ),
        body: Container(

            padding: EdgeInsets.symmetric(vertical: 0, horizontal:  0),
            child: Column(
              children: [


                if(Sesion.rol == Rol.alumno.toString())...[
                  VistaAlumno(),
                ]
                else if(Sesion.rol == Rol.profesor.toString())...[
                  VistaProfesor()
                ]
                else if(Sesion.rol == Rol.administrador.toString())...[
                    VistaAdministrador()
                  ]
                  else if(Sesion.rol == Rol.programador.toString())...[
                      VistaProgramador()
                    ]
              ],
            )




        ),
      );


  }

  ///Este método devuelve toda la vista que va a ver el profesor en un Widget.
  Widget VistaProfesor()
  {
    return _listaProfesores();
  }

  ///Este método devuelve toda la vista que va a ver el alumno en un Widget.
  Widget VistaAlumno()
  {
    Navigator.pop(context);
    return
      Container(
      );
  }


  ///Este método devuelve toda la vista que va a ver el administrador en un Widget.
  Widget VistaAdministrador()
  {
    return _listaProfesores();
  }


  Widget _listaProfesores()
  {
    return
      Container(
        alignment: Alignment.center,
        //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
        child:Column(
          children:[

            Text("Eres un administrador"),

            for(int i = 0; i < profesores.length; i++)
              Container(
                  constraints: BoxConstraints(maxWidth: 80,minWidth: 30, maxHeight: 80),
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.cyan,
                      borderRadius: BorderRadius.circular(20)),
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    child: Column(
                      children: [
                        Text(profesores[i].nombre,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),

                        Image.network(profesores[i].foto,width:100,
                          height: 55,
                          fit: BoxFit.fill,),
                      ],

                    ),
                    onPressed: () {
                      Sesion.seleccion = profesores[i];
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => PerfilProfesor()));
                    },




                  )
              )
          ],
        ),
      );
  }

  /*
  *
  * */

  Widget VistaProgramador()
  {
    return
      Container(
        //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
        child:Column(
          children:[

            Text("Eres un programador")

          ],
        ),
      );
  }

  cargarProfesores() async{
    profesores = await base.consultarTodosProfesores();
    actualizar();
  }


  void actualizar() async
  {
    setState((){});
  }

}








