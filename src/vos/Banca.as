package vos
{
	public class Banca
	{
		public var bancaID:int;
		public var usuarioID:int;
		public var nombre:String;
		public var activa:int;
		public var renta:Number;
		
		public var comision:Number;
		
		public var usuario:String;
		public var clave:String;
		
		public var papelera:Boolean;
		public var creacion:String;
		public var contacto:String;

		public function get usID():String {
			return "g"+bancaID;
		}
	}
}