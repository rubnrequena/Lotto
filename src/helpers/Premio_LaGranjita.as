package helpers
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	public class Premio_LaGranjita extends PremioWeb implements IPremio
	{
		private static const ANIMALES:Array = ["BALLENA","DELFIN","CARNERO","TORO","CIEMPIES","ALACRAN","LEON","RANA","PERICO","RATON","AGUILA","TIGRE","GATO","CABALLO",
			"MONO","PALOMA","ZORRO","OSO","PAVO","BURRO","CHIVO","COCHINO","GALLO","CAMELLO","CEBRA","IGUANA","GALLINA","VACA","PERRO","ZAMURO","ELEFANTE","CAIMAN",
		"LAPA","ARDILLA","PESCADO","VENADO","JIRAFA","CULEBRA"];
		private static const NUMEROS:Array = ["00","0","01","02","03","04","05","06","07","08","09","10","11","12","13","14","15","16","17","18","19","20","21",
			"22","23","24","25","26","27","28","29","30","31","32","33","34","35","36"];
		
		private var _fecha:String;
		
		private var stAzar:uint;
		private var azar_loader:URLLoader;
		private var azar_busq:String;
		private var azar_req:URLRequest;
		private var azar_fecha:String;
		
		private var loader_alt:URLLoader;
		private var stAlt:uint;
		private var ldh_loader:URLLoader;
		private var ldh_req:URLRequest;
		private var ldh_busq:String;
		private var stLDH:uint;
		
		public function Premio_LaGranjita()
		{
			url = 'https://twitter.com/lagranjitaofic';
			
			loader_alt = new URLLoader();
			loader_alt.addEventListener(Event.COMPLETE,premioAlt_complete);
			loader_alt.dataFormat = URLLoaderDataFormat.TEXT;			
			
			
			azar_loader = new URLLoader();
			azar_loader.addEventListener(Event.COMPLETE,azar_complete);
			azar_req = new URLRequest('https://www.tuazar.com/loteria/lagranjita/resultados/');
			azar_req.useCache=false;
			azar_req.cacheResponse=false;
			
			ldh_loader = new URLLoader();
			ldh_loader.addEventListener(Event.COMPLETE,ldh_complete);
			ldh_req = new URLRequest('http://www.loteriadehoy.com/animalitos/');
			ldh_req.useCache=false;
			ldh_req.cacheResponse=false;
			
			super();
			numCompletado=2;
		}
		
		protected function ldh_complete(event:Event):void
		{
			if (numBusq++>60) return;
			var source:String = ldh_loader.data;
			var a:int = source.indexOf('<span class="chart-title text-blue"> La Granjita </span>');
			var b:int = source.indexOf('<span class="chart-title text-azul"> Lotto Leon </span>');
			source = source.substring(a,b);
			
			if (ldh_busq=='Granjita 9:00 AM') { //fix 9am
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
		
		override public function buscar(sorteo:String, fecha:Date=null):void
		{
			super.buscar(sorteo, fecha);
			_busq = sorteo.split(" ").slice(-2).join(" ");
			if (_busq.split(":").shift()<10) _busq = "0"+_busq;
			_fecha = DateFormat.format(fecha,"dd DE mmmm").toUpperCase();
					
			//twitter
			//loader.load(web);			
			loader_alt.load(web);			
			
			//tuazar
			azar_fecha = DateFormat.format(fecha);
			azar_busq = _busq.split(" ")[0];
			azar_loader.load(azar_req);
			
			//ldh
			if (_busq.substr(0,1)=="0") ldh_busq = 'Granjita '+_busq.substr(1);
			else ldh_busq = 'Granjita '+_busq;
			ldh_loader.load(ldh_req);
		}
		
		override protected function onComplete(event:Event):void {
			if (numBusq++>60) return;
			var source:String = (loader.data as String);
			var sorteo:int = source.indexOf("\n"+_busq);
			source = source.substr(sorteo-40,100).toUpperCase();
			var a:int = source.indexOf("<");
			var fecha:int = source.indexOf(_fecha);
			source = source.substring(fecha,a);
			if (fecha>-1) {
				var data:Array = source.split("\n");
				source = data[3].split(" ");
				var n:String = ObjectUtil.extractAndTrail(source);
				if (n.length==0) {
					n = NUMEROS[ANIMALES.indexOf(removerAcentuacao(source))]
				}
				Loteria.console.log("Premio recibido principal",srt,"PLENO",n);
				dispatchEventWith(Event.COMPLETE,false,n);
				isComplete();
			} else retry();
		}
		private function premioAlt_complete (event:Event):void {
			var s:String = _busq.split(" ").join("").toLowerCase();
			
			Loteria.console.log("Buscando premio alternativo para",srt);
			if (numBusq++>60) return;
			var source:String = (loader_alt.data as String);
			source = source.substr(source.indexOf('<div id="timeline"'));
			var sorteo:int = source.indexOf(s);
			source = source.substr(sorteo-40,100).toUpperCase();
			var a:int = source.indexOf("\n<");
			var fecha:int = source.indexOf(_fecha);
			source = source.substring(fecha,a);
			if (fecha>-1) {
				source = source.substr(source.indexOf(s.toUpperCase()));
				var data:Array = source.split(" ");
				var n:String = NUMEROS[ANIMALES.indexOf(removerAcentuacao(data[1]))];
				Loteria.console.log("Premio alternativo encontrado",srt," (",n,')');
				dispatchEventWith(Event.COMPLETE,false,n);
				isComplete();
			} else {
				stAlt = setTimeout(function ():void {
					loader_alt.load(web);
				},_delay);
			}
		}
		
		private function removerAcentuacao(texto:String):String{
			var letrasSubstitutas:Array = new Array("A", "E", "I","O", "U", "Ç");
			var padraoDeSubstituicao:Array = new Array();
			
			padraoDeSubstituicao[0] = new RegExp("[ÁÀÃÂÄ]", "g");
			padraoDeSubstituicao[1] = new RegExp("[ÉÈÊË]", "g");
			padraoDeSubstituicao[2] = new RegExp("[ÍÌÏÎ]", "g");
			padraoDeSubstituicao[3] = new RegExp("[ÓÒÕÔÜ]", "g");
			padraoDeSubstituicao[4] = new RegExp("[ÚÙÜÛ]", "g");
			padraoDeSubstituicao[5] = new RegExp("Ç", "g");
			
			for(var i:Number = 0;i<padraoDeSubstituicao.length; i++){
				texto = texto.replace(padraoDeSubstituicao[i], 
					letrasSubstitutas[i]);
			}
			
			return texto;
		}
		
		//TUAZAR
		protected function azar_complete(event:Event):void
		{
			if (numBusq++>60) return;
			var source:String = azar_loader.data;
			//vefiricar dia de premio
			if (source.indexOf(azar_fecha)>-1) {
				
				var bfix:String = '<span>'+azar_busq+'</span>';
				
				var a:int = source.indexOf(' resultados">');
				var b:int = source.indexOf("<nav",a);
				a = source.indexOf("<div ",a-30);
				
				source = source.substring(a,b);
				
				a = source.indexOf(bfix);
				
				b = source.indexOf("<span>",a-120);
				a = source.indexOf("</span>",a);
				
				source = source.substring(b,a);
				
				var n:String = ObjectUtil.extractAndTrail(source.substr(6,2));
				if (parseInt(n) || n=="0" || n=="00") {
					Loteria.console.log("Premio tuAzar encontrado:",srt,"(",n,")");
					dispatchEventWith(Event.COMPLETE,false,n);
					isComplete();
				} else {
					Loteria.console.log("Esperando premiacion tuAzar:",srt,"(",numBusq,")");
					stAzar= setTimeout(function ():void {
						azar_loader.load(azar_req);
					},_delay);
				}
			} else {
				Loteria.console.log("Esperando premiacion tuAzar:",srt,"(",numBusq,")");
				stAzar=setTimeout(function ():void {
					azar_loader.load(azar_req);
				},_delay);
			}
		}
		
		override public function dispose():void {
			super.dispose();
			clearTimeout(stAzar);
			clearTimeout(stAlt);
			clearTimeout(stLDH);
			
			loader_alt.removeEventListener(Event.COMPLETE,premioAlt_complete);
			loader_alt = null;
			
			ldh_loader.removeEventListener(Event.COMPLETE,ldh_complete);
			ldh_loader = null;
			ldh_req=null;
			
			azar_loader.removeEventListener(Event.COMPLETE,azar_complete);
			azar_req=null;
			azar_loader=null;
		}
	}
}