package helpers
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.clearTimeout;
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
		private var dl_load:URLLoader;
		private var dl_url:String;
		private var dl_req:URLRequest;
		private var stTw:uint;
		
		
		public function Premio_RuletaOriente()
		{
			url = 'http://www.ruletactiva.com.ve/';
			tw_url = 'https://twitter.com/ruletactivave';
			dl_url = 'https://www.dlottery.net.ve/';
			super();
			
			tw_req = new URLRequest(tw_url);
			tw_req.cacheResponse=false;
			tw_req.useCache=false;
			
			tw_loader = new URLLoader;
			tw_loader.addEventListener(Event.COMPLETE,tw_onComplete);
			tw_loader.addEventListener(IOErrorEvent.IO_ERROR,tw_error);
			
			dl_req = new URLRequest(dl_url);
			dl_load = new URLLoader;
			dl_load.addEventListener(Event.COMPLETE,dl_onComplete);
		}
		
		protected function dl_onComplete(event:Event):void
		{
			var src:String = dl_load.data;
			src = getDlotery(src,"ruletactiva","9:00");
		}
		
		protected function tw_error(event:IOErrorEvent):void
		{
			tw_loader.load(tw_req);
		}
		
		override public function buscar(sorteo:String, fecha:Date=null):void {
			super.buscar(sorteo,fecha);
			_busq = DateFormat.format(fecha,"dd DE mmmm").toUpperCase();
			
			_sorteo = sorteo.substr(-8);
			_sorteo = StringUtil.trim(_sorteo).split(" ").shift();
			loader.load(web);
			
			//dlotery
			//dl_load.load(dl_req);			
			
			//twitter
			tw_fecha = DateFormat.format(fecha,"dd\/mm\/yyyy");
			var tw_sorteo:String = sorteo.substr(-8);
			tw_busq = [
				tw_sorteo,
				tw_sorteo.split(" ").join(""),
				tw_sorteo.substr(1),
				tw_sorteo.substr(1).split(" ").join("")
			];
			if (tw_sorteo=="12:00 PM") tw_busq = ["12:00 M","12:00M","12:00 DM","12:00DM"]
			tw_loader.load(tw_req);
		}
		
		protected function tw_onComplete(event:Event):void
		{
			if (numBusq>90) return;
			var a:int,b:int,t:String;
			var source:String = tw_loader.data as String;
			var e:Boolean=false;
			var reg:RegExp = /[0-9]/;
			var freg:RegExp = new RegExp(tw_fecha+"|"+_busq,"gi");
			var hreg:RegExp = /[0-1][0-9]:00|[0-9]:00/;
			var nreg:RegExp = /[a-zA-ZáéíóúÁÉÍÓÚñÑ]{3,} \d{1,2}\n|\d{1,2}\s{0,2} [a-zA-ZáéíóúÁÉÍÓÚñÑ]{3,}/;
			
			for (var i:int = 0; i < 20; i++) {
				a = source.indexOf('<div class="js-tweet-text-container">',b);
				b = source.indexOf('</div>',a);
				t = source.substring(a,b+6).toUpperCase();
				var y:int = t.search(/GRUPO|NEGRO|ROJO|VERDE/g); 
				if (y>-1) {					
					//validar fecha
					if (t.search(freg)>-1) {
						//validar horario
						var a1:* = hreg.exec(t);
						//var ss:String = t.substr(a1.index,a1[0].length);
						//ss = ss.length==4?"0"+ss:ss;
						if (_sorteo.indexOf(a1[0])>-1) {
							e=true;
							a1 = nreg.exec(t);
							var s:String = ObjectUtil.extractAndTrail(a1[0]);
							Loteria.console.log("Premio twitter recibido",srt,"PLENO",s);
							dispatchEventWith(Event.COMPLETE,false,s);
							isComplete();
						}
					}
				}
			}
			if (!e) {
				stTw = setTimeout(function ():void {
					numBusq++;
					tw_loader.load(tw_req);
				},_delay);
			}
		}
		
		
		override protected function onComplete(event:Event):void {
			if (numBusq>90) return;
			var source:String = loader.data;
			source = source.substr(source.indexOf('<div id="result">'));
			var sorteo:int = source.indexOf(_sorteo);
			if (sorteo>-1) {				
				var ns:int = source.indexOf("images/sorteos/",sorteo-200);
				source = source.substr(ns,sorteo);
				source = source.substr(0,33);
									
				var npleno:String = ObjectUtil.extractAndTrail(source);
				Loteria.console.log("Premio webOfic recibido",srt,"PLENO",npleno);
				dispatchEventWith(Event.COMPLETE,false,npleno);
				isComplete();
			} else {
				Loteria.console.log("Esperando premiacion:",srt,"(",numBusq,")");
				stTw = setTimeout(function ():void {
					numBusq++;
					loader.load(web);
				},_delay);
			}
		}
		
		override public function dispose():void {
			super.dispose();
			tw_loader.removeEventListener(Event.COMPLETE,tw_onComplete);
			tw_loader.removeEventListener(IOErrorEvent.IO_ERROR,tw_error);
			
			tw_req = null;
			tw_loader=null;
			
			clearTimeout(stTw);
		}
	}
}