package helpers
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	public class Premio_GranRuleta extends PremioWeb implements IPremio
	{
		private var _sorteo:String;
		private var _localFecha:String;
		
		private var dl_url:String;
		private var dl_loader:URLLoader;
		private var dl_req:URLRequest;
		private var stdLot:uint;
		private var localLog:File;
		
		public function Premio_GranRuleta()
		{
			url = 'https://twitter.com/lagranruleta';
			dl_url = 'https://dlottery.wordpress.com/';
			
			dl_loader = new URLLoader;
			dl_loader.addEventListener(Event.COMPLETE,dl_complete);
			
			dl_req = new URLRequest(dl_url);
			dl_req.cacheResponse=false;
			dl_req.useCache=false;
			
			super();
			numCompletado=2;
			
		}
		
		protected function dl_complete(event:Event):void
		{
			if (numBusq>60) return;
			var source:String = dl_loader.data;			
			//vefiricar dia de premio
			var ts:int = source.indexOf(_localFecha);
			if (ts>-1) {
				var a:int = source.indexOf("Resultados Gran Ruleta");
				var b:int = source.indexOf("</table>",a);
				source = source.substring(a,b);
				
				a = source.indexOf(_sorteo);
				if (a>-1) {
					b = source.indexOf(')</',a);
				}
				source = source.substring(b-2,b);
				if (parseInt(source) || source=="0" || source=="00") {
					Loteria.console.log("Premio dLoterry:",srt,"(",source,")");
					dispatchEventWith(Event.COMPLETE,false,source);
					isComplete();
				} else dl_retry();
			} else dl_retry();
		}
		
		public function dl_retry ():void {
			Loteria.console.log("Esperando dLoterry:",srt,"(",numBusq,")");
			stdLot=setTimeout(function ():void {
				++numBusq;
				dl_loader.load(dl_req);
			},_delay);	
		}
		
		override public function buscar(sorteo:String,fecha:Date=null):void {
			super.buscar(sorteo,fecha);
			
			_localFecha = DateFormat.format(fecha,"dd/mm/yyyy");
			_busq = DateFormat.format(fecha,"dd DE mmmm").toUpperCase();
			_sorteo = sorteo.substr(-8).split(" ").shift();
			
			localLog = File.applicationStorageDirectory.resolvePath("GRANRULETA/"+sorteo.split(":").join("_")+".txt");
			
			loader.load(web);
			dl_loader.load(dl_req);				
		}
		
		override protected function onComplete(event:Event):void {
			if (numBusq>60) return;
			var source:String = loader.data;			
			var fecha:int = source.indexOf(_busq);
			var sorteo:int = source.indexOf(_sorteo,fecha);
			fecha = source.indexOf(_busq,sorteo-30);
			if (fecha>-1 && sorteo>-1) {
				source = source.substring(fecha);
				source = source.substring(0,source.indexOf("GRUPO"));
				Console.saveTo(source,localLog);
				var pleno_start:int = source.indexOf("PLENO");
				var pleno:Array = String(source.split("\n")[2]).split(":");
				var npleno:String = ObjectUtil.extractAndTrail(pleno[1]);
				Loteria.console.log("Premio recibido",srt,"PLENO (",npleno,')');
				dispatchEventWith(Event.COMPLETE,false,npleno);
				isComplete();
			} else {
				retry();
			}
		}
		
		override public function dispose():void {
			super.dispose();
			
			clearTimeout(stdLot);
			dl_loader.removeEventListener(Event.COMPLETE,dl_complete);
			dl_loader=null;
			dl_req=null;
			dl_url=null;
		}
	}
}