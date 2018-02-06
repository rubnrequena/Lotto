package helpers
{
	import flash.events.Event;
	import flash.utils.setTimeout;
	
	import mx.utils.StringUtil;

	public class Premio_FrutaActiva extends PremioWeb implements IPremio
	{
		public function Premio_FrutaActiva()
		{
			url = "https://twitter.com/frutactivaofic";
			super();
		}
		
		override public function buscar (sorteo:String,fecha:Date=null):void {
			super.buscar(sorteo,fecha);
			_busq = DateFormat.format(fecha,"dd/mm/yy")+" "+sorteo.split(" ").pop();
			loader.load(web);
		}
		
		override protected function onComplete(event:Event):void {
			if (numBusq++>60) return;
			var source:String = loader.data;			
			var s:int = source.indexOf(_busq);
			var pleno_start:int = source.indexOf("PLENO",s);
			if (s>-1 && pleno_start>-1 && pleno_start-s<30) {
				var pleno:Array = source.substr(pleno_start,10).split(":");
				var npleno:String = StringUtil.trim(pleno[1]);
				Loteria.console.log("Premio recibido:",srt,"PLENO",npleno);
				dispatchEventWith(Event.COMPLETE,false,npleno);	
			} else {
				Loteria.console.log("Esperando premiacion:",srt,"(",numBusq,")");
				setTimeout(function ():void {
					loader.load(web);
				},_delay);
			}
		}
		
	}
}