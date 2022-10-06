
import 'package:colegio_especial_dgp/Dart/discapacidad.dart';
import 'package:colegio_especial_dgp/Dart/main.dart';
import 'package:colegio_especial_dgp/Flutter/myhomepage.dart';
import 'package:colegio_especial_dgp/Flutter/passwordLogin.dart';
import '../Dart/clase.dart';
import '../Dart/usuario.dart';
import '../Dart/Sesion.dart';

import 'package:colegio_especial_dgp/Dart/AccesoBD.dart';
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


  @override
  void initState(){
    super.initState();
    inicializar();
    Sesion.reload();
    Sesion.paginaActual = this;

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






