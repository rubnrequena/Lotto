package helpers
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.URLVariables;

	public class Premio_RuletonPeru extends PremioWeb implements IPremio
	{
		private var _sorteo:*;
		private var localLog:File;
		public function Premio_RuletonPeru()
		{
			super("ruletonperu");
		}
		
		override public function buscar(sorteo:String,fecha:Date=null):void {
			super.buscar(sorteo,fecha);
			
			//_localFecha = DateFormat.format(fecha,"dd/mm/yyyy");
			_busq = DateFormat.format(fecha,"dd/mm/yyyy").toLowerCase();
			_sorteo = sorteo.split(" ").slice(-2).join("").toLowerCase();
			
			localLog = File.applicationStorageDirectory.resolvePath("RULETONPR/"+sorteo.split(":").join("_")+".txt");
			
			var fv:URLVariables = new URLVariables;
			fv.fecha = _busq.toLowerCase();
			fv.hora = _sorteo.toLocaleLowerCase();
			fv.sorteo = "ruletonperu";
			
			web.data = fv;
			loader.load(web);				
		}
		
		override protected function onComplete(event:Event):void {
			if (numBusq++>60) return;
			if (loader.data && loader.data!="") {
				var src:Object = JSON.parse(loader.data);
				//src.ganador = ObjectUtil.trailZero(src.ganador);
				Loteria.console.log("Premio Tweeter:",srt,"(",src.ganador,")");
				dispatchEventWith(Event.COMPLETE,false,src.ganador);
				isComplete();
			} else retry();
		}
	}
}