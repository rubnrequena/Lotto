package helpers
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import helpers.pools.LoaderPool;
	
	import starling.utils.execute;

	public class SMS
	{	
		
		private static var smsURI:String = "http://srq-hermes.herokuapp.com/sms/";
		
		public static var ADMIN_CONTACTS:Array;
		
		public static function init():void {
			ADMIN_CONTACTS = Loteria.setting.plataformas.sms.admins;
		}
		
		public static function sendMulti (number:Array,msg:String,cb:Function=null):Boolean {
			var len:Number=number.length;
			var res:int; var resData:Array = [];
			var cursor:int;
			
			send(number[cursor++],msg,sendResult);
			function sendResult (data:*):void {
				if (len==++res) if (cb!=null) execute(cb,resData); 
				else {
					resData.push(data);
					send(number[cursor++],msg,sendResult);
				}
			}
			return Loteria.setting.plataformas.sms.activa;
		}
		
		public static function send (number:String,msg:String,cb:Function=null):Boolean {
			if (Loteria.setting.plataformas.sms.activa==1) {
				var l:URLLoader = LoaderPool.getItem();
				var r:URLRequest = new URLRequest(smsURI); //pool
				r.method = URLRequestMethod.POST;
				var v:URLVariables = new URLVariables; //pool
				v.num = number;
				v.txt = msg;
				
				r.data = v;
				
				l.addEventListener(Event.COMPLETE,sms_complete);
				l.load(r);
				
				function sms_complete (e:Event):void {
					l.removeEventListener(Event.COMPLETE,sms_complete);
					LoaderPool.dispose(l);
					if (cb!=null) execute(cb,l.data);
				};
			}
			return Loteria.setting.plataformas.sms.activa;
		}
		
		public function SMS()
		{
			
			
			
		}
	}
}