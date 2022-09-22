import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';


class MyHomePage extends StatefulWidget{

  @override
  MyHomePageState createState() => MyHomePageState();



}

class MyHomePageState extends State<MyHomePage>{
  @override
  Widget build(BuildContext context){



    return DefaultTabController(length: 1, child: Scaffold(
      key: GlobalKey<ScaffoldState>(),
      appBar:AppBar(
        title: const Text('AppEspecial')
      ),
      body: TabBarView(
        children: <Widget>[
          Text('Hola')
        ],
        
      ),
    )
    );
  }
}