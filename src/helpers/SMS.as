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
		
		private static var devices:Vector.<int>;
		
		public static function init():void {
			devices = new Vector.<int>;
			load('https://smsgateway.me/api/v3/devices',null,URLRequestMethod.GET,initSMS_result);
			
			function initSMS_result (result:Object):void {
				for each (var dev:Object in result.result.data) {
					devices.push(int(dev.id));
				}
				Loteria.console.log("DISPOSITIVOS SMS REGISTRADOS: ",devices.length);
			}
		}
		
		private static function load (url:String,params:Object,method:String="POST",cb:Function=null):void {
			var l:URLLoader = LoaderPool.getItem();
			var r:URLRequest = new URLRequest(url); //pool
			r.method = URLRequestMethod.POST;
			var v:URLVariables = new URLVariables; //pool
			v.email = "rubnrequena@gmail.com";
			v.password = "srqsms";
			
			for (var s:String in params) {
				v[s] = params[s];
			}			
			r.data = v;
			
			l.addEventListener(Event.COMPLETE,sms_complete);
			l.load(r);
			
			function sms_complete (e:Event):void {
				l.removeEventListener(Event.COMPLETE,sms_complete);
				LoaderPool.dispose(l);
				if (cb!=null) execute(cb,JSON.parse(l.data));
			};
		}
		
		public static function send (number:String,msg:String,cb:Function=null):Boolean {
			if (Loteria.setting.plataformas.sms.activa==1) {
				var l:URLLoader = LoaderPool.getItem();
				var r:URLRequest = new URLRequest('https://smsgateway.me/api/v3/messages/send'); //pool
				r.method = URLRequestMethod.POST;
				var v:URLVariables = new URLVariables; //pool
				v.email = "rubnrequena@gmail.com";
				v.password = "srqsms";
				v.number = number;
				v.message = msg;
				v.device = devices[devices.length-1];
				
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