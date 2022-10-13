
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/Sesion.dart';
import 'package:colegio_especial_dgp/Dart/discapacidad.dart';
import 'package:colegio_especial_dgp/Flutter/loginpage.dart';
import 'package:colegio_especial_dgp/Flutter/perfilalumno.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/clase.dart';
import 'package:colegio_especial_dgp/Dart/usuario.dart';

import 'package:colegio_especial_dgp/Dart/AccesoBD.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';

import "package:image_picker/image_picker.dart";

enum seleccionImagen{
  camara,
  galeria
}


class MyHomePage extends StatefulWidget{

  @override
  MyHomePageState createState() => MyHomePageState();

}

class MyHomePageState extends State<MyHomePage>{

  late VideoPlayerController controller;

  var msg = "null";
  var imagen = null;
  var video = null;
  var alumnos = [];
  var fotoTomada;
  ImagePicker capturador = new ImagePicker();

  var registrando = false;
  var mensajeDeRegistro = "";

  var indiceTextos = 0;
  var indiceImagenes = 0;
  var indiceVideos = 0;

  var db = FirebaseFirestore.instance;

  AccesoBD base = new AccesoBD();

  final controladorNombre = TextEditingController();
  final controladorApellidos = TextEditingController();
  final controladorPassword = TextEditingController();
  final controladorFechanacimiento = TextEditingController();
  final controladorRol = TextEditingController();


  @override
  void dispose(){
    controladorNombre.dispose();
    controladorApellidos.dispose();
    controladorPassword.dispose();
    controladorFechanacimiento.dispose();
    controladorRol.dispose();
    super.dispose();
  }



  @override
  void initState(){
    super.initState();

    Sesion.paginaActual = this;



    if(Sesion.rol == Rol.profesor.toString())
    {
      cargarAlumnos();
    }

    if(Sesion.rol == Rol.alumno.toString())
    {
      print("Cargando tareas");
      cargarTareas();
    }


  }

  selectFromCamera(seleccion) async{

    try {
      if(seleccion == seleccionImagen.camara)
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


  @override
  Widget build(BuildContext context){


    return

      new WillPopScope(child: new Scaffold(

        appBar:AppBar(

          title: Text('Hola ${Sesion.nombre}'),
          automaticallyImplyLeading: false,
        ),
        body: Container(

            padding: EdgeInsets.symmetric(vertical: 0, horizontal:  0),
            child: Column(
              children: [


                if(Sesion.rol == Rol.alumno.toString())...[
                  VistaAlumno()
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


  Widget VistaProfesor()
  {
    return
      Container(
        alignment: Alignment.center,
        //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
        child:Column(
          children:[

            Text("Eres un profesor"),

            for(int i = 0; i < alumnos.length; i++)
              Container(
                  constraints: BoxConstraints(maxWidth: 70,minWidth: 30),
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.cyan,
                      borderRadius: BorderRadius.circular(20)),
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    child: Text(alumnos[i].nombre,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () {
                      Sesion.seleccion = alumnos[i];
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => perfilAlumno()));
                    },


                  )

              )

          ],
        ),
      );
  }


  Widget VistaAlumno()
  {
    return
      Container(
        //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
        alignment: Alignment.center,
          child:Column(
              children:[
                        Text("Eres un alumno"),


                        if(Sesion.misTareas != null)...[
                        for(int i = 0; i < Sesion.misTareas.length; i++)
                          Container(
                              constraints: BoxConstraints(maxWidth: 200,minWidth: 200),
                              width: 50,
                              margin: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Colors.cyan,
                                  borderRadius: BorderRadius.circular(20)),
                              alignment: Alignment.center,
                                child: Column(children: [



                                      Text(Sesion.misTareas[i].nombre,
                                        style: TextStyle(
                                          color: Colors.white,

                                       ),
                                      ),

                                      for(int j = 0; j < Sesion.misTareas[i].orden.length; j++)
                                        
                                        if(Sesion.misTareas[i].orden[j] == "T")...[
                                          Text(Sesion.misTareas[i].textos[indiceTextos]
                                              ,style: TextStyle(
                                                color: Colors.white,
                                              )
                                          ),
                                          
                                        ]
                                        else if(Sesion.misTareas[i].orden[j] == "I")...[
                                          
                                          Image.network(Sesion.misTareas[i].imagenes[indiceImagenes])
                                          
                                          ]
                                        else if(Sesion.misTareas[i].orden[j] == "V")...[

                                          ]
                                  
                                ]

                              ),
                          )
                          ],

                          /*
                          FloatingActionButton(
                              onPressed: (){actualizar();} ,
                              child: const Icon(Icons.refresh),

                          )*/



                    ],
                  ),
      );
  }


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
                onPressed: (){selectFromCamera(seleccionImagen.camara);}
            ),
            ElevatedButton(
                child: Text('Elige una foto de la galería'),
                onPressed: (){selectFromCamera(seleccionImagen.galeria);}
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


  Widget ReproductorVideo()
  {
    return
    Container(
      //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
      child:Column(
        children:[
          
          AspectRatio(
            aspectRatio: controller.value.aspectRatio ,
            child: VideoPlayer(controller)
          ),

          Container( //duration of video
            child: Text("Total Duration: " + controller.value.duration.toString()),
          ),

          Container(
              child: VideoProgressIndicator(
                  controller,
                  allowScrubbing: true,
                  colors:VideoProgressColors(
                    backgroundColor: Colors.black,
                    playedColor: Colors.red,
                    bufferedColor: Colors.grey,
                  )
              )
          ),

          Container(
            child: Row(
              children: [
                IconButton(
                    onPressed: (){
                      if(controller.value.isPlaying){
                        controller.pause();
                      }else{
                        controller.play();
                      }

                      setState(() {

                      });
                    },
                    icon:Icon(controller.value.isPlaying?Icons.pause:Icons.play_arrow)
                ),

              ],
            ),
          )
        ]
      )

    );
  }

  cargarAlumnos() async{
    alumnos = await base.consultarTodosAlumnos();
    actualizar();
  }

  cargarTareas() async {
    await base.consultarTareasAsignadasAlumno(Sesion.id);
  }

  lecturaImagen(path)
  {
    var future = base.leerImagen(path);

    future.then((value){
      imagen = value;
      actualizar();

    });
  }

  lecturaVideo(path){

    var future = base.leerVideo(path);

    future.then((value){
      video = value;
      controller = VideoPlayerController.network(video);
      controller.initialize().then((value){
        setState(() {});
      });
      actualizar();
    });
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

  void resetIndicesTarea(){
    indiceImagenes = 0;
    indiceTextos = 0;
    indiceVideos = 0;
  }
  
  void incIndiceImagenes(){
    indiceImagenes++;
  }


  void incIndiceTextos(){
    indiceTextos++;
  }

  void incIndiceVideos(){
    indiceVideos++;
  }

 void actualizar() async
  {
    setState((){});
  }


}








