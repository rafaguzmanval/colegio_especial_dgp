
import 'package:colegio_especial_dgp/discapacidad.dart';
import 'package:colegio_especial_dgp/main.dart';
import 'package:colegio_especial_dgp/myhomepage.dart';
import 'package:colegio_especial_dgp/passwordLogin.dart';
import 'clase.dart';
import 'usuario.dart';
import 'Sesion.dart';

import 'package:colegio_especial_dgp/AccesoBD.dart';
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
  var imagenes;
  var imagenUgr;


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



              if(imagenUgr != null)...[
                Image(
                  image: NetworkImage(imagenUgr),
                  width: 100,
                  height: 100,
                )
              ],

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
      Navigator.push(context,
      MaterialPageRoute(builder: (context) => PasswordLogin()));
  }


  Widget ListaUsuarios()
  {
    if(usuarios == null)
      return Container();
    else {
      if(imagenes == null)
      cargarImagenesUsuario();
      return
        Container(
          //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
            child: Column(
                children: [
                  if(usuarios != null)...[
                    for(int i = 0; i < usuarios.length; i++)
                      Container(
                          constraints: BoxConstraints(
                              maxWidth: 100, minWidth: 30),
                          margin: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Colors.cyan,
                              borderRadius: BorderRadius.circular(20)),
                          alignment: Alignment.center,
                          child: FlatButton(
                            child: Column(
                              children: [
                                Text(usuarios[i].nombre,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),

                                if(imagenes != null && imagenes.length == usuarios.length)...[
                                  Image(
                                      width: 50,
                                      height: 50,
                                      image: NetworkImage(imagenes[i]))
                                ] else
                                  ...[
                                    new CircularProgressIndicator()
                                  ]


                              ],

                            ),
                            onPressed: () {
                              Sesion.id = usuarios[i].id;
                              Sesion.nombre = usuarios[i].nombre;
                              Sesion.rol = usuarios[i].rol;
                              SeleccionUsuario();
                            },


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

  cargarImagenesUsuario() async
  {
    if(usuarios != null)
      {
        imagenes = [];
        for(int i = 0;i < usuarios.length; i++)
        {
          imagenes.add(await lecturaImagen(usuarios[i].foto));
        }
        _actualizar();
      }

  }

  void _actualizar() async
  {
    //var reloj = 1;
    //await Future.delayed(Duration(seconds:reloj));
    setState(() {

    });
  }

}







