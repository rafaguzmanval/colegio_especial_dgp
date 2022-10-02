
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
  var imagen;


  @override
  void initState(){
    super.initState();
    inicializar();
    lecturaImagen("AppStorage/ugr.png");
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

              if(imagen != null)
              Image.memory(imagen)
            ],
          )


      ),
    );
  }

  inicializar() async{
    usuarios = await base.consultarTodosUsuarios();
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
    else
    return
      Container(
        //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
          child:Column(
              children:[
                          for(int i = 0; i < usuarios.length; i++)
                            Container(
                              constraints: BoxConstraints(maxWidth: 100,minWidth: 30),
                              margin: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.cyan,
                                borderRadius: BorderRadius.circular(20)),
                              alignment: Alignment.center,
                              child: FlatButton(
                                child: Text(usuarios[i].nombre,
                                    style: TextStyle(
                                          color: Colors.white,
                                      ),
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
                )



      );
  }

  lecturaImagen(path)
  {
    var future = base.leerImagen(path);

    future.then((value){
      imagen = value;
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







