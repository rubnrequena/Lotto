package helpers
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import starling.utils.StringUtil;

	public class Premio_LottoActivo extends PremioWeb implements IPremio
	{
		private var loader_azar:URLLoader;
		private var req_azar:URLRequest;
		private var busq_azar:String;
		
		private var ldh_loader:URLLoader;
		private var ldh_req:URLRequest;
		private var ldh_busq:String;
		
		private var _fecha:String;
		
		private var _localFecha:String;
		
		private var busq_ofic:String;
		
		private var lottoLoader:URLLoader;
		
		private var stLotto:int, stAzar:int, stdLot:int, stLDH:int;
		
		public function Premio_LottoActivo()
		{
			super("lottoactivo");
			
			url = 'https://dlottery.wordpress.com/';
			
			loader_azar = new URLLoader;
			req_azar = new URLRequest('https://www.tuazar.com/loteria/lottoactivo/resultados/');
			req_azar.useCache=false;
			req_azar.cacheResponse=false;
			
			ldh_loader = new URLLoader;
			ldh_req = new URLRequest('http://www.loteriadehoy.com/animalitos/');
			ldh_req.useCache = false;
			ldh_req.cacheResponse = false;
			
			ofic_loader = new URLLoader;
			ofic_req = new URLRequest(configs.webofic.url);
			ofic_req.useCache=false;
			ofic_req.cacheResponse=false;
						
			numCompletado= configs.numCompletado;
		}
		
		override public function buscar (sorteo:String,fecha:Date=null):void {
			super.buscar(sorteo,fecha);
			
			_busq = sorteo.split(" ").pop();
			_fecha = DateFormat.format(fecha);
			_localFecha = DateFormat.format(fecha,"dd/mm/yyyy");
			
			_fechaweb = DateFormat.format(fecha,'dd mmm yyyy');
			
			var a:Array = _busq.split("");
			a.splice(-2,2);
			a.push(":00");
			busq_azar = a.join(""); 
			busq_ofic = busq_azar.toString(); 
			busq_azar = busq_azar.length==4?"0"+busq_azar:busq_azar;
			
			//web oficial
			ofic_loader.addEventListener(Event.COMPLETE,oficial_complete);
			var fv:URLVariables = new URLVariables;
			fv.fecha = _fechaweb;
			fv.hora = busq_ofic;
			fv.sorteo = "lottoactivo";
			ofic_req.data = fv;
			ofic_loader.load(ofic_req);
			
			//dlottery
			var b:int;
			b = busq_azar.split(":").shift();
			_busq = b<8?(b+12).toString():b.toString();
			_busq += ":00";
			//loader.load(web);
			
			//tuazar
			loader_azar.addEventListener(Event.COMPLETE,azar_complete);
			loader_azar.load(req_azar);
			
			//loteria de hoy
			ldh_busq = "Animalito "+b+":00";
			ldh_loader.addEventListener(Event.COMPLETE,ldh_complete);
			//ldh_loader.load(ldh_req);
			
		}
		
		protected function oficial_complete(event:Event):void
		{
			if (numBusq++>90) return;
			if (ofic_loader.data && ofic_loader.data!="") {
				var src:Object = JSON.parse(ofic_loader.data);
				//src.ganador = ObjectUtil.trailZero(src.ganador);
				Loteria.console.log("Premio WebOficial:",srt,"(",src.ganador,")");
				dispatchEventWith(Event.COMPLETE,false,src.ganador);
				isComplete();
			} else retryOfic();
			/*var rjpgs:RegExp = new RegExp('\\d{1,2}_d200.jpg','g');
			var sorteos:Array = ["9:00","10:00","11:00","12:00","1:00","3:00","4:00","5:00","6:00","7:00"];
			var a:int, b:int;
			if (src.indexOf(_fechaweb)>-1) {
				a = 0; b = src.length;
				for (var i:int = 0; i < 9; i++) {					
					var jpgs:Object = rjpgs.exec(src.substring(a,b));
					if (jpgs) {
						if (busq_ofic==sorteos[i]) {
							var n:String = String(jpgs[0]).split("_")[0];
							a = rjpgs.lastIndex;
							
							Loteria.console.log("Premio WebOficial:",srt,"(",n,")");
							dispatchEventWith(Event.COMPLETE,false,n);
							isComplete();
							return;
						}
					} else {
						retryOfic();
						break;
					}
					
				}
			} else retryOfic();*/
			
			function retryOfic():void {
				Loteria.console.log("Esperando WebOficial:",srt,"(",numBusq,")");
				stOfic=setTimeout(function ():void {
					ofic_loader.load(ofic_req);
				},_delay);
			}
		}
				
		private var ofic_loader:URLLoader;
		private var ofic_req:URLRequest;
		private var _fechaweb:String;
		private var stOfic:uint;
		
		
		protected function ldh_complete(event:Event):void
		{
			if (numBusq++>90) return;
			var source:String = ldh_loader.data;
			var a:int = source.indexOf('<span class="chart-topic text-green"> Lotto Activo </span>');
			var b:int = source.indexOf('<span class="chart-topic text-blue"> La Granjita </span>');
			source = source.substring(a,b);
				
			if (ldh_busq=='Animalito 9:00 AM') { //fix 9am
				if (source.indexOf("Por Salir")==-1) {
					Loteria.console.log("Esperando LoteriaDeHoy:",srt,"(",numBusq,")");
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
					Loteria.console.log("Premio LoteriaDeHoy:",srt,"(",n,")");
					dispatchEventWith(Event.COMPLETE,false,n);
					isComplete();
				} else {
					Loteria.console.log("Esperando LoteriaDeHoy:",srt,"(",numBusq,")");
					stLDH=setTimeout(function ():void {
						ldh_loader.load(ldh_req);
					},_delay);
				}
			} else {
				Loteria.console.log("Esperando LoteriaDeHoy:",srt,"(",numBusq,")");
				stLDH = setTimeout(function ():void {
					ldh_loader.load(ldh_req);
				},_delay);
			}
		}
		
		protected function azar_complete(event:Event):void
		{
			if (numBusq++>90) return;
			var source:String = loader_azar.data;
			//vefiricar dia de premio
			if (source.indexOf(_fecha)>-1) {
			
				var bfix:String = '<span>'+busq_azar+'</span>';
				
				var a:int = source.indexOf(' resultados">');
				var b:int = source.indexOf("<nav",a);
				a = source.indexOf("<div ",a-30);
				
				source = source.substring(a,b);
				
				a = source.indexOf(bfix);
				
				b = source.indexOf("<span>",a-120);
				a = source.indexOf("</span>",a);
				
				source = source.substring(b,a);
				
				var n:String = ObjectUtil.extractInt(StringUtil.trim(source.substr(6,2)));
				if (parseInt(n) || n=="0" || n=="00") {
					Loteria.console.log("Premio tuAzar encontrado:",srt,"(",n,")");
					dispatchEventWith(Event.COMPLETE,false,n);
					isComplete();
				} else {
					Loteria.console.log("Esperando tuAzar:",srt,"(",numBusq,")");
					stAzar= setTimeout(function ():void {
						loader_azar.load(req_azar);
					},_delay);
				}
			} else {
				Loteria.console.log("Esperando tuAzar:",srt,"(",numBusq,")");
				stAzar=setTimeout(function ():void {
					loader_azar.load(req_azar);
				},_delay);
			}
		}
		
		override protected function onComplete(event:Event):void {			
			if (numBusq++>90) return;
			var source:String = loader.data;			
			//vefiricar dia de premio
			var ts:int = source.indexOf(_localFecha);
			if (ts>-1) {
				var a:int = source.indexOf("Resultados Lotto Activo");
				var b:int = source.indexOf("</table>",a);
				source = source.substring(a,b);
				
				a = source.indexOf(_busq);
				if (a>-1) {
					b = source.indexOf(')</td>',a);
				}
				source = ObjectUtil.extractInt(source.substring(b-2,b));
				if (parseInt(source) || source=="0" || source=="00") {
					Loteria.console.log("Premio dLoterry:",srt,"(",source,")");
					dispatchEventWith(Event.COMPLETE,false,source);
					isComplete();
				} else {
					Loteria.console.log("Esperando dLoterry:",srt,"(",numBusq,")");
					stdLot=setTimeout(function ():void {
						loader.load(web);
					},_delay);
				}
			}
		}
		
		override public function dispose():void {
			super.dispose();
			ldh_loader.removeEventListener(Event.COMPLETE,ldh_complete);
			ldh_loader = null;
			ldh_req = null;
						
			loader_azar.removeEventListener(Event.COMPLETE,azar_complete);
			loader_azar = null;
			req_azar=null;			
						
			if (ofic_loader)
			ofic_loader.removeEventListener(Event.COMPLETE,oficial_complete);
			ofic_loader=null;
			ofic_req=null;
			
			clearTimeout(stLDH);
			clearTimeout(stdLot);
			clearTimeout(stAzar);
			clearTimeout(stOfic);
		}
	}
}