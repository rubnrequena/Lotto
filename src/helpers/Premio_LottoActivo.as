package helpers
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
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
			ofic_req = new URLRequest('http://www.lottoactivo.com/');
			ofic_req.useCache=false;
			ofic_req.cacheResponse=false;
			
			super();
			
			numCompletado=2;
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
			ldh_loader.load(ldh_req);
			
			//lotto activo
			/*if (b>=1&&b<=7) _busqOfic = b+":00 PM";
			else if (b>=9&&b<=11) _busqOfic = b+":00 AM";
			else _busqOfic = b+":00 M";
			_busqOfic += " \n"+_localFecha;*/
			//findImage();
		}
		
		protected function oficial_complete(event:Event):void
		{
			if (numBusq++>90) return;
			var src:String = ofic_loader.data;
			if (src.indexOf(_fechaweb)>-1) {
				if (busq_ofic=="9:00") busq_ofic = "0"+busq_ofic;
				busq_ofic = 'alt="'+busq_ofic;
				var e:int = src.indexOf(busq_ofic);
				var a:int = src.indexOf("/",e-15);
				var b:int = src.indexOf("_",a);
				src = ObjectUtil.extractAndTrail(src.substring(a+1,b));
				if (src.length>3) {
					retryOfic();
				} else {
					if (parseInt(src) || src=="0" || src=="00") {
						Loteria.console.log("Premio WebOficial:",srt,"(",src,")");
						dispatchEventWith(Event.COMPLETE,false,src);
						isComplete();
					} else retryOfic();
				}
			} else retryOfic();
			
			function retryOfic():void {
				Loteria.console.log("Esperando WebOficial:",srt,"(",numBusq,")");
				stOfic=setTimeout(function ():void {
					ofic_loader.load(ofic_req);
				},_delay);
			}
		}
		
		private function findImage():void
		{
			lottoLoader = new URLLoader;
			var req:URLRequest = new URLRequest('https://twitter.com/lottoactivo');
			lottoLoader.addEventListener(Event.COMPLETE,onImageFound);
			lottoLoader.load(req);
		}
		private function onImageFound (e:Event):void {
			var source:String = lottoLoader.data;
			var sorteo:int = source.indexOf(busq_ofic);
			if (sorteo>-1) {
				var imgStart:int = source.indexOf('data-image-url="',sorteo);
				var imgEnd:int = source.indexOf('"',imgStart+16);
				compareImage(source.substring(imgStart+16,imgEnd));
			} else {
				Loteria.console.log("Esperando premiacion LottoActivo:",srt,"(",numBusq,")");
				stLotto= setTimeout(function ():void {
					findImage();
				},_delay);
			}
		}
		
		
		private static var images:Object;
		private function compareImage(url:String):void
		{
			if (images==null) {
				images = {};
				var folder:File = File.documentsDirectory.resolvePath("lotto");
				var lista:Array = folder.getDirectoryListing();
				var ncomplete:int; var numfiles:int = lista.length;
				for each (var f:File in folder.getDirectoryListing()) {
					loadImage(f.nativePath,loadComplete);
				}
			} else {
				loadImage(url,onLoadImage);
			}
			
			function loadComplete (b:Bitmap,name:String):void {
				ncomplete++;
				images[name] = b.bitmapData;
				if (ncomplete==numfiles) {
					//comparar
					loadImage(url,onLoadImage);
				}
			}	
			
			function onLoadImage (b:Bitmap,n:String):void{
				var b1:BitmapData = b.bitmapData;
				var b2:BitmapData;
				for (var i:String in images) {
					b2 = images[i];
					var compare:* = b1.compare(b2); 
					if (compare==0) {
						n = i.split(".").shift();
						Loteria.console.log("Premio LottoActivo encontrado:",srt,"(",n,")");
						dispatchEventWith(Event.COMPLETE,false,n);
						isComplete();
						return;
					}
				}
				//not match	
			}
			
		}
		
		private var imgLoader:Loader = new Loader;
		private var ofic_loader:URLLoader;
		private var ofic_req:URLRequest;
		private var _fechaweb:String;
		private var stOfic:uint;
		protected function loadImage (url:String,cb:Function):void {
			var req:URLRequest = new URLRequest(url);
			imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,function imgLoader_content (e:Event):void {
				cb.call(null,Bitmap(LoaderInfo(e.target).content),url.split("\\").pop());
			});
			imgLoader.load(req);
		}
		
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
			
			if (lottoLoader)
			lottoLoader.removeEventListener(Event.COMPLETE,onImageFound);
			
			if (ofic_loader)
			ofic_loader.removeEventListener(Event.COMPLETE,oficial_complete);
			ofic_loader=null;
			ofic_req=null;
			
			clearTimeout(stLotto);
			clearTimeout(stLDH);
			clearTimeout(stdLot);
			clearTimeout(stAzar);
			clearTimeout(stOfic);
		}
	}
}