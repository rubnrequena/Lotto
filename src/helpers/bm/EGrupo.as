package helpers.bm
{
	import starling.events.EventDispatcher;
	
	public class EGrupo extends EventDispatcher
	{
		public var id:int;
		public var sorteos:Array;
		public function EGrupo() {
			super();
			sorteos = [];
		}
		
		public function registrar (venta:Object):void {
			/*var sorteo:EVentas = new EVentas;
			sorteo.sorteoID = venta.sorteoID;
			sorteo.monto = venta.monto;
			sorteo.numero = venta.numero;*/
			sorteos.push(venta);
		}
		
	}
}