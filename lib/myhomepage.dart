import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';


class MyHomePage extends StatefulWidget{

  @override
  MyHomePageState createState() => MyHomePageState();



}

class MyHomePageState extends State<MyHomePage>{

  String msg = 'hola';
  AccesoBase base = new AccesoBase();

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








class AccesoBase{
  DatabaseReference ref = FirebaseDatabase.instance.ref();

  escribirDatos() async{
    await ref.child("usuario/0").set({
      "nombre": "Manolo",
      "telefono" : "3424"
    });

    await ref.child("usuario/1").set({
      "nombre": "Pepe",
      "telefono" : "6666",
      "edad" : "16"
    });

  }



  Future<String> leerDatos() async{

    final valor = await ref.child("usuario/0").get();


    return valor.value.toString();
  }


}