package
{
	import be.aboutme.airserver.AIRServer;
	import be.aboutme.airserver.endpoints.socket.SocketEndPoint;
	import be.aboutme.airserver.endpoints.socket.handlers.websocket.WebSocketClientHandlerFactory;
	import be.aboutme.airserver.events.AIRServerEvent;
	import be.aboutme.airserver.messages.Message;
	
	import controls.BancaControl;
	import controls.MonitorSistema;
	import controls.ServidorControl;
	import controls.TaquillaControl;
	import controls.UsuarioControl;
	
	import feathers.controls.LayoutGroup;
	import feathers.themes.MinimalDesktopTheme;
	
	import helpers.SMS;
	import helpers.WS;
	import helpers.pools.LoaderPool;
	
	import models.ModelHUB;
	
	import starling.events.Event;
	
	public class Main extends LayoutGroup
	{
		private var bancas:AIRServer;
		private var servidor:AIRServer;
		private var clientes:AIRServer;
		private var usuarios:AIRServer;
		
		private var model:ModelHUB;
		
		public function Main() {
			super();
			addEventListener(Event.ADDED_TO_STAGE,onAdded);
		}
		
		protected function onAdded ():void {
			new MinimalDesktopTheme();
			
			LoaderPool.initialize(100,100>>1);
			
			Loteria.console = new Console();
			Loteria.console.width = stage.stageWidth;
			Loteria.console.height = stage.stageHeight;
			Loteria.console.log("v180224");
			addChild(Loteria.console);
			
			SMS.init();
			WS.init();
			
			var n:int=0;
			model = new ModelHUB();
			model.addEventListener(Event.READY,function ():void {
				if (++n >= 3) {
					MonitorSistema.iniciar();
					
					servidor.start();
					bancas.start();
					clientes.start();
					usuarios.start();
					
					model.ventas.addEventListener(Event.CLOSE,function ():void {
						var m:Message = new Message;
						m.command = "close-mant";
						clientes.sendMessageToAllClients(m);
						
						/*setTimeout(function ():void {
							clientes.stop();
							bancas.stop();
							usuarios.stop();
						},1000);*/
					});
				}
			});
			
			servidor = new AIRServer();
			servidor.addEndPoint(new SocketEndPoint(model.settings.net.puertos.servidor,new WebSocketClientHandlerFactory));
			servidor.addEventListener(AIRServerEvent.CLIENT_ADDED,servidor_added);
			
			bancas = new AIRServer();
			bancas.addEndPoint(new SocketEndPoint(model.settings.net.puertos.banca,new WebSocketClientHandlerFactory));
			bancas.addEventListener(AIRServerEvent.CLIENT_ADDED,banca_added);
			
			clientes = new AIRServer;
			clientes.addEndPoint(new SocketEndPoint(model.settings.net.puertos.taquilla,new WebSocketClientHandlerFactory));
			clientes.addEventListener(AIRServerEvent.CLIENT_ADDED,cliente_added);
			
			usuarios = new AIRServer;
			usuarios.addEndPoint(new SocketEndPoint(model.settings.net.puertos.usuario,new WebSocketClientHandlerFactory));
			usuarios.addEventListener(AIRServerEvent.CLIENT_ADDED,usuario_added);
			
			/*sms = new AIRServer;
			sms.addEndPoint(new SocketEndPoint(model.settings.net.puertos.sms,new AMFSocketClientHandlerFactory));
			sms.addEventListener(AIRServerEvent.CLIENT_ADDED,sms_added);*/
		}
		
		protected function sms_added(event:AIRServerEvent):void
		{
			new SMSControl(event.client,model);
		}
		
		protected function usuario_added(event:AIRServerEvent):void {
			new UsuarioControl(event.client,model);
		}
		
		protected function servidor_added(event:AIRServerEvent):void {
			new ServidorControl(event.client,model);
		}
		
		protected function banca_added(event:AIRServerEvent):void {
			new BancaControl(event.client,model);
		}
		
		protected function cliente_added(event:AIRServerEvent):void {
			new TaquillaControl(event.client,model);
		}
	}
}