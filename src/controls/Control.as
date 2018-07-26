package controls
{
	
	import flash.events.Event;
	import flash.utils.getTimer;
	
	import avmplus.getQualifiedClassName;
	
	import be.aboutme.airserver.Client;
	import be.aboutme.airserver.events.MessageReceivedEvent;
	
	import models.ModelHUB;
	
	import starling.events.EventDispatcher;
	
	public class Control extends EventDispatcher
	{
		public static const DIAS10:uint = 864000000;
		
		private static const CLASS_NAME:Object = {
			TaquillaControl:"TC",
			BancaControl:"BC",
			UsuarioControl:"UC",
			ServidorControl:"SC",
			ComercializadoraControl:"CC"
		}
			
		protected var _model:ModelHUB;
		protected var _cliente:Client;
		
		protected var mt:int;
		protected var cmt:int;
		protected var controlName:String;
		protected var controlNameID:String;
		protected var _controlID:*;
		

		public function set controlID(value:*):void {
			_controlID = value;
			controlNameID = CLASS_NAME[getQualifiedClassName(this).split("::").pop()];
			controlName = "["+controlNameID+":"+value+"]";
		}

		
		static public var EX_HANDLER:EventDispatcher = new EventDispatcher;
		
		public function Control(cliente:Client,model:ModelHUB) {
			super();
			_model = model;
			_cliente = cliente;
			
			_cliente.addEventListener(MessageReceivedEvent.MESSAGE_RECEIVED,onMessage);
			_cliente.addEventListener(Event.CLOSE,onClose);		
			
			controlName = "["+getQualifiedClassName(this).split("::").pop()+"]";
		}
		
		protected function onClose(event:Event):void {
			_cliente.removeEventListener(Event.CLOSE,onClose);
			removeEventListeners();
			dispose();
		}		
		
		protected function onMessage(event:MessageReceivedEvent):void {
			mt = getTimer();			
			//Loteria.console.log(controlName,event.message.command,JSON.stringify(event.message.data));
			dispatchEventWith(event.message.command,false,event.message);
		}
		
		protected function measure(e:String):void {
			cmt=getTimer()-mt;
			Loteria.console.log(controlName,e,cmt+"ms");
			MonitorSistema.monitor.ms_last = cmt;
			MonitorSistema.monitor.ms_last_desc = controlNameID+"_"+e;
		}
		
		protected function dispose():void {
			
		}
		
		
	}
}