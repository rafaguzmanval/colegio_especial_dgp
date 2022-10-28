
import 'dart:ui';

import 'package:colegio_especial_dgp/Dart/main.dart';
import 'package:colegio_especial_dgp/Flutter/password_login.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../Dart/notificacion.dart';
import '../Dart/sesion.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';


class LoginPage extends StatefulWidget{

  @override
  LoginPageState createState() => LoginPageState();

}

class LoginPageState extends State<LoginPage>{

  AccesoBD base = new AccesoBD();
  var usuarios;
  var imagenUgr;
  var maxUsuariosPorFila = 2;

  FlutterLocalNotificationsPlugin notificaciones = new FlutterLocalNotificationsPlugin();


  @override
  void initState() {

    super.initState();
    obtenerAutenticacion();
    inicializar();
    Notificacion.initialize(flutterLocalNotificationsPlugin);
    Notificacion.showBigTextNotification(title: "Bienvenio", body: "LA gran notificacion", fln: flutterLocalNotificationsPlugin);
    Sesion.reload();
    Sesion.paginaActual = this;

  }

  obtenerAutenticacion() async{

    try {
      Sesion.credenciales =
      await FirebaseAuth.instance.signInAnonymously();
      print("Signed in with temporary account.");
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          print("Anonymous auth hasn't been enabled for this project.");
          break;
        default:
          print("Unknown error.");
      }
    }


  }

  @override
  Widget build(BuildContext context){


    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar:AppBar(

          title:  Text('TuCole')
      ),
      body:   ListaUsuarios()

      /*
      Container(


        alignment: Alignment.center,

        child: Column(

          children: [

            Text("Iniciar Sesión"),

            ImagenUGR(),

            Text('Créditos: Los mochileros'),
            Text('Rafael Guzmán , Blanca Abril , Javier Mesa , José Paneque , Hicham Bouchemma , Emilio Vargas'),


          ],
        ),



      )  */
    );

  }

  inicializar() async{

    usuarios = await base.consultarTodosUsuarios();
    imagenUgr = await lecturaImagen("AppStorage/ugr.png");
    _actualizar();
  }



  SeleccionUsuario() async
  {
    await Navigator.push(context,
        MaterialPageRoute(builder: (context) => PasswordLogin()));

    inicializar();
  }

  Widget ImagenUGR()
  {
    return Container(

        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              if(imagenUgr != null)...[

                Image.network(imagenUgr,width:100,
                  height: 100,
                  fit: BoxFit.fill,),
              ],
              Image.asset("assets/mochileros.png" ,
                  width:100 ,
                  height:100)


            ]
        )
    );
  }

  Widget ListaUsuarios()
  {
    if(usuarios == null)
      return Column(
        children: [
        ImagenUGR(),
        Text('Créditos: Los mochileros'),
        Text('Rafael Guzmán , Blanca Abril , Javier Mesa , José Paneque , Hicham Bouchemma , Emilio Vargas'),]
      );
    else {
      return
          OrientationBuilder(builder: (context,orientation)=>
            orientation == Orientation.portrait
                  ? buildPortrait()
                : buildLandscape(),

          );
   }
  }

  buildLandscape()
  {
    maxUsuariosPorFila = 5;
    return
      SingleChildScrollView(
        child: buildLista()
      );
  }


  buildPortrait()
  {
    maxUsuariosPorFila = 2;
    return
      SingleChildScrollView(
          child: buildLista()
      );

  }

  buildLista(){
    return
      Column(
          children: [

            for(int i = 0; i < usuarios.length/maxUsuariosPorFila; i++)
              Container(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        for(int j = i*maxUsuariosPorFila; j < (i*maxUsuariosPorFila) + maxUsuariosPorFila && j < usuarios.length; j++)
                          Container(
                              width:100,
                              height: 100,
                              margin: EdgeInsets.all(20),
                              alignment: Alignment.center,
                              child: ElevatedButton(
                                child: Column(
                                  children: [
                                    Text(usuarios[j].nombre,
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),

                                    Image.network(usuarios[j].foto,width:100,
                                      height: 70,
                                      fit: BoxFit.fill,),
                                  ],

                                ),
                                onPressed: () {
                                  Sesion.id = usuarios[j].id;
                                  Sesion.nombre = usuarios[j].nombre;
                                  Sesion.rol = usuarios[j].rol;
                                  SeleccionUsuario();
                                },


                              )

                          )]
                  )


              ),
          ]
      );
  }



  lecturaImagen(path) async
  {
    return await base.leerImagen(path);
  }



  void _actualizar() async
  {
    //maxUsuariosPorFila = MediaQuery.of(this.context).orientation == Orientation.portrait? 2 : 4;
    setState(() {

    });
  }

}