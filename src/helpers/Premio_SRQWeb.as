package helpers
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.utils.setTimeout;
	
	import starling.events.EventDispatcher;
	
	public class Premio_SRQWeb extends EventDispatcher implements IPremio
	{
		private var localLog:File;
		private var web:URLRequest;
		private var loader:URLLoader;
		private var configs:Object;
		private var _delay:int;
		private var reintentar:int;
		private var _retry:int;
		private var numBusq:int;
		private var st:uint;
		private var numResultados:int;
		private var numCompletado:Object;
		private var srt:String;
		private var _name:String;
		
		public function Premio_SRQWeb(name:String)
		{
			if (Loteria.setting.premios.sorteos.hasOwnProperty(name)) {
				configs = Loteria.setting.premios.sorteos[name];
			} else {
				configs = Loteria.setting.premios.sorteos["predeterminado"]
			}
			
			_name = name;
			web = new URLRequest(configs.webofic.url);
			web.useCache = false;
			web.cacheResponse = false;
			
			_delay = int(Loteria.setting.premios.retraso)*60000; //ms a minutos
			reintentar = 3;
			_retry = 0;
			
			loader = new URLLoader;
			loader.addEventListener(Event.COMPLETE,onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR,error);
			loader.dataFormat = URLLoaderDataFormat.TEXT;
		}
		
		protected function error(event:IOErrorEvent):void {
			Loteria.console.log("ERROR AL CONCECTAR CON SERVIDOR DE PREMIOS");
			if (_retry++<3)
				if (loader) loader.load(web);
		}
		
		protected function onComplete(event:Event):void {
			if (numBusq++>60) return;
			if (loader.data && loader.data!="") {
				var src:Object = JSON.parse(loader.data);
				//src.ganador = ObjectUtil.trailZero(src.ganador);
				Loteria.console.log("Premio SRQBridge:",srt,"(",src.ganador,")");
				dispatchEventWith(Event.COMPLETE,false,src);
				isComplete();
			} else retry();
		}
		
		private function retry():void
		{
			Loteria.console.log("Esperando premiacion:",srt,"(",numBusq,")");
			st = setTimeout(function ():void {
				numBusq++;
				if (loader) loader.load(web);
			},_delay);
		}
		
		public function isComplete():void {
			if (++numResultados==numCompletado) {
				dispatchEventWith("ready",false,this);
			}
		}
		
		public function buscar(sorteo:String, fecha:Date=null):void
		{
			srt = sorteo;
			localLog = File.applicationStorageDirectory.resolvePath("RULETONCOL/"+sorteo.split(":").join("_")+".txt");
			
			var fv:URLVariables = new URLVariables;
			//fv.fecha = DateFormat.format(fecha);
			fv.hora = sorteo.toLocaleLowerCase();
			fv.sorteo = _name;
			
			web.data = fv;
			trace("BUSCAR",web.url,JSON.stringify(fv));
			loader.load(web);
		}
		
		public function dispose():void
		{
		}
	}
}