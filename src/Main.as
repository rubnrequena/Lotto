package
{
	import flash.data.SQLResult;
	import flash.filesystem.File;
	
	import be.aboutme.airserver.AIRServer;
	import be.aboutme.airserver.endpoints.socket.SocketEndPoint;
	import be.aboutme.airserver.endpoints.socket.handlers.websocket.WebSocketClientHandlerFactory;
	import be.aboutme.airserver.events.AIRServerEvent;
	import be.aboutme.airserver.messages.Message;
	
	import controls.BancaControl;
	import controls.ComercializadoraControl;
	import controls.MonitorSistema;
	import controls.ServidorControl;
	import controls.TaquillaControl;
	import controls.UsuarioControl;
	
	import feathers.controls.LayoutGroup;
	import feathers.themes.MinimalDesktopTheme;
	
	import helpers.DateFormat;
	import helpers.SMS;
	import helpers.WS;
	import helpers.pools.LoaderPool;
	
	import models.ModelHUB;
	
	import starling.events.Event;
	import starling.utils.StringUtil;
	
	public class Main extends LayoutGroup
	{
		private var bancas:AIRServer;
		private var servidor:AIRServer;
		private var clientes:AIRServer;
		private var usuarios:AIRServer;
		private var comercializadora:AIRServer;
		
		private var model:ModelHUB;
		
		public function Main() {
			super();
			addEventListener(Event.ADDED_TO_STAGE,onAdded);
		}
		
		protected function onAdded ():void {
			new MinimalDesktopTheme();
			
			LoaderPool.initialize(100,100>>1);
			
			var f:File;
			Loteria.console = new Console();
			Loteria.console.width = stage.stageWidth;
			Loteria.console.height = stage.stageHeight;
			f = File.applicationDirectory.resolvePath("Loteria.swf");
			Loteria.console.log("v"+DateFormat.format(f.creationDate,"yymmdd"),f.modificationDate.toLocaleTimeString());
			addChild(Loteria.console);
			
			WS.init();
			SMS.init();
			
			//validar disco duro
			f = File.createTempFile();
			var size:Number = Number((f.spaceAvailable/1024/1024/1024).toFixed(2));
			Loteria.console.log('ESPACIO DISPONIBLE: ',size,"GBs");
			if (size<Loteria.setting.minEspacioDisponible) {
				WS.enviar(Loteria.setting.plataformas.usuarios.admin,
					"["+Loteria.setting.servidor+"] ADVERTENCIA: ESPACIO DISPONIBLE CRITICO, "+size+" GBs");
			}
			
			var n:int=0;
			model = new ModelHUB();
			model.addEventListener(Event.READY,function ():void {
				if (++n >= 3) {
					MonitorSistema.iniciar();
					
					servidor.start();
					bancas.start();
					clientes.start();
					usuarios.start();
					comercializadora.start();		
					
					SMS.sendMulti(SMS.ADMIN_CONTACTS,StringUtil.format("Servidor {0} iniciado a las: {1}",
						Loteria.setting.servidor,	//0
						DateFormat.format(null,DateFormat.masks.isoDateTime))
					);	//1
					
					validarSuspensionesPendientes();
					
					model.ventas.addEventListener(Event.CLOSE,function ():void {
						var m:Message = new Message;
						m.command = "close-mant";
						clientes.sendMessageToAllClients(m);
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
			
			
			comercializadora = new AIRServer;
			comercializadora.addEndPoint(new SocketEndPoint(model.settings.net.puertos.comercializadora,new WebSocketClientHandlerFactory));
			comercializadora.addEventListener(AIRServerEvent.CLIENT_ADDED,comer_added);
			/*sms = new AIRServer;
			sms.addEndPoint(new SocketEndPoint(model.settings.net.puertos.sms,new AMFSocketClientHandlerFactory));
			sms.addEventListener(AIRServerEvent.CLIENT_ADDED,sms_added);*/
		}
		
		private function validarSuspensionesPendientes():void {
			Loteria.console.log("VALIDANDO USUARIOS POR SUSPENDER");
			var now:Date = new Date(model.ahora);
			model.balance.validar(now,function (r:SQLResult):void {
				var count:int=0;
				for each (var us:Object in r.data) {					
					var time:int = (now.time-us.tiempo)/1000/60/60/24;
					if (time>us.limite && us.balance>us.minMonto) {
						var indice:String = (us.usID as String).charAt(0);
						var id:int = int((us.usID as String).slice(1));						
						if (indice=="c" || indice=="u") {
							model.usuarios.editar({activo:-10,usuarioID:id});
						} else {
							model.bancas.editar({activa:-10,bancaID:id});
						}
					}
				}
			});
		}
		
		protected function comer_added(event:AIRServerEvent):void {
			new ComercializadoraControl(event.client,model);
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