package helpers
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	import helpers.pools.LoaderPool;
	
	import starling.utils.execute;

	public class Mail
	{
		public function Mail()
		{
			
		}
		
		public static const PREMIO_CONFIRMADO:String = "[{4}]<p>SORTEO: #{0} {1}</p><p>NUMERO: {2}</p><p>USUARIO: {3}</p>";
		public static const PREMIO_REINICIADO:String = "<p>SORTEO: #{0} {1}</p><p>FECHA: {2}</p><p>USUARIO: {3}</p>";
		
		public static const JV_MIDAS_INCONSISTENCIA:String = '<p style="font-weight:bold">{0} SORTEO(S) NO COINCIDEN</p><p>FECHA: {1}</p><p>SORTEOS: <br/>{2}</p>';
		public static const JV_MIDAS_OK:String = '<p style="font-weight:bold">TODOS LOS SORTEOS COINCIDEN</p><p>FECHA: {0}</p><p>JUGADO: {1}</p><p>PREMIOS: {2}</p>';
		
		public static const VENTA_CONFIRMADA:String = "<p>AGENCIA: {0}</p><p>FECHA: {1}</p><p>SERIAL: {2}</p><p>CODIGO SEG: {3}</p><p>TOTAL JUGADO: {4}</p><p><b>JUGADAS</b></p>{5}<p>TICKET EXPIRA EN 3 DIAS</p>";
		
		private static var loader:URLLoader;
		private static var req:URLRequest = new URLRequest("http://srq.com.ve/mailed.php");
		private static var vars:URLVariables = new URLVariables;
		public static function send (to:String,subject:String,body:String,cb:Function=null):Boolean {
			if (Loteria.setting.plataformas.correo.activa==1) {
				
				loader = LoaderPool.getItem();
				loader.addEventListener(Event.COMPLETE,onComplete);
				loader.addEventListener(IOErrorEvent.IO_ERROR,onError);
				
				vars.to = to;
				vars.subject = subject;
				vars.msg = body;
				
				req.method = URLRequestMethod.POST;
				req.data = vars;			
				loader.load(req);
				
				function onComplete(event:Event):void {
					execute(cb,loader.data);
					loader.removeEventListener(Event.COMPLETE,onComplete);
					loader.removeEventListener(IOErrorEvent.IO_ERROR,onError);
					LoaderPool.dispose(loader);
				}
				function onError(event:IOErrorEvent):void
				{
					loader.removeEventListener(Event.COMPLETE,onComplete);
					loader.removeEventListener(IOErrorEvent.IO_ERROR,onError);
					Loteria.console.log("[MAIL] Error al conectar con servidor");
				}
			}
			return Loteria.setting.plataformas.correo.activa;
		}
		public static function sendAdmin (subject:String,body:String,cb:Function=null):Boolean {
			if (Loteria.setting.servidor=="local") return false;
			return send("rubnrequena@gmail.com","["+Loteria.setting.servidor+"] "+subject,body,cb);
		}
	}
}