package helpers
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import helpers.pools.LoaderPool;
	
	import starling.utils.StringUtil;
	import starling.utils.execute;

	public class SMS
	{	
		
		private static var smsURI:String;
		public static var activo:Boolean;
		
		public static var ADMIN_CONTACTS:Array;
		private static var defKey:Object;
		
		public static function init():void {
			smsURI = Loteria.setting.plataformas.sms.uri;	
			ADMIN_CONTACTS = Loteria.setting.plataformas.sms.admins;
			activo = Loteria.setting.plataformas.sms.activa;
			defKey = Loteria.setting.plataformas.sms.key;
		}
		
		public static function sendMulti (number:Array,msg:String,cb:Function=null,key:String=null):Boolean {
			var len:Number=number.length;
			var res:int; var resData:Array = [];
			var cursor:int;
			
			for (var i:int = 0; i < number.length; i++) {
				send(number[i],msg,sendResult);
			}
			
			function sendResult (data:*):void {
				if (i==len) {				
					if (cb!=null) execute(cb,resData);
				} else resData.push(data);
			}
			return Loteria.setting.plataformas.sms.activa;
		}
		
		public static function send (number:String,msg:String,cb:Function=null,key:String=null):Boolean {
			if (activo) {
				var l:URLLoader = LoaderPool.getItem();
				var r:URLRequest = new URLRequest(StringUtil.format(smsURI,key||defKey)); //pool
				r.method = URLRequestMethod.GET;
				var v:URLVariables = new URLVariables; //pool
				v.num = number;
				v.txt = msg;				
				r.data = v;				
				l.addEventListener(Event.COMPLETE,sms_complete);
				l.addEventListener(IOErrorEvent.IO_ERROR,onError);
				l.load(r);
				
				function sms_complete (e:Event):void {
					l.removeEventListener(Event.COMPLETE,sms_complete);
					l.removeEventListener(IOErrorEvent.IO_ERROR,onError);
					LoaderPool.dispose(l);
					if (cb!=null) execute(cb,null,JSON.parse(l.data));
				};
				function onError (e:IOErrorEvent):void {
					Loteria.console.log("ERROR al conectar con ",r.url,JSON.stringify(r.data));	
					l.removeEventListener(Event.COMPLETE,sms_complete);
					l.removeEventListener(IOErrorEvent.IO_ERROR,onError);
					//if (cb!=null) execute(cb,JSON.parse(l.data));
				};
			}
			return Loteria.setting.plataformas.sms.activa;
		}
		
		public function SMS()
		{
			
			
			
		}
	}
}