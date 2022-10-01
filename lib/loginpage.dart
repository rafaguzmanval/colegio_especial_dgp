
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


class LoginPage extends StatefulWidget{

  @override
  LoginPageState createState() => LoginPageState();

}

class LoginPageState extends State<LoginPage>{

  AccesoBD base = new AccesoBD();


  @override
  void initState(){
    super.initState();
    ComprobarLogeo("oVCDb0mXIhjjC2GB3WFR","OtraMierdaContraseña");
  }

  @override
  Widget build(BuildContext context){



    //base.escribirDatos();

    return Scaffold(
      appBar:AppBar(
          title:  Text('TuCole')
      ),
      body: Container(
          child: Column(
            children: [
            Text("Pagina de logueo")
            ],

          )


      ),
    );
  }


  ComprobarLogeo(id,password) async
  {
    var resul = await base.checkearPassword(id,password);

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







