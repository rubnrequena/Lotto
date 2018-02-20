package helpers
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	public class Premio_LottoLeon extends PremioWeb implements IPremio
	{
		private var _fecha:String;

		private var source:Object;
		private var ldh_loader:URLLoader;
		private var ldh_req:URLRequest;
		private var ldh_busq:String;
		private var stLDH:uint;
		public function Premio_LottoLeon()
		{
			url = 'http://lottoleon.com/IndexServlet';			
			super();
			web.method = URLRequestMethod.POST;
			
			ldh_loader = new URLLoader();
			ldh_loader.addEventListener(Event.COMPLETE,ldh_complete);
			ldh_req = new URLRequest('http://www.loteriadehoy.com/animalitos/');
			ldh_req.useCache=false;
			ldh_req.cacheResponse=false;
		}
		
		protected function ldh_complete(event:Event):void
		{
			if (numBusq++>60) return;
			var source:String = ldh_loader.data;
			var a:int = source.indexOf('<span class="chart-title text-azul"> Lotto Leon </span>'), b:int;
			source = source.substring(a).toLowerCase();
			
			if (ldh_busq=='LOTTOLEON 10:15 AM') { //fix 9am
				if (source.indexOf("Por Salir")==-1) {
					Loteria.console.log("Esperando premiacion LoteriaDeHoy:",srt,"(",numBusq,")");
					stLDH = setTimeout(function ():void {
						ldh_loader.load(ldh_req);
					},_delay);
					return;
				}
			}
			
			a = source.indexOf(ldh_busq);
			if (a>-1) {
				source = source.substring(a-600,a);
				b = source.indexOf('</span>');
				source = source.substring(b-2,b);
				var n:String = ObjectUtil.extractAndTrail(source);
				if (parseInt(n) || n=="0" || n=="00") {
					Loteria.console.log("Premio LoteriaDeHoy encontrado:",srt,"(",n,")");
					dispatchEventWith(Event.COMPLETE,false,n);
					isComplete();
				} else {
					Loteria.console.log("Esperando premiacion LoteriaDeHoy:",srt,"(",numBusq,")");
					stLDH=setTimeout(function ():void {
						ldh_loader.load(ldh_req);
					},_delay);
				}
			} else {
				Loteria.console.log("Esperando premiacion LoteriaDeHoy:",srt,"(",numBusq,")");
				stLDH = setTimeout(function ():void {
					ldh_loader.load(ldh_req);
				},_delay);
			}
		}
		
		override public function buscar(sorteo:String, fecha:Date=null):void {
			super.buscar(sorteo, fecha);
			_busq = sorteo.split(" ").slice(-2).join(" ").toLowerCase();
			_fecha = DateFormat.format(fecha,"dd-mm-yyyy");
			
			var data:URLVariables = new URLVariables;
			data.opt = "consultResult";
			data.datesearch = _fecha;
			web.data = data;
			
			loader.load(web);
			
			//ldh
			if (_busq=="12:15 am") ldh_busq = 'lottoleon 12:15 pm';
			else ldh_busq = 'lottoleon '+_busq; 
			ldh_loader.load(ldh_req);
		}
		
		override protected function onComplete(event:Event):void {
			if (numBusq>30) return;
			source = JSON.parse(String(loader.data));
			var a:Boolean=false; var x:int;
			for each (var sorteo:Object in source) {
				if (sorteo.hasOwnProperty("time") && sorteo.hasOwnProperty("number") &&_busq==sorteo.time) {
					a=true;
					var n:String = ObjectUtil.extractAndTrail(sorteo.number);
					if (n=="0") n = "00";
					else if (n=="00") n = "0";
					Loteria.console.log("Premio LottoLeon encontrado:",srt,"(",n,")");
					dispatchEventWith(Event.COMPLETE,false,n);
					isComplete();
					return;
				}
			}
			if (a==false) retry();
		}
		
		override public function dispose():void {
			super.dispose();
			clearTimeout(stLDH);
			ldh_loader.removeEventListener(Event.COMPLETE,ldh_complete);
			ldh_loader = null;
			ldh_req=null;
		}
	}
}