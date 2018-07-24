package helpers
{
	import flash.events.Event;
	import flash.filesystem.File;

	public class Premio_MiniLottico extends PremioWeb implements IPremio
	{
		private var _fecha:String;
		private var localLog:File;
		private var reg1:RegExp = /[0-9]{1,2}-[A-Z]{4,6}/g;
		public function Premio_MiniLottico()
		{
			url = 'https://twitter.com/minilottoactivo';
			super();
		}
		
		override public function buscar(sorteo:String, fecha:Date=null):void {
			super.buscar(sorteo, fecha);
			_busq = sorteo.split(" ")[2].split(" ").shift();
			_fecha = DateFormat.format(fecha,"dd/mm/yyyy");
			
			localLog = File.applicationStorageDirectory.resolvePath("MINI/"+sorteo.split(":").join("_")+".txt");
			
			loader.load(web);
		}
		
		override protected function onComplete(event:Event):void
		{
			if (numBusq>60) return;
			var data:String = (loader.data as String);
			var e:Boolean=false;
			getTweets(data,function (data:*):Boolean {
				data = String(data).toUpperCase().split("\n");
				if (data[0].indexOf(_fecha)>-1) {
					if (data[1].indexOf(" "+_busq)>-1) {
						var a:String = data[2].match(reg1)[0];
						var n:String = ObjectUtil.extractAndTrail(a.split("-")[0]);
						dispatchEventWith(Event.COMPLETE,false,n);
						isComplete();
						e=true;
						return true;
					}
				}
				
			});
			if (e==false) retry();
		}
	}
}