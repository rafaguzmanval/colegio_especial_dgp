
class Sesion{
   static var id;
   static var nombre;
   static var rol;
   static var misTareas;
   static var seleccion;
   static var paginaActual;
   static var controladoresVideo = [];

   static reload(){
      id = null;
      nombre = null;
      rol = null;
      misTareas = [];
      seleccion = null;

   }

   Sesion(){
      id = null;
      nombre = null;
      rol = null;
      misTareas = [];
      seleccion = null;
   }
}