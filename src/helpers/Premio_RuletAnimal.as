package helpers
{
	import flash.events.Event;
	
	import starling.utils.StringUtil;

	public class Premio_RuletAnimal extends PremioWeb implements IPremio
	{
		private var _fecha:String;
		public function Premio_RuletAnimal()
		{
			url = 'https://twitter.com/Ruletanimal';
			super();
		}
		
		override public function buscar(sorteo:String, fecha:Date=null):void
		{
			super.buscar(sorteo, fecha);
			_busq = sorteo.split(" ").pop();
			_fecha = DateFormat.format(fecha,"dd/mm/yy");
			loader.load(web);
		}
		
		override protected function onComplete(event:Event):void
		{
			if (numBusq>60) return;
			var data:String = (loader.data as String).toUpperCase();
			var sorteo:int = data.indexOf("SORTEO "+_busq);
			var fecha:int = data.indexOf(_fecha,sorteo);
			var fs:int = sorteo-fecha;
			if (sorteo>-1 && fs<30) {
				data = data.substring(sorteo,data.indexOf("(",sorteo));
				data = data.split("\n").pop();
				data = data.split(":").pop();
				data = StringUtil.trim(data);
				Loteria.console.log("Premio recibido",srt+" "+_fecha,"PLENO",data);
				dispatchEventWith(Event.COMPLETE,false,data);
				isComplete();
			} else retry();
		}
		
	}
}