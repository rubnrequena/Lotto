package helpers
{
	import flash.events.Event;
	import flash.net.URLVariables;

	public class Premio_LotoSelva extends PremioWeb implements IPremio
	{
		private var _fecha:String;
		public function Premio_LotoSelva()
		{
			//url = 'http://www.lotoselva.com/control/resultados.php';
			super("selva");
		}
		
		override public function buscar(sorteo:String, fecha:Date=null):void {
			super.buscar(sorteo, fecha);
			_busq = sorteo.split(" ").slice(-2).join(" ");
			_fecha = DateFormat.format(fecha,"dd-mm-yyyy");
			
			var urld:URLVariables = new URLVariables;
			urld.sorteo = "selva";
			urld.fecha = _fecha;
			urld.hora = _busq;
			web.data = urld;		
			
			loader.load(web);
		}
		override protected function onComplete(event:Event):void {
			if (numBusq++>60) return;
			if (loader.data && loader.data!="") {
				var src:Object = JSON.parse(loader.data);
				//src.ganador = ObjectUtil.trailZero(src.ganador);
				Loteria.console.log("Premio Selva Tweeter:",srt,"(",src.ganador,")");
				dispatchEventWith(Event.COMPLETE,false,src.ganador);
				isComplete();
			} else retry();
		}
		/*override protected function onComplete(event:Event):void {
			if (numBusq>30) return;
			var xml:XML = XML(loader.data);
			var b:Boolean=true;
			for each (var x:XML in xml.Animalitos) {
				if (x.@Fecha==_fecha && x.@Sorteo==_busq) {
					b=false;
					var n:String = ObjectUtil.trailZero(x.@Numero);
					Loteria.console.log("Premio recibido",srt,"PLENO",n);
					dispatchEventWith(Event.COMPLETE,false,n);
					isComplete();
					return;
				}
			}
			if (b) retry();
		}*/
		
	}
}