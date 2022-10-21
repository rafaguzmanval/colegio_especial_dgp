
class Sesion{
   static var id;
   static var nombre;
   static var rol;
   static var tareas;
   static var seleccion;
   static var paginaActual;
   static var controladoresVideo = [];

   static reload(){
      id = null;
      nombre = null;
      rol = null;
      tareas = [];
      seleccion = null;

   }

   Sesion(){
      id = null;
      nombre = null;
      rol = null;
      tareas = [];
      seleccion = null;
   }
}