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
		public var papelera:int;
		
		public var comision:Number;
		public var participacion:Number;
		
		public function get usID():String {
			if (tipo==1) return "u"+usuarioID;
			if (tipo==2) return "c"+usuarioID;
			return usuarioID.toString();
		}
	}
}