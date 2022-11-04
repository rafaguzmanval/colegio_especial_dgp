import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:colegio_especial_dgp/Dart/passport_method.dart';
import 'package:colegio_especial_dgp/Dart/sesion.dart';
import 'package:colegio_especial_dgp/Dart/discapacidad.dart';
import 'package:colegio_especial_dgp/Flutter/loginpage.dart';
import 'package:colegio_especial_dgp/Flutter/myhomepage.dart';
import 'package:colegio_especial_dgp/Flutter/perfil_alumno.dart';
import 'package:colegio_especial_dgp/Dart/rol.dart';
import 'package:colegio_especial_dgp/Dart/clase.dart';
import 'package:colegio_especial_dgp/Dart/usuario.dart';

import 'package:colegio_especial_dgp/Dart/acceso_bd.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';

import "package:image_picker/image_picker.dart";

import "package:flutter_tts/flutter_tts.dart";
import 'package:intl/intl.dart';




enum SeleccionImagen{
  camara,
  galeria
}


class RegistroUsuarios extends StatefulWidget{

  @override
  RegistroUsuariosState createState() => RegistroUsuariosState();

}

class RegistroUsuariosState extends State<RegistroUsuarios>{

  var db = FirebaseFirestore.instance;

  AccesoBD base = new AccesoBD();


  var fotoTomada;
  ImagePicker capturador = new ImagePicker();

  var registrando = false;
  var mensajeDeRegistro = "";
  var rolElegido = "ningun rol elegido";
  var fechaElegida = null;


  final controladorNombre = TextEditingController();
  final controladorApellidos = TextEditingController();
  final controladorPassword = TextEditingController();
  final controladorFechanacimiento = TextEditingController();
  final controladorRol = TextEditingController();


  ///Cuándo se pasa de página es necesario que todos los controladores de los formularios y de los reproductores de vídeo se destruyan.
  @override
  void dispose(){

    super.dispose();
  }



  @override
  void initState(){
    super.initState();

    Sesion.paginaActual = this;

  }

  ///introduce en el atributo @fototomada la imagen, @seleccion nos indica si el método va a ser desde la cámara o de galería
  seleccionarImagen(seleccion) async{

    try {
      if(seleccion == SeleccionImagen.camara)
        {
      print("Se va a abrir la cámara de fotos");
        fotoTomada =  await capturador.pickImage(
            source: ImageSource.camera,
            imageQuality: 15,

        );}
    else
      {
        print("Se coger una foto de la galería");
        fotoTomada =  await capturador.pickImage(
            source: ImageSource.gallery,
            imageQuality: 15);
      }

    }
    catch(e){
      print(e);
    }
    actualizar();
  }


  /// Este es el build de la clase MyHomePage que devuelve toda la vista génerica más la vista especial de cada usuario.
  @override
  Widget build(BuildContext context){
    
    return

      new Scaffold(

        appBar:AppBar(

          title: Text('Registra un nuevo usuario'),
        ),
        body: Container(

            padding: EdgeInsets.symmetric(vertical: 0, horizontal:  0),
            child: Column(
              children: [


                if(Sesion.rol == Rol.alumno.toString())...[
                  VistaAlumno(),
                ]
                else if(Sesion.rol == Rol.profesor.toString())...[
                  VistaProfesor()
                ]
                else if(Sesion.rol == Rol.administrador.toString())...[
                    VistaAdministrador()
                  ]
              ],
            )




        ),
      );


  }

  ///Este método devuelve toda la vista que va a ver el profesor en un Widget.
  Widget VistaProfesor()
  {
    Navigator.pop(context);
    return
      Container(
      );
  }

  ///Este método devuelve toda la vista que va a ver el alumno en un Widget.
  Widget VistaAlumno()
  {
    Navigator.pop(context);
    return
      Container(
      );
  }


  ///Este método devuelve toda la vista que va a ver el administrador en un Widget.
  Widget VistaAdministrador()
  {
    return
      Container(
        alignment: Alignment.center,
        //padding: EdgeInsets.symmetric(vertical: 0,horizontal: 200),
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children:[
            SizedBox(
              height: 5,
            ),

            SizedBox(
              width: 500,
              child: TextField(
                obscureText: false,
                maxLength: 20,
                decoration: InputDecoration(
                  border:OutlineInputBorder(),
                  hintText: 'Introduce nombre *',
                ),
                controller: controladorNombre,
              ),
            ),

            SizedBox(
              width: 500,
              child:TextField(
                obscureText: false,
                maxLength: 40,
                decoration: InputDecoration(
                  border:OutlineInputBorder(),
                  hintText: 'Introduce apellidos *',
                ),
                controller: controladorApellidos,
              ),
            ),

            SizedBox(
              width: 500,
              child: TextField(
                obscureText: true,
                maxLength: 20,
                decoration: InputDecoration(
                  border:OutlineInputBorder(),
                  hintText: 'Introduce contraseña *',
                ),
                controller: controladorPassword,
              ),
            ),

            const Text(
              "Introduce fecha de nacimiento: *",
              style: TextStyle(fontSize: 20.0, height: 2.0, color: Colors.black),
            ),

            ElevatedButton(onPressed: () async{
              await showDatePicker(context: context, locale: const Locale("es","ES"),initialDate: DateTime.now(), firstDate: DateTime(1940), lastDate: DateTime.now())
              .then((e){ fechaElegida = e ; actualizar();});

            }, child: Text((fechaElegida == null) ?"Elige la fecha de nacimiento" : DateFormat('d/M/y').format(fechaElegida))

            ),

            /*
            TextField(
              obscureText: false,
              decoration: InputDecoration(
                border:OutlineInputBorder(),
                hintText: 'Introduce fecha de nacimiento',
              ),
              controller: controladorFechanacimiento,
            ),*/

            const Text(
              "Elige rol para el usuario: *",
              style: TextStyle(fontSize: 20.0, height: 2.0, color: Colors.black),
            ),

            DropdownButton(
              value: rolElegido,
              items: [Rol.profesor.toString(), Rol.administrador.toString(), Rol.alumno.toString(), "ningun rol elegido"].map((String value){
                return DropdownMenuItem(value: value,
                    child: Text(value),);
              }).toList(),
              onChanged: (String? value){
                setState(() {
                  rolElegido = value!;
                });
              },
            ),

            const Text(
              "Elige foto de perfil (opcional):",
              style: TextStyle(fontSize: 20.0, height: 2.0, color: Colors.black),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ElevatedButton(
                    child: Text('Haz una foto desde la cámara'),
                    onPressed: (){seleccionarImagen(SeleccionImagen.camara);}
                ),

                SizedBox(
                  width: 10,
                ),

                ElevatedButton(
                    child: Text('Elige una foto de la galería'),
                    onPressed: (){seleccionarImagen(SeleccionImagen.galeria);}
                ),
              ],
            ),

            SizedBox(
              height: 100,
              width: 100,
                child: fotoTomada == null
                  ? Center(child: Container(
                  decoration: BoxDecoration(border:Border.all(color: Colors.black)),
                  child: Text('Ninguna foto tomada'),
                ))
                  : Center(child: Image.file(File(fotoTomada.path))),
            ),

            Text(mensajeDeRegistro),

            Visibility(
                visible: !registrando,
                child:
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(const Color.fromRGBO(143, 125, 178,1)),
              ),
              child: Text("Registrar",
                style: TextStyle(
                    backgroundColor: Colors.transparent,
                    color: Colors.white
                ),
              ),
              onPressed: () {
                registrarUsuario();
              },

            )
            ),


            Visibility(
                visible: registrando,
                child: new CircularProgressIndicator()

            ),

          ],
        ),
      );
  }

  onDateChanged()
  {

  }

  //Método para registrar usuario
  registrarUsuario()
  {

    // FALTARIA HACER COMPROBACIÓN DE QUE EL NOMBRE Y APELLIDOS YA ESTÁN REGISTRADOS EN LA BASE DE DATOS

    if(controladorNombre.text.isNotEmpty && controladorApellidos.text.isNotEmpty && controladorPassword.text.isNotEmpty
        && fechaElegida != null && rolElegido != "ningun rol elegido")
    {
      registrando = true;
      actualizar();

      var nombre = "" + controladorNombre.text;
      var apellidos = "" + controladorApellidos.text;
      var password = "" + controladorPassword.text;
      var fechanacimiento = "" + DateFormat('d/M/y').format(fechaElegida);
      var rol = "" + rolElegido;

      Usuario usuario = Usuario();
      usuario.setUsuario(
          nombre, apellidos, password, fechanacimiento, rol, "",Passportmethod.text);

      var foto = null;
      if(fotoTomada != null)
        {
          foto = File(fotoTomada.path);
        }


      var future = base.registrarUsuario(usuario, foto);

      future.then((value) {
        registrando = false;

        if (value) {
          controladorNombre.text = "";
          controladorApellidos.text = "";
          controladorPassword.text = "";
          controladorFechanacimiento.text = "";
          fotoTomada = null;

          mensajeDeRegistro =
          "Registro completado correctamente\nPuedes volver a registrar otro usuario:";
        }
        else {
          mensajeDeRegistro = "Fallo al registrar, inténtelo de nuevo";
          mostrarError(mensajeDeRegistro);
        }

        actualizar();
      });
    }
    else
      {
        mensajeDeRegistro = "Debe rellenar todos los campos";
        mostrarError(mensajeDeRegistro);
        actualizar();
      }
  }

  mostrarError(mensaje){
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: Container(
            padding: const EdgeInsets.all(16),
            height: 90,
            decoration: const BoxDecoration(
              color: Color(0xFFC72C41),
              borderRadius: BorderRadius.all(Radius.circular(29)),
            ),
            child: Text(mensaje),
          )
      ),
    );
  }
  /*
  Future<Null> _selectDate(BuildContext context) async{
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
      firstDate: DateTime(1940),
      lastDate: DateTime(2101));

    if(picked != null)
      setState(() {
        fechaElegida = picked;
        Date
        controladorFechanacimiento.text = DateFormat.yMd().format(fechaElegida);
      });
  }*/

 void actualizar() async
  {
    setState((){});
  }

}








