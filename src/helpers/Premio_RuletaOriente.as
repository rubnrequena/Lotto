package helpers
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.setTimeout;
	
	import starling.utils.StringUtil;

	public class Premio_RuletaOriente extends PremioWeb implements IPremio
	{
		private var _sorteo:String;
		private var tw_url:String;
		private var tw_loader:URLLoader;
		private var tw_req:URLRequest;
		private var tw_delay:uint;
		private var tw_busq:Array;
		private var tw_fecha:String;
		private var x:XML;
		private var r:Array;
		
		
		public function Premio_RuletaOriente()
		{
			url = 'http://www.ruledactiva.com/';
			tw_url = 'https://twitter.com/ruletactivave';
			super();
			
			tw_req = new URLRequest(tw_url);
			tw_req.cacheResponse=false;
			tw_req.useCache=false;
			
			tw_loader = new URLLoader;
			tw_loader.addEventListener(Event.COMPLETE,tw_onComplete);
			tw_loader.addEventListener(IOErrorEvent.IO_ERROR,tw_error);
			
		}
		
		protected function tw_error(event:IOErrorEvent):void
		{
			trace(event.type,event.text);
			tw_loader.load(tw_req);
		}
		
		override public function buscar(sorteo:String, fecha:Date=null):void {
			super.buscar(sorteo,fecha);
			_busq = DateFormat.format(fecha,"dd DE mmmm").toUpperCase();
			_sorteo = sorteo.substr(-8);
			_sorteo = StringUtil.trim(_sorteo).split(" ").shift();
			//loader.load(web);
			
			
			//twitter
			tw_fecha = DateFormat.format(fecha,"dd/mm/yyyy");
			var tw_sorteo:String = sorteo.substr(-8);
			tw_busq = [
				tw_sorteo,
				tw_sorteo.split(" ").join(""),
				tw_sorteo.substr(1),
				tw_sorteo.substr(1).split(" ").join("")
			];
			if (tw_sorteo=="12:00 PM") tw_busq = ["12:00 M","12:00M"]
			tw_loader.load(tw_req);
		}
		
		protected function tw_onComplete(event:Event):void
		{
			trace(event.type);
			var a:int,b:int,t:String;
			var source:String = tw_loader.data as String;
			
			for (var i:int = 0; i < 20; i++) {
				a = source.indexOf('<div class="js-tweet-text-container">',b);
				b = source.indexOf('</div>',a);
				t = source.substring(a,b+6);
				
				x = XML(t);
				t = x.p[0].text();
				if (t.indexOf("GRUPO")>-1) {
					r = t.split("\n");
					//validar horario
					var s:String = StringUtil.trim(r[2]);
					var a1:int = tw_busq.indexOf(s); 
					if (a1>-1) {
						s = ObjectUtil.extractAndTrail(r[3]);
						Loteria.console.log("Premio twitter recibido",srt,"PLENO",s);
						dispatchEventWith(Event.COMPLETE,false,s);
						isComplete();
					}
				}
			}
		}
		
		
		override protected function onComplete(event:Event):void {
			if (numBusq>30) return;
			var source:String = loader.data;
			source = source.substr(source.indexOf('<div id="result">'));
			var sorteo:int = source.indexOf(_sorteo);
			if (sorteo>-1) {				
				var ns:int = source.indexOf("images/sorteos/",sorteo-200);
				source = source.substr(ns,sorteo);
				source = source.substr(0,33);
				
				var npleno:String = ObjectUtil.extractAndTrail(source);
				Loteria.console.log("Premio recibido",srt,"PLENO",npleno);
				dispatchEventWith(Event.COMPLETE,false,npleno);
				isComplete();
			} else {
				Loteria.console.log("Esperando premiacion:",srt,"(",numBusq,")");
				setTimeout(function ():void {
					numBusq++;
					loader.load(web);
				},_delay);
			}
		}
	}
}