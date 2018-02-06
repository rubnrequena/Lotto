package helpers.bm
{
	import starling.events.EventDispatcher;
	
	public class ESorteo extends EventDispatcher
	{
		public var sorteo:int;
		public var ventas:Vector.<EVentas>;

		private var v:EVentas;
		public function ESorteo() {
			super();
			ventas = new Vector.<EVentas>;
		}
		
		public function registrar (venta:Object):void {			
			v = new EVentas;
			for each (v in ventas) {
				if (v.numero==venta.numero) {
					v.monto += venta.monto;
					return;
				}
			}
			v = new EVentas;
			v.monto = venta.monto;
			v.numero = venta.numero;
			ventas.push(v);
		}
	}
}