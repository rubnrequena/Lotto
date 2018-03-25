package helpers
{
	import flash.events.Event;
	import flash.filesystem.File;

	public class Premio_RuletAnimal extends PremioWeb implements IPremio
	{
		private var _fecha:String;
		private var r1:RegExp = /[0-9]/;
		private var r2:RegExp = /[0-9]{2}|[0-9]{1}/g;
		private var localLog:File;
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
			
			localLog = File.applicationStorageDirectory.resolvePath("RULETANIMAL/"+sorteo.split(":").join("_")+".txt");
			
			loader.load(web);
		}
		
		override protected function onComplete(event:Event):void
		{
			if (numBusq>60) return;
			var data:String = (loader.data as String);
			var e:Boolean=false;
			getTweets(data,function (data:*):Boolean {
				data = String(data).toUpperCase().split("\n");
				var ss:String = data[0];
				ss = ss.substr(ss.search(r1));
				ss = ss.substring(0,ss.indexOf("M")+1);
				var sorteo:int = data[0].indexOf("SORTEO "+ss);
				var fecha:int = data[1].indexOf(_fecha,sorteo);
				
				if (ss==_busq && (sorteo>-1 && fecha>-1)) {
					Console.saveTo(data,localLog);
					ss = data[2].match(r2)[0];
					Loteria.console.log("Premio recibido",srt+" "+_fecha,"PLENO",ss);
					dispatchEventWith(Event.COMPLETE,false,ss);
					isComplete();
					e=true;
					return true;
				}
			});
			if (e==false) retry();
		}	
	}
}