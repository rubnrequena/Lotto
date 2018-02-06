package helpers
{
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import starling.utils.StringUtil;
	
	public class Premio_TuFrutaActiva extends PremioWeb
	{
		private var _sorteo:String;
		public function Premio_TuFrutaActiva()
		{
			url = 'https://twitter.com/tufrutactiva?lang=es';
			super();
		}
		
		override public function buscar(sorteo:String,fecha:Date=null):void {
			super.buscar(sorteo,fecha);
			srt = sorteo;
			_busq = DateFormat.format(fecha,"dd-mm-yyyy");
			_sorteo = sorteo.split(" ").slice(-2).join(" ");
			loader.load(web);
		}
		
		override protected function onComplete (event:Event):void {
			if (numBusq>10) return;
			
			var source:String = loader.data;
			var f:int = source.indexOf(_busq);
			var s:int = source.indexOf(_sorteo);
			f = source.indexOf(_busq,s-30);
			//trace("diff",f,s,f-s,_sorteo);
			if (f>-1 && s>-1) {
				var pleno_start:int = source.indexOf("Pleno",s);
				var num_start:int = source.indexOf(" ",pleno_start);
				var num_end:int = source.indexOf(" ",num_start+1);
				var npleno:String = StringUtil.trim(source.substring(num_start,num_end));
				Loteria.console.log("Premio recibido",srt,"PLENO",padding(npleno));
				dispatchEventWith(Event.COMPLETE,false,padding(npleno));
			} else {
				Loteria.console.log("Esperando premiacion:",srt,"(",numBusq,")");
				setTimeout(function ():void {
					numBusq++;
					loader.load(web);
				},_delay);
			}
		}
		
		private function padding (n:String):String {
			if (n!="0") return n.length==1?"0"+n:n;
			return n;
		}
	}
}