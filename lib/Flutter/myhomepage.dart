import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/discapacidad.dart';
import 'package:colegio_especial_dgp/Flutter/crear_tarea.dart';
import 'package:colegio_especial_dgp/Flutter/loginpage.dart';
import 'package:colegio_especial_dgp/Flutter/perfil_alumno.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/clase.dart';
import 'package:colegio_especial_dgp/Dart/usuario.dart';

import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:colegio_especial_dgp/Flutter/registro_usuarios.dart';
import 'package:colegio_especial_dgp/Flutter/tablon_comunicacion.dart';
import 'package:colegio_especial_dgp/Flutter/ver_tareas.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:video_player/video_player.dart';

import "package:image_picker/image_picker.dart";

import "package:flutter_tts/flutter_tts.dart";

import 'lista_alumnos.dart';
import 'lista_profesores.dart';

enum SeleccionImagen{
  camara,
  galeria
}


class MyHomePage extends StatefulWidget{

  @override
  MyHomePageState createState() => MyHomePageState();

}

class MyHomePageState extends State<MyHomePage>{

  var db = FirebaseFirestore.instance;
  double offSetActual = 0;
  AccesoBD base = new AccesoBD();



  ///Cuándo se pasa de página es necesario que todos los controladores de los formularios y de los reproductores de vídeo se destruyan.
  @override
  void dispose(){

    super.dispose();
  }



  @override
  void initState(){
    super.initState();

    Sesion.paginaActual = this;

    Sesion.seleccion = "";
    Sesion.tareas = [];


  }


  /// Este es el build de la clase MyHomePage que devuelve toda la vista génerica más la vista especial de cada usuario.
  @override
  Widget build(BuildContext context){
    
    return
      new WillPopScope(child: new Scaffold(
        appBar:AppBar(
          leading: IconButton(icon: Icon(Icons.settings_power, color: Colors.white),onPressed: () => _onBackPressed(context)),

          title: Column(
            children: [Text('Menú principal'),
          ]
          ),
          automaticallyImplyLeading: false,
        ),
        body: Container(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal:  0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
      ),
          onWillPop: () async {
          final pop = await _onBackPressed(context);
          return pop ?? false;
             },
          );


  }

  ///Este método devuelve toda la vista que va a ver el profesor en un Widget.
  Widget VistaProfesor()
  {
    return
      Container(
        alignment: Alignment.center,
        child:
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                child: Column(
                  children: [
                    Text("Lista de alumnos",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),

                    Image.network("https://firebasestorage.googleapis.com/v0/b/colegioespecialdgp.appspot.com/o/Im%C3%A1genes%2Fpictogramas%2Fhola.png?alt=media&token=8985d5de-d0a5-4c53-a427-32f9241917d3",width:100,
                      height: 55,
                      fit: BoxFit.fill,),
                  ],

                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ListaAlumnos()));
                },
              ),
            ]
        ),
      );

  }

  ///Este método devuelve toda la vista que va a ver el alumno en un Widget.
  Widget VistaAlumno()
  {
    return
      Container(
        alignment: Alignment.center,
        child:
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                child: Column(
                  children: [
                    Text("Tablon de Comunicacion",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),

                    Image.network("https://firebasestorage.googleapis.com/v0/b/colegioespecialdgp.appspot.com/o/Im%C3%A1genes%2Fpictogramas%2Fhola.png?alt=media&token=8985d5de-d0a5-4c53-a427-32f9241917d3",width:100,
                      height: 55,
                      fit: BoxFit.fill,),
                  ],

                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => TablonComunicacion()));
                },
              ),

              ElevatedButton(
                child: Column(children: [
                  Text("Lista de Tareas",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),

                  Image.network("https://firebasestorage.googleapis.com/v0/b/colegioespecialdgp.appspot.com/o/Im%C3%A1genes%2Fpictogramas%2Fhola.png?alt=media&token=8985d5de-d0a5-4c53-a427-32f9241917d3",width:100,
                    height: 55,
                    fit: BoxFit.fill,),
                ],

                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => VerTareas()));
                },
              ),
            ]
        ),
      );
  }


  ///Este método devuelve toda la vista que va a ver el administrador en un Widget.
  Widget VistaAdministrador()
  {
    return
      Container(
        alignment: Alignment.center,
        child:
          Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              child: Column(
                children: [
                  Text("Lista de alumnos",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),

                  Image.network("https://firebasestorage.googleapis.com/v0/b/colegioespecialdgp.appspot.com/o/Im%C3%A1genes%2Fpictogramas%2Fhola.png?alt=media&token=8985d5de-d0a5-4c53-a427-32f9241917d3",width:100,
                    height: 55,
                    fit: BoxFit.fill,),
                ],

              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ListaAlumnos()));
              },
            ),

            ElevatedButton(
              child: Column(children: [
                Text("Lista de Profesores",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),

                Image.network("https://firebasestorage.googleapis.com/v0/b/colegioespecialdgp.appspot.com/o/Im%C3%A1genes%2Fpictogramas%2Fhola.png?alt=media&token=8985d5de-d0a5-4c53-a427-32f9241917d3",width:100,
                  height: 55,
                  fit: BoxFit.fill,),
              ],

              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ListaProfesores()));
              },
            ),

            ElevatedButton(
              child: Column(
                children: [
                  Text("Registro de Usuario",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),

                  Image.network("https://firebasestorage.googleapis.com/v0/b/colegioespecialdgp.appspot.com/o/Im%C3%A1genes%2Fpictogramas%2Fhola.png?alt=media&token=8985d5de-d0a5-4c53-a427-32f9241917d3",width:100,
                    height: 55,
                    fit: BoxFit.fill,),
                ],

              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => RegistroUsuarios()));
              },
            ),

            ElevatedButton(
              child: Column(
                children: [
                  Text("Crear Tarea",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),

                  Image.network("https://firebasestorage.googleapis.com/v0/b/colegioespecialdgp.appspot.com/o/Im%C3%A1genes%2Fpictogramas%2Fhola.png?alt=media&token=8985d5de-d0a5-4c53-a427-32f9241917d3",width:100,
                    height: 55,
                    fit: BoxFit.fill,),
                ],

              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CrearTarea()));
              },
            ),
          ]
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


          ],
        ),
      );
  }




  //Método para cambiar la funcionalidad del botón de volver atrás

Future<bool?> _onBackPressed(BuildContext context){

    return showDialog(
        context: context,
        builder : (context) {

          return AlertDialog(
            title: const Text('¿Seguro?'),
            content: Text('¿Quieres cerrar sesión?'),

            actions: [
              ElevatedButton(onPressed: (){
                Navigator.pop(context,false);

              }, child: Text('No')),
              ElevatedButton(onPressed: (){
                Navigator.popUntil(context, (route) => route.isFirst);

              }, child: Text('Sí')),

            ],

          );
        }
       );
  }

 void actualizar() async
  {
    setState((){});
  }


}








