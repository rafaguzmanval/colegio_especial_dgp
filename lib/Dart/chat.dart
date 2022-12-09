import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  var id;
  var idUsuario1;
  var idUsuario2;
  var nombre;
  var foto;
  bool sinLeer;
  var fechaUltimoMensaje;

  // Constructor
  Chat(this.id,
        this.idUsuario1,
        this.idUsuario2,
        this.nombre,
        this.foto,
        this.sinLeer,
        this.fechaUltimoMensaje);

}