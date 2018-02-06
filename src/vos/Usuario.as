package vos
{
	public class Usuario
	{
		public static const SUSPENDIDO:int = 0;
		public static const USUARIO_SUSPENDIDO:int = 1;
		public static const GRUPOS_SUSPENDIDOS:int = 2;
		public static const ACTIVO:int = 3;
		
		public var usuarioID:int;
		public var usuario:String;
		public var clave:String;
		public var nombre:String;
		public var tipo:int;
		public var activo:int;
		public var registrado:Number;
		public var renta:Number;
		
	}
}