package helpers
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import starling.events.EventDispatcher;
	
	public class PremioWeb extends EventDispatcher
	{
		protected var loader:URLLoader = new URLLoader();
		protected var _busq:String;
		
		protected var _delay:int;
		protected var web:URLRequest;
		
		protected var url:String;		
		protected var reintentar:int;
		private var _retry:int=0;
		
		protected var numBusq:int;
		public var srt:String;
		
		private var numResultados:int;
		protected var numCompletado:int=1;
		private var st:uint;
		private var x:XML;
		protected var configs:Object;
				
		public function PremioWeb(name:String="") {
			super();
			
			if (Loteria.setting.premios.sorteos.hasOwnProperty(name)) {
				configs = Loteria.setting.premios.sorteos[name];
				url = configs.webofic.url;
			}
			
			web = new URLRequest(url);
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
				loader.load(web);
		}
		
		protected function onComplete(event:Event):void {
			
		}
		
		protected function retry ():void {				
			Loteria.console.log("Esperando premiacion:",srt,"(",numBusq,")");
			st = setTimeout(function ():void {
				numBusq++;
				if (loader) loader.load(web);
			},_delay);
		}
		
		public function buscar (sorteo:String,fecha:Date=null):void {
			srt = sorteo;
			Loteria.console.log("Buscando premio:",sorteo);
		}
		
		public function isComplete():void {
			if (++numResultados==numCompletado) {
				dispatchEventWith("ready",false,this);
			}
		}
		
		public function dispose():void {
			loader.removeEventListener(Event.COMPLETE,onComplete);
			loader=null;
			
			clearTimeout(st);
			
			web=null;
			removeEventListeners(Event.COMPLETE);
		}
		
		protected function getTweets(source:String,filter:Function):String {
			var a:int,b:int,t:String;
			var e:Boolean=false;
			
			for (var i:int = 0; i < 20; i++) {
				a = source.indexOf('<div class="js-tweet-text-container">',b);
				b = source.indexOf('</div>',a);
				t = source.substring(a,b+6);
				
				x = XML(t);
				t = x.p[0].text();
				if (filter.call(this,t)) {
					return t;
				}
			}
			return null;
		}
		
		protected function getDlotery (src:String,sorteo:String,hora:String):String {
			var a:int,b:int;
			a = src.indexOf(sorteo);
			src = src.substr(a);
			a = src.indexOf("<table");
			b = src.indexOf("</table>",a);
			src = src.substring(a,b);
			return src;
		}
	}
}