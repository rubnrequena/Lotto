package helpers
{
	import flash.events.Event;

	public class Premio_RuletAnimal extends PremioWeb implements IPremio
	{
		private var _fecha:String;
		private var r1:RegExp = /[0-9]/;
		private var r2:RegExp = /[0-9]{2}/g;
		public function Premio_RuletAnimal()
		{
			url = 'https://twitter.com/Ruletanimal';
			super();
		}
		
		override public function buscar(sorteo:String, fecha:Date=null):void
		{
			super.buscar(sorteo, fecha);
			_busq = sorteo.split(" ").pop();
			_fecha = DateFormat.format(fecha,"dd/mm/yy");
			loader.load(web);
		}
		
		override protected function onComplete(event:Event):void
		{
			if (numBusq>60) return;
			var data:String = (loader.data as String);
			var e:Boolean=false;
			getTweets(data,function (data:*):Boolean {
				data = data.split("\n");
				var ss:String = data[0];
				ss = ss.substr(ss.search(r1));
				ss = ss.substring(0,ss.indexOf("m")+1).toUpperCase();
				var sorteo:int = data.indexOf("sorteo "+_busq);
				var fecha:int = data.indexOf(_fecha,sorteo);
				var fs:int = sorteo-fecha;
				if (ss==_busq && fs<30) {
					ss = data[2].match(r2)[0];
					trace("nnn",data);
					Loteria.console.log("Premio recibido",srt+" "+_fecha,"PLENO",ss);
					dispatchEventWith(Event.COMPLETE,false,data);
					isComplete();
					e=true;
					return true;
				}
			});
			if (e==false) retry();
		}	
	}
}