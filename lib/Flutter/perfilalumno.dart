
import 'package:colegio_especial_dgp/Dart/Sesion.dart';
import 'package:colegio_especial_dgp/Dart/discapacidad.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import '../Dart/clase.dart';
import '../Dart/usuario.dart';

import 'package:colegio_especial_dgp/Dart/AccesoBD.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';


class perfilAlumno extends StatefulWidget{

  @override
  perfilAlumnoState createState() => perfilAlumnoState();

}

class perfilAlumnoState extends State<perfilAlumno>{


  AccesoBD base = new AccesoBD();

  var usuarioPerfil;

  var imagenPerfil;

  final myController = TextEditingController();

  @override
  void dispose(){
    myController.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();

    Sesion.paginaActual = this;
    cargarUsuario();


  }

  @override
  Widget build(BuildContext context){



    return Scaffold(
      appBar:AppBar(
        title: Text('Perfil de ${Sesion.seleccion.nombre}'
            ''),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal:  10),
        child: Column(
          children: [


            if(Sesion.rol == Rol.alumno.toString())...[
              VistaAlumno()
            ]
            else if(Sesion.rol == Rol.profesor.toString())...[
              VistaProfesor()
            ]
            else if(Sesion.rol == Rol.administrador.toString())...[
                VistaAdministrador()
              ]
              else if(Sesion.rol == Rol.programador.toString())...[
                  VistaProgramador()
                ]
          ],
        )


      ),
    );
  }


  Widget VistaProfesor()
  {
    return
      Container(
        //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
        child:Column(
          children:[

            if(usuarioPerfil != null)...[
              Text(usuarioPerfil.nombre),
              Text(usuarioPerfil.apellidos),
              Text(usuarioPerfil.fechanacimiento),
              Text(usuarioPerfil.rol),

              Image(
                width: 100,
                height: 100,
                image: NetworkImage(usuarioPerfil.foto),
              )
              ,
              Text("\nTAREAS:"),


              if(Sesion.misTareas != null)...
                [
                  for(int i = 0; i < Sesion.misTareas.length; i++)
                    Container(
                        child:Row(
                          children: [

                                Text(Sesion.misTareas[i]),
                                IconButton(onPressed: () {base.eliminarTareaAlumno(Sesion.seleccion.id, Sesion.misTareas[i]);},
                                icon: Icon(Icons.delete)
                                )


                          ],
                        )

                    ),
                ],




              Text("\n Añadir Tarea: "),

              TextField(
                decoration: InputDecoration(
                  border:OutlineInputBorder(),
                  hintText: 'Introduce nueva tarea',
                ),
                controller: myController,
              ),

              ElevatedButton(
                child: Text("Añadir Tarea",
                  style: TextStyle(
                      color: Colors.amberAccent,
                  ),
                ),
                onPressed: () {
                  base.addTareaAlumno(Sesion.seleccion.id, myController.text);
                },


              )



            ]else ...[
              new CircularProgressIndicator()
            ]



          ],
        ),
      );
  }


  Widget VistaAlumno()
  {
    return
      Container(
        //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
          child:Column(
              children:[
                        Text("Eres un alumno"),


                    ],
                  ),
      );
  }


  Widget VistaAdministrador()
  {
    return
      Container(
        //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
        child:Column(
          children:[

            Text("Eres un profesor")

          ],
        ),
      );
  }

  Widget VistaProgramador()
  {
    return
      Container(
        //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
        child:Column(
          children:[

            Text("Eres un profesor")

          ],
        ),
      );
  }

  cargarUsuario() async// EN sesion seleccion estara el id del usuario que se ha elegido
  {
    usuarioPerfil = await base.consultarIDusuario(Sesion.seleccion.id);
    await base.consultarTareas(Sesion.seleccion.id);
    actualizar();
  }

  lecturaImagen(path) async
  {
     return await base.leerImagen(path);
  }


  void actualizar()
  {

    setState(() {

    });
  }

}








