import 'package:colegio_especial_dgp/AccesoBD.dart';
import 'package:flutter/material.dart';



class MyHomePage extends StatefulWidget{

  @override
  MyHomePageState createState() => MyHomePageState();



}

class MyHomePageState extends State<MyHomePage>{

  String msg = 'hola';
  AccesoBD base = new AccesoBD();

  @override
  void initState(){
    super.initState();
    lectura();

  }

  @override
  Widget build(BuildContext context){



    base.escribirDatos();

    return DefaultTabController(length: 1, child: Scaffold(
      key: GlobalKey<ScaffoldState>(),
      appBar:AppBar(
        title: const Text('AppEspecial')
      ),
      body: TabBarView(
        children: <Widget>[

          Text(msg)

        ],

      ),
    )
    );
  }

  lectura()
  {
    Future<String> future = base.leerDatos();

    future.then((value){
      msg = value;
      print(msg);
      _actualizar();

    });
  }


  void _actualizar() async
  {
    var reloj = 1;
    await Future.delayed(Duration(seconds:reloj));
    setState(() {

    });
  }

}








