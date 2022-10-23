
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
      appBar:AppBar(
          title:  Text('TuCole')
      ),
      body: Container(
        alignment: Alignment.center,

          child: Column(

            children: [
            Text("Iniciar Sesión"),
              ListaUsuarios(),



              Row(
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

              ),



              Text('Créditos: Los mochileros'),
              Text('Rafael Guzmán , Blanca Abril , Javier Mesa , José Paneque , Hicham Bouchemma , Emilio Vargas'),


            ],
          )


      ),
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


  Widget ListaUsuarios()
  {
    if(usuarios == null)
      return Container();
    else {

      return
        Container(
          //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if(usuarios != null)...[
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

                      )
                      ],
                    )

                     )
                  ]
                ]
            )


        );
    }
  }

  lecturaImagen(path) async
  {
    return await base.leerImagen(path);
  }


  void _actualizar() async
  {
    //var reloj = 1;
    //await Future.delayed(Duration(seconds:reloj));
    setState(() {

    });
  }

}







