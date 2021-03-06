package vos
{
	

	public class Usuario
	{
		public static const SUSPENDIDO:int = 0;
		public static const SUSPENDIDO_PAGO:int = 1;
		public static const GRUPOS_SUSPENDIDOS:int = 2;
		public static const USUARIO_ACTIVO:int = 3;
		public static const PAGO_SUSPENDIDO:int = -10;
		public static const ACTIVO:int = 3;

		public static const TIPO_TAQUILLA:int = 1;
		public static const TIPO_GRUPO:int = 2;
		public static const TIPO_BANCA:int = 3;
		public static const TIPO_USUARIO:int = 4;
		public static const TIPO_COMERCIAL:int = 5;
		public static const TIPO_ADMIN:int = 6;

		
		public var usuarioID:int;
		public var usuario:String;
		public var clave:String;
		public var nombre:String;
		public var tipo:int;
		public var activo:int;
		public var registrado:Number;
		public var renta:Number;
		public var papelera:int;
		public var contacto:String;
		
		public var comision:Number;
		public var participacion:Number;
		
		public function get usID():String {
			if (tipo==1) return "u"+usuarioID;
			if (tipo==2) return "c"+usuarioID;
			return usuarioID.toString();
		}
	}
}