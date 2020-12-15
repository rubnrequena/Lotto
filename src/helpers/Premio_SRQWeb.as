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
	import flash.utils.getTimer;
	import flash.utils.clearTimeout;
	
	public class Premio_SRQWeb extends EventDispatcher implements IPremio
	{
		private var localLog:File;
		private var web:URLRequest;
		private var loader:URLLoader;
		private var configs:Object;
		private var _delay:int;
		private var st:uint;
		private var srt:String;
		private var _name:String;

		private var reintentar:int;
		private var reintentos:int=Loteria.setting.premios.reintentos || 10;

		private var inicioBusq:int;
		private var tiempoBusq:int=Loteria.setting.premios.tiempoBusqueda_ms || 3600000; //1 hora
		
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
			
			_delay = int(Loteria.setting.premios.retraso || 5)*60000; //ms a minutos			
			
			loader = new URLLoader;
			loader.addEventListener(Event.COMPLETE,onComplete);
			loader.addEventListener(IOErrorEvent.IO_ERROR,error);
			loader.dataFormat = URLLoaderDataFormat.TEXT;
		}
		protected function get sigoBuscando():Boolean {
			var time:int = getTimer() - inicioBusq;
			return time > tiempoBusq?false:true;
		}
		protected function error(event:IOErrorEvent):void {
			Loteria.console.log("404:",srt,event.text);
			retry();
		}
		private function onComplete(event:Event):void {
			var data:String = loader.data;
			if (data && data!="") {
				try {
					var src:Object = JSON.parse(data);
					if (!src.hasOwnProperty("zodiaco")) {
						src.ganador = ObjectUtil.trailZero(src.ganador);
					}
					Loteria.console.log("200:",srt,"numero:",src.ganador);
					dispatchEventWith(Event.COMPLETE,false,src.ganador);
					isComplete();
				} catch (err) {
					Loteria.console.log("500: FORMATO INVALIDO",srt);
				}
			} else retry();
		}
		
		private function retry():void {
				st = setTimeout(function ():void {
					if (loader) loader.load(web);
				},_delay);
		}
		
		public function isComplete():void {
			dispatchEventWith("ready",false,this);
		}
		
		public function buscar(sorteo:String, fecha:Date=null):void {
			if (inicioBusq==0) inicioBusq=getTimer();
			srt = sorteo;
			
			var fv:URLVariables = new URLVariables;
			fv.hora = sorteo.toLocaleLowerCase();
			fv.sorteo = _name;
			fv.servidor = Loteria.setting.servidor;
			
			web.data = fv;
			Loteria.console.log('[JV:Premio] Iniciando busqueda de premio:',sorteo)
			loader.load(web);
		}
		
		public function dispose():void {
			clearTimeout(st);
			if (loader) loader.close();
		}
	}
}