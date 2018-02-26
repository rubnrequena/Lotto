package helpers
{
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.filesystem.File;

	public class WS
	{
		private var process:NativeProcess;
		public function WS()
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
		
		public function enviar (n:String,msg:String):void {
			var s:String = 'python yowsup-cli demos -s '+n+' "'+msg+'" -c config.conf';
			process.standardInput.writeMultiByte(s+'\n',File.systemCharset);
		}
	}
}