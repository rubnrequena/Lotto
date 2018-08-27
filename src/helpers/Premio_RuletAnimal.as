package helpers
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.URLVariables;

	public class Premio_RuletAnimal extends PremioWeb implements IPremio
	{
		private var _fecha:String;		
		private var localLog:File;
		public function Premio_RuletAnimal()
		{
			super("ruletanimal");			
		}
		
		override public function buscar(sorteo:String, fecha:Date=null):void
		{
			super.buscar(sorteo, fecha);
			_busq = sorteo.split(" ").pop();
			_fecha = DateFormat.format(fecha,"dd/mm/yy");
			
			localLog = File.applicationStorageDirectory.resolvePath("RULETANIMAL/"+sorteo.split(":").join("_")+".txt");
			
			var fv:URLVariables = new URLVariables;
			fv.fecha = _fecha;
			fv.hora = _busq.toLocaleLowerCase();
			fv.sorteo = "ruletanimal";
			
			web.data = fv;
			loader.load(web);
		}
		
		override protected function onComplete(event:Event):void
		{
			if (numBusq++>60) return;
			if (loader.data && loader.data!="") {
				var src:Object = JSON.parse(loader.data);
				//src.ganador = ObjectUtil.trailZero(src.ganador);
				Loteria.console.log("Premio WebOficial:",srt,"(",src.ganador,")");
				dispatchEventWith(Event.COMPLETE,false,src.ganador);
				isComplete();
			} else retry();
		}	
	}
}