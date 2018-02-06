package helpers
{
	import flash.events.Event;

	public class Premio_LotoSelva extends PremioWeb implements IPremio
	{
		private var _fecha:String;
		public function Premio_LotoSelva()
		{
			url = 'http://parlay.website/lotoselva/control/resultados.php';
			super();
		}
		
		override public function buscar(sorteo:String, fecha:Date=null):void {
			super.buscar(sorteo, fecha);
			_busq = sorteo.split(" ").slice(-2).join(" ");
			_fecha = DateFormat.format(fecha);
			loader.load(web);
		}
		
		override protected function onComplete(event:Event):void {
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
		}
		
	}
}