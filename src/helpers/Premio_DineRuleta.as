package helpers
{
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import mx.utils.StringUtil;

	public class Premio_DineRuleta extends PremioWeb implements IPremio
	{
		public function Premio_DineRuleta()
		{
			url = 'https://twitter.com/dineruleta';
			super();
		}
		
		override public function buscar (sorteo:String,fecha:Date=null):void {
			super.buscar(sorteo,fecha);
			_busq = DateFormat.format(fecha,"dd-mm-yy")+" "+sorteo.split(" ").pop();
			loader.load(web);
		}
		
		override protected function onComplete(event:Event):void {
			if (numBusq>30) return;
			var source:String = loader.data;			
			var s:int = source.indexOf(_busq);
			if (s>-1) {
				var pleno_start:int = source.indexOf("PLENO",s);
				var pleno:Array = source.substr(pleno_start,10).split(":");
				var npleno:String = StringUtil.trim(pleno[1]);
				Loteria.console.log("Premio recibido:",srt,"PLENO",npleno);
				dispatchEventWith(Event.COMPLETE,false,npleno);
			} else {
				Loteria.console.log("Esperando premiacion:",srt,"(",numBusq,")");
				setTimeout(function ():void {
					numBusq++;
					Loteria.console.log("Buscando premios para",_busq);
					loader.load(web);
				},_delay);
			}
		}
	}
}