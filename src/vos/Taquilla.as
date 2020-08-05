package vos
{
	public class Taquilla
	{
		public var taquillaID:int;
		public var usuarioID:int;
		public var bancaID:int;
		public var nombre:String;
		public var usuario:String;
		public var clave:String;
		public var activa:Boolean;
		public var estaActiva:int;
		public var comision:Number;
		
		public var fingerprint:String;
		public var fingerlock:Boolean;
		
		public var conectado:Number;
		public var papelera:int;
		public var creacion:String;
		public var contacto:String;

		//public var impuesto:Number = 4
		
		public function get usID():String {
			return "t"+taquillaID;
		}
	}
}