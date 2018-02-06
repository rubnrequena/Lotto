package vos.sistema
{
	public class VOMonitor
	{
		public var ms_max:int;
		public var ms_min:int;
		public var accion_contador:Object;
		
		private var accval:String;
		private var cnt:Number;
		
		private var _ms_last:int;
		private var _ms_last_desc:String;
		

		public function get ms_last_desc():String { return _ms_last_desc; }
		public function set ms_last_desc(value:String):void {
			_ms_last_desc = value;
			accval = value.split(" ").shift()
			cnt = accion_contador[accval]; 
			if (cnt) accion_contador[accval] = ++cnt;
			else accion_contador[accval] = 1;
		}


		public function get ms_last():int { return _ms_last; }
		public function set ms_last(value:int):void {
			_ms_last = value;
			if (value>ms_max) ms_max = value;
			if (value<ms_min) ms_min = value;
		}

		
		public function VOMonitor() {
			accion_contador = {};
		}
	}
}