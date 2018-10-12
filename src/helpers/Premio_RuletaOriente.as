package helpers
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
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
			
			super("ruletaoriente");
			
			/*tw_req = new URLRequest(tw_url);
			tw_req.cacheResponse=false;
			tw_req.useCache=false;
			
			tw_loader = new URLLoader;
			tw_loader.addEventListener(Event.COMPLETE,tw_onComplete);
			tw_loader.addEventListener(IOErrorEvent.IO_ERROR,tw_error);
			*/
		}
		
		protected function tw_error(event:IOErrorEvent):void
		{
			tw_loader.load(tw_req);
		}
		
		override public function buscar(sorteo:String, fecha:Date=null):void {
			super.buscar(sorteo,fecha);
			_busq = DateFormat.format(fecha,"dd DE mmmm").toUpperCase();
			
			_sorteo = sorteo.substr(-8).toLowerCase();
			var a:Array = _sorteo.split(":");
			a[0] = int(a[0]);
			_sorteo = a.join(":");	
			//_sorteo = StringUtil.trim(_sorteo).split(" ").join(" ").toLowerCase();
			
			var fv:URLVariables = new URLVariables;
			fv.fecha = _busq.toLowerCase();
			fv.hora = _sorteo.toLocaleLowerCase();
			fv.sorteo = "ruletaoriente";
			
			web.data = fv;
			loader.load(web);
			
			//dlotery
			//dl_load.load(dl_req);			
			
			//twitter
			/*tw_fecha = DateFormat.format(fecha,"dd\/mm\/yyyy");
			var tw_sorteo:String = sorteo.substr(-8);
			tw_busq = [
				tw_sorteo,
				tw_sorteo.split(" ").join(""),
				tw_sorteo.substr(1),
				tw_sorteo.substr(1).split(" ").join("")
			];
			if (tw_sorteo=="12:00 PM") tw_busq = ["12:00 M","12:00M","12:00 DM","12:00DM"]
			tw_loader.load(tw_req);*/
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
		
		protected function tw_onComplete(event:Event):void
		{
			if (numBusq>90) return;
			var a:int,b:int,t:String;
			var source:String = tw_loader.data as String;
			var e:Boolean=false;
			var reg:RegExp = /[0-9]/;
			var freg:RegExp = new RegExp(tw_fecha+"|"+_busq,"gi");
			var hreg:RegExp = /[0-1][0-9]:00|[0-9]:00/;
			var nreg:RegExp = /[a-zA-ZáéíóúÁÉÍÓÚñÑ]{3,} \d{1,2}\n|\d{1,2} {0,2} [a-zA-ZáéíóúÁÉÍÓÚñÑ]{3,}/;
			
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
		
		
		protected function onComplete_web(event:Event):void {
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
		
		/*override public function dispose():void {
			super.dispose();
			
			tw_req = null;
			tw_loader=null;
			
			clearTimeout(stTw);
		}*/
	}
}