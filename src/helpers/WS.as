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

	public class WS
	{
		public static const NTF_TQ_SORTEO_INV:String = "[{3}] VERIFICAR RESULTADO\\nSORTEO: {0}\\nTAQ: {1}\\nUSUARIO: {2}";
		
		private static var process:NativeProcess;
		
		private static var url:URLLoader;
		private static var req:URLRequest;
		private static var reqData:URLVariables;
		private static var queue:Array=[];
		private static var cmsg:Object;
		private static var ocupado:Boolean;
		public static var preferencias:Object;
		
		public function WS()
		{
			
		}
		
		public static function init ():void {
			initWeb();
			preferencias = Loteria.setting.plataformas.ws;
		}
		
		private static function initWeb():void {
			url = new URLLoader;
			url.addEventListener(Event.COMPLETE,onComplete);
			url.addEventListener(IOErrorEvent.IO_ERROR,onError);
			
			var wsUrl:String = Loteria.setting.plataformas.ws.url[0]; //alternar entre varias url
			req = new URLRequest(wsUrl);
			
			reqData = new URLVariables;
		}
		
		protected static function onError(event:IOErrorEvent):void
		{
			ocupado=false;
			queue.push(cmsg);
			checkQueue();
		}
		
		protected static function onComplete(event:Event):void {
			ocupado=false;
			checkQueue();
		}
		
		public static function enviar (numero:String,mensaje:String):void {
			queue.push({
				num:numero,msg:mensaje
			});
			
			if (!ocupado) checkQueue();
		}
		
		private static function checkQueue():void
		{
			if (queue.length>0) {
				cmsg = queue.removeAt(0);
				
				reqData.n = cmsg.num;
				reqData.msg = cmsg.msg;
				reqData.psw = Loteria.setting.plataformas.ws.psw;
				
				req.data = reqData;
				ocupado=true;
				url.load(req);
			}
		}
		public static function emitir (n:Array,msg:String):void {
			for (var i:int = 0; i < n.length; i++) {
				enviar(n[i],msg);
			}
		}
		
		private static function initLocal():void
		{
			var nativeProcessStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
			var dir:File = new File(Loteria.setting.plataformas.ws.yowdir);
			var file:File = new File("C:\\Windows\\System32\\cmd.exe"); 
			nativeProcessStartupInfo.executable = file;
			nativeProcessStartupInfo.workingDirectory = dir; 
			process = new NativeProcess(); 
			//process.addEventListener(ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData); 
			process.start(nativeProcessStartupInfo);
		}
		
		public static function enviarLocal (n:String,msg:String):void {
			var s:String = 'python yowsup-cli demos -s '+n+' "'+msg+'" -c config.conf';
			process.standardInput.writeMultiByte(s+'\n',File.systemCharset);
		}
	}
}