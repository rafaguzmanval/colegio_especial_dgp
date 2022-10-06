
import 'package:colegio_especial_dgp/discapacidad.dart';
import 'package:colegio_especial_dgp/main.dart';
import 'package:colegio_especial_dgp/myhomepage.dart';
import 'clase.dart';
import 'usuario.dart';
import 'Sesion.dart';

import 'package:colegio_especial_dgp/AccesoBD.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';


class PasswordLogin extends StatefulWidget{

  @override
  PasswordLoginState createState() => PasswordLoginState();

}

class PasswordLoginState extends State<PasswordLogin>{

  AccesoBD base = new AccesoBD();
  var usuarios;


  @override
  void initState(){
    super.initState();
    Sesion.paginaActual = this;

  }

  final myController = TextEditingController();

  @override
  void dispose(){
    myController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context){

    return Scaffold(
      appBar:AppBar(
          title:  Text('Hola ${Sesion.nombre}'),

      ),
      body:
          Container(
              margin:EdgeInsets.all(5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  TextField(
                    obscureText: true,

                    decoration: InputDecoration(
                      border:OutlineInputBorder(),
                      hintText: 'Introduce la clave',
                        ),
                      controller: myController,
                    ),

                  ElevatedButton(
                        child: Text("Enviar",
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                        onPressed: () {
                          ComprobarLogeo(Sesion.id, myController.text);
                        },


                      )
                ],
              )

        ),
    );
  }

  inicializar() async{
    usuarios = await base.consultarTodosUsuarios();
    _actualizar();
  }


  ComprobarLogeo(id,password) async
  {
    var resul = await base.checkearPassword(id,password);

    print(resul);

    if(resul){
      Navigator.push(context,
      MaterialPageRoute(builder: (context) => MyHomePage())
      );
    }
    else
      {

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







