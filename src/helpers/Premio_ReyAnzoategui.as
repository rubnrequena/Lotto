package helpers
{
	import flash.events.Event;

	public class Premio_ReyAnzoategui extends PremioWeb implements IPremio
	{
		private var _fecha:String;
		public function Premio_ReyAnzoategui()
		{
			url = 'https://www.animalitosreyanzoategui.com/resultanimalitos?limit=8';
			super();
		}
		
		override public function buscar(sorteo:String, fecha:Date=null):void {
			super.buscar(sorteo, fecha);
			_busq = sorteo.split(" ").slice(-2).join(" ").toUpperCase();
			_fecha = DateFormat.format(fecha);
			loader.load(web);
		}
		
		override protected function onComplete(event:Event):void {
			if (numBusq>30) return;
			var source:Object = JSON.parse(loader.data);
			var b:Boolean=true;
			for each (var s:Object in source.rows) {
				if (s.fecha==_fecha && s.descripcion==_busq) {
					b=false;
					Loteria.console.log("Premio encontrado:",srt,"(",s.numero,")");
					dispatchEventWith(Event.COMPLETE,false,s.numero);
					isComplete();
				}
			}
			if (b) retry();
		}
		
	}
}