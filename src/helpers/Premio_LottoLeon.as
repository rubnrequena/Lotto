package helpers
{
	import flash.events.Event;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	public class Premio_LottoLeon extends PremioWeb implements IPremio
	{
		private var _fecha:String;

		private var source:Object;
		public function Premio_LottoLeon()
		{
			url = 'http://lottoleon.com/IndexServlet';			
			super();
			web.method = URLRequestMethod.POST;
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
		}
		
		override protected function onComplete(event:Event):void {
			if (numBusq>30) return;
			source = JSON.parse(String(loader.data));
			var a:Boolean=false; var x:int;
			for each (var sorteo:Object in source) {
				if (sorteo.hasOwnProperty("time") && sorteo.hasOwnProperty("number") &&_busq==sorteo.time) {
					a=true;
					var n:String = ObjectUtil.extractAndTrail(sorteo.number);
					Loteria.console.log("Premio LottoLeon encontrado:",srt,"(",n,")");
					dispatchEventWith(Event.COMPLETE,false,n);
					isComplete();
					return;
				}
			}
			if (a==false) retry();
		}
	}
}