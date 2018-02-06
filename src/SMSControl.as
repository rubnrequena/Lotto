package
{
	import flash.events.Event;
	
	import be.aboutme.airserver.Client;
	import be.aboutme.airserver.messages.Message;
	
	import controls.Control;
	
	import models.ModelHUB;
	
	import starling.events.Event;
	
	public class SMSControl extends Control
	{
		public static var _clientes:Vector.<Client> = new Vector.<Client>;
		
		private var msg:Message;
		
		public function SMSControl(cliente:Client,model:ModelHUB)
		{
			super(cliente,model);
			_clientes.push(cliente);
			
			msg = new Message;
			
			model.addEventListener("sms_send",onSend);
			
			/*dispatchEventWith("sms_send",false,{
				command:"sms",
				data:{t:"04149970167",m:"Hola mundo"}
			});*/
		}
		
		private function onSend(e:starling.events.Event):void {
			msg.command = e.data.command;
			msg.data = e.data.data;
			_cliente.sendMessage(msg);
		}
		
		override protected function onClose(event:flash.events.Event):void {
			_model.removeEventListener("sms_send",onSend);
			super.onClose(event);			
			_clientes.removeAt(_clientes.indexOf(_cliente));
		}
	}
}