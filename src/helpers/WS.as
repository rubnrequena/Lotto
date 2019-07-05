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
		
		private static var url:URLLoader;
		private static var req:URLRequest;		
		
		private static var queue:Array=[];
		private static var enviando:Boolean;
		
		public static var preferencias:Object;
		public static var soporte:Array;
		public static var premios:Array;
		public static var admin:String;
		
		public function WS()
		{
			
		}
		
		public static function init ():void {
			initWeb();
			preferencias = Loteria.setting.plataformas.ws;
			var usuarios:Object = Loteria.setting.plataformas.usuarios;
			soporte = usuarios.soporte;
			premios = usuarios.premios;
			admin = usuarios.admin;
		}
		
		private static function initWeb():void {
			url = new URLLoader;
			url.addEventListener(Event.COMPLETE,onComplete);
			url.addEventListener(IOErrorEvent.IO_ERROR,onError);
		}
		
		protected static function onError(event:IOErrorEvent):void {
			trace("Mensaje NO enviado");
			checkMensajes();
		}	
		protected static function onComplete(event:Event):void {
			trace("Mensaje enviado");
			checkMensajes();
		}
		protected static function checkMensajes ():void {
			enviando=false;
			if (queue.length>0) {
				var msg:Object = queue.shift();
				enviar(msg.numero,msg.mensaje);
			}
		}
		public static function enviar (numero:String,mensaje:String):void {
			if (enviando) {
					queue.push({
						numero:numero,
						mensaje:mensaje
					});
			} else  {
				mensaje = encodeURIComponent(mensaje);
				mensaje = mensaje.replace("\n","%0A");
				mensaje = "_["+Loteria.setting.servidor+"]_ "+mensaje;
				enviando=true;
				req = new URLRequest(StringUtil.format(Loteria.setting.plataformas.ws.url,numero,mensaje));
				url.load(req);
			}
		}
		public static function emitir (n:Array,msg:String):void {
			for (var i:int = 0; i < n.length; i++) enviar(n[i],msg);
		}
	}
}