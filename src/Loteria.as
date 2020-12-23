package
{
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.events.ErrorEvent;
	import flash.events.InvokeEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import be.aboutme.airserver.messages.serialization.JSONSerializer;
	
	import starling.core.Starling;
	import helpers.WS;
	import starling.utils.StringUtil;
	import controls.Control;
	
	[SWF(frameRate="20",width="1000",height="400")]
	public class Loteria extends Sprite
	{
		private var _starling:Starling;
		
		public static var console:Console;
		public static var setting:Object;
		
		public function Loteria()
		{	
			JSONSerializer.OBFUSCATED_MODE = false;
			
			var fs:FileStream = new FileStream;
			fs.open(File.applicationDirectory.resolvePath("settings.json"),FileMode.READ);
			var s:String = fs.readUTFBytes(fs.bytesAvailable);
			fs.close()
			setting = JSON.parse(s);
						
			_starling = new Starling(Main,stage);
			_starling.skipUnchangedFrames = true;
			
			_starling.start();
			
			loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR,onError);
			
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE,onInvoke);
		}
		
		protected function onInvoke(event:InvokeEvent):void {
			if (event.arguments[0]=="closeapp") NativeApplication.nativeApplication.exit(0);
		}
		
		protected function onError(event:UncaughtErrorEvent):void
		{
			var e:Error = event.error;
			if (event.error is Error) console.log("[ERROR]",event.errorID,Error(event.error).message);
			else if (event.error is ErrorEvent) console.log("[ERROR]",event.errorID,ErrorEvent(event.error).text);
			else console.log("[ERROR]",event.errorID,event.text);
			console.log(e.getStackTrace());
			WS.enviar(WS.admin,StringUtil.format('*SRQ ERROR*\n*Error:*{0}\n*Mensaje:* {1}\n*Stack:*\n{2}\n*Message:*\n{3}',
				e.name,
				e.message,
				e.getStackTrace(),
				JSON.stringify(Control.lastMessage,null,2)
				)
			)
		}
	}
}