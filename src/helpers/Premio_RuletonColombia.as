package helpers
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.URLVariables;

	public class Premio_RuletonColombia extends PremioWeb implements IPremio
	{
		private var _sorteo:*;
		private var localLog:File;
		public function Premio_RuletonColombia()
		{
			super("ruletoncol");
		}
		
		override public function buscar(sorteo:String,fecha:Date=null):void {
			super.buscar(sorteo,fecha);
			
			//_localFecha = DateFormat.format(fecha,"dd/mm/yyyy");
			_busq = DateFormat.format(fecha,"dd/mm/yyyy").toLowerCase();
			_sorteo = sorteo.split(" ").slice(-2).join("").toLowerCase();
			
			localLog = File.applicationStorageDirectory.resolvePath("RULETONCOL/"+sorteo.split(":").join("_")+".txt");
			
			var fv:URLVariables = new URLVariables;
			fv.fecha = _busq.toLowerCase();
			fv.hora = _sorteo.toLocaleLowerCase();
			fv.sorteo = "ruletoncol";
			
			web.data = fv;
			loader.load(web);				
		}
		
		override protected function onComplete(event:Event):void {
			if (numBusq++>60) return;
			if (loader.data && loader.data!="") {
				var src:Object = JSON.parse(loader.data);
				//src.ganador = ObjectUtil.trailZero(src.ganador);
				Loteria.console.log("Premio SRQBrigde:",srt,"(",src.ganador,")");
				dispatchEventWith(Event.COMPLETE,false,src.ganador);
				isComplete();
			} else retry();
		}		
	}
}