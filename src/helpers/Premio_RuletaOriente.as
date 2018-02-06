package helpers
{
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import starling.utils.StringUtil;

	public class Premio_RuletaOriente extends PremioWeb implements IPremio
	{
		private var _sorteo:String;
		
		public function Premio_RuletaOriente()
		{
			url = 'http://www.ruledactiva.com/';
			super();
		}
			
		override public function buscar(sorteo:String, fecha:Date=null):void {
			super.buscar(sorteo,fecha);
			_busq = DateFormat.format(fecha,"dd DE mmmm").toUpperCase();
			_sorteo = sorteo.substr(-8);
			_sorteo = StringUtil.trim(_sorteo).split(" ").shift();
			loader.load(web);
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