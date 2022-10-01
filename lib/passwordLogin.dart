
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

  @override
  Widget build(BuildContext context){

    final myController = TextEditingController();

    @override
    void dispose(){
      myController.dispose();
      super.dispose();
    }
    //base.escribirDatos();

    return Scaffold(
      appBar:AppBar(
          title:  Text('Hola ${Sesion.nombre}')
      ),
      body: Container(
        alignment: Alignment.center,
          child: Column(
            children: [
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border:OutlineInputBorder(),
                  hintText: 'Introduce la clave',
                    ),
                  controller: myController,
                ),

                  FlatButton(
                    child: Text("Enviar",
                      style: TextStyle(
                        color: Colors.cyan,
                        decorationColor: Colors.lightBlueAccent
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
                              constraints: BoxConstraints(maxWidth: 70,minWidth: 30),
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
                                     ComprobarLogeo(usuarios[i].id, usuarios[i].password);
                                 },


                              )

                            )
                      ]
                )



      );
  }



  void _actualizar() async
  {
    //var reloj = 1;
    //await Future.delayed(Duration(seconds:reloj));
    setState(() {

    });
  }

}







