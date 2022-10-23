import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/discapacidad.dart';
import 'package:colegio_especial_dgp/Flutter/loginpage.dart';
import 'package:colegio_especial_dgp/Flutter/myhomepage.dart';
import 'package:colegio_especial_dgp/Flutter/perfil_alumno.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/clase.dart';
import 'package:colegio_especial_dgp/Dart/usuario.dart';

import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';

import "package:image_picker/image_picker.dart";

import "package:flutter_tts/flutter_tts.dart";

enum SeleccionImagen{
  camara,
  galeria
}


class RegistroUsuarios extends StatefulWidget{

  @override
  RegistroUsuariosState createState() => RegistroUsuariosState();

}

class RegistroUsuariosState extends State<RegistroUsuarios>{

  var db = FirebaseFirestore.instance;

  AccesoBD base = new AccesoBD();


  var fotoTomada;
  ImagePicker capturador = new ImagePicker();

  var registrando = false;
  var mensajeDeRegistro = "";



  final controladorNombre = TextEditingController();
  final controladorApellidos = TextEditingController();
  final controladorPassword = TextEditingController();
  final controladorFechanacimiento = TextEditingController();
  final controladorRol = TextEditingController();


  ///Cuándo se pasa de página es necesario que todos los controladores de los formularios y de los reproductores de vídeo se destruyan.
  @override
  void dispose(){

    super.dispose();
  }



  @override
  void initState(){
    super.initState();

    Sesion.paginaActual = this;

  }

  ///introduce en el atributo @fototomada la imagen, @seleccion nos indica si el método va a ser desde la cámara o de galería
  seleccionarImagen(seleccion) async{

    try {
      if(seleccion == SeleccionImagen.camara)
        {
      print("Se va a abrir la cámara de fotos");
        fotoTomada =  await capturador.pickImage(
            source: ImageSource.camera,
            imageQuality: 15,

        );}
    else
      {
        print("Se coger una foto de la galería");
        fotoTomada =  await capturador.pickImage(
            source: ImageSource.gallery,
            imageQuality: 15);
      }

    }
    catch(e){
      print(e);
    }
    actualizar();
  }


  /// Este es el build de la clase MyHomePage que devuelve toda la vista génerica más la vista especial de cada usuario.
  @override
  Widget build(BuildContext context){
    
    return

      new Scaffold(

        appBar:AppBar(

          title: Text('Registra un nuevo usuario'),
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
              ],
            )




        ),
      );


  }

  ///Este método devuelve toda la vista que va a ver el profesor en un Widget.
  Widget VistaProfesor()
  {
    Navigator.pop(context);
    return
      Container(
      );
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
    return
      Container(
        //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
        child:Column(
          children:[

            Text("Eres un administrador"),

            Text("\nRegistra un nuevo usuario:"),

            TextField(
              obscureText: false,
              decoration: InputDecoration(
                border:OutlineInputBorder(),
                hintText: 'Introduce nombre',
              ),
              controller: controladorNombre,
            ),

            TextField(
              obscureText: false,
              decoration: InputDecoration(
                border:OutlineInputBorder(),
                hintText: 'Introduce apellidos',
              ),
              controller: controladorApellidos,
            ),

            TextField(
              obscureText: false,
              decoration: InputDecoration(
                border:OutlineInputBorder(),
                hintText: 'Introduce contraseña',
              ),
              controller: controladorPassword,
            ),

            TextField(
              obscureText: false,
              decoration: InputDecoration(
                border:OutlineInputBorder(),
                hintText: 'Introduce fecha de nacimiento',
              ),
              controller: controladorFechanacimiento,
            ),

            /*
            TextField(
              obscureText: false,
              decoration: InputDecoration(
                border:OutlineInputBorder(),
                hintText: 'Introduce rol',
              ),
              controller: controladorRol,
            ),*/

            ElevatedButton(
                child: Text('Haz una foto para la imagen de perfil'),
                onPressed: (){seleccionarImagen(SeleccionImagen.camara);}
            ),
            ElevatedButton(
                child: Text('Elige una foto de la galería'),
                onPressed: (){seleccionarImagen(SeleccionImagen.galeria);}
            ),

            SizedBox(
              height: 100,
              width: 100,
                child: fotoTomada == null
                  ? Center(child: Text('Ninguna foto tomada'))
                  : Center(child: Image.file(File(fotoTomada.path))),
            ),

            Text(mensajeDeRegistro),

            Visibility(
                visible: !registrando,
                child:
            TextButton(
              child: Text("Registrar",
                style: TextStyle(
                    color: Colors.cyan,
                    decorationColor: Colors.lightBlueAccent
                ),
              ),
              onPressed: () {
                registrarUsuario();
              },

            )
            ),


            Visibility(
                visible: registrando,
                child: new CircularProgressIndicator()

            ),

          ],
        ),
      );
  }

  //Método para registrar usuario
  registrarUsuario()
  {

    // FALTARIA HACER COMPROBACIÓN DE QUE EL NOMBRE Y APELLIDOS YA ESTÁN REGISTRADOS EN LA BASE DE DATOS

    if(controladorNombre.text.isNotEmpty && controladorApellidos.text.isNotEmpty && controladorPassword.text.isNotEmpty
        && controladorFechanacimiento.text.isNotEmpty && fotoTomada != null)
    {
      registrando = true;
      actualizar();

      var nombre = "" + controladorNombre.text;
      var apellidos = "" + controladorApellidos.text;
      var password = "" + controladorPassword.text;
      var fechanacimiento = "" + controladorFechanacimiento.text;
      var rol = "Rol.alumno" + controladorRol.text;

      Usuario usuario = Usuario();
      usuario.setUsuario(
          nombre, apellidos, password, fechanacimiento, rol, "");


      var future = base.registrarUsuario(usuario, File(fotoTomada.path));

      future.then((value) {
        registrando = false;

        if (value) {
          controladorNombre.text = "";
          controladorApellidos.text = "";
          controladorPassword.text = "";
          controladorFechanacimiento.text = "";
          fotoTomada = null;

          mensajeDeRegistro =
          "Registro completado correctamente\nPuedes volver a registrar otro usuario:";
        }
        else {
          mensajeDeRegistro = "Fallo al registrar, inténtelo de nuevo";
        }

        actualizar();
      });
    }
    else
      {
        mensajeDeRegistro = "Es necesario rellenar todos los campos";
        actualizar();
      }
  }

 void actualizar() async
  {
    setState((){});
  }

}







