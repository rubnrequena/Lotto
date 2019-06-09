package helpers
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import starling.utils.StringUtil;

	public class WS
	{
		public static const NTF_TQ_SORTEO_INV:String = "[{3}] VERIFICAR RESULTADO\nSORTEO: {0}\nTAQ: {1}\nUSUARIO: {2}";
		
		private static var process:NativeProcess;
		
		private static var url:URLLoader;
		private static var req:URLRequest;
		private static var reqData:URLVariables;
		private static var queue:Array=[];
		private static var cmsg:Object;
		private static var ocupado:Boolean;
		public static var preferencias:Object;
		public static var usuarios:Object;
		
		public function WS()
		{
			
		}
		
		public static function init ():void {
			initWeb();
			preferencias = Loteria.setting.plataformas.ws;
			usuarios = Loteria.setting.plataformas.usuarios;
		}
		
		private static function initWeb():void {
			url = new URLLoader;
			url.addEventListener(Event.COMPLETE,onComplete);
			url.addEventListener(IOErrorEvent.IO_ERROR,onError);
		}
		
		protected static function onError(event:IOErrorEvent):void {
			//Loteria.console("WS Error: ",event.text);
		}		
		protected static function onComplete(event:Event):void {
			//Loteria.console("WS: enviado");
		}

		public static function enviar (numero:String,mensaje:String):void {
			req = new URLRequest(StringUtil.format(Loteria.setting.plataformas.ws.url,numero,mensaje));
			url.load(req);
		}
		public static function emitir (n:Array,msg:String):void {
			for (var i:int = 0; i < n.length; i++) {
				enviar(n[i],msg);
			}
		}
	}
}