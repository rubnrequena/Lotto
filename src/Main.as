package
{
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

	import flash.data.SQLResult;
	import flash.filesystem.File;
	import flash.utils.setInterval;

	import helpers.DateFormat;
	import helpers.WS;
	import helpers.pools.LoaderPool;

	import http.APIControl;
	import http.HttpServer;
	import http.TaqControl;

	import models.ModelHUB;

	import starling.events.Event;
	import starling.utils.StringUtil;

	import vos.Usuario;
	import db.SQLStatementPool;
	import flash.errors.SQLError;
	
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
			
			//validar disco duro
			var minEspacioIntervalo:int = Loteria.setting.minEspacioIntervalo || 30
			var minEspacioDisponible:int = Loteria.setting.minEspacioDisponible || 1
			setInterval(function ():void {
				f = File.createTempFile();
				var size:Number = Number((f.spaceAvailable/1024/1024/1024).toFixed(2));
				Loteria.console.log('ESPACIO DISPONIBLE: ',size,"GBs");
				if (size<minEspacioDisponible) {
					WS.emitir(WS.soporte,"ADVERTENCIA: ESPACIO DISPONIBLE CRITICO, "+size+" GBs");
				}
			},1000*60*minEspacioIntervalo); // verificar cada 30m
			
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
					
					WS.emitir(WS.soporte,StringUtil.format("Servidor {0} iniciado a las:\n {1}",
						Loteria.setting.servidor,	//0
						DateFormat.format(null,DateFormat.masks.isoDateTime))
					);	//1
					validarBaseDatos();
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
			
			var webserv:HttpServer = new HttpServer();
			webserv.listen(Loteria.setting.net.puertos.api);
			webserv.registerController(new TaqControl(model));
			webserv.registerController(new APIControl(model));
		}
		
		//autoSuspender
		private function validarSuspensionesPendientes():void {
			var now:Date = new Date(model.ahora);
			model.balance.validar(now,function (r:SQLResult):void {
				for each (var us:Object in r.data) {					
					var indice:String = (us.sID as String).charAt(0);
					var id:int = int((us.sID as String).slice(1));						
					if (indice=="c" || indice=="u") model.usuarios.editar({activo:Usuario.SUSPENDIDO,usuarioID:id});
					else model.bancas.editar({activa:Usuario.SUSPENDIDO,bancaID:id});
				}
			});
		}

		private function validarBaseDatos ():void {
			/* var ticket:SQLStatementPool = new SQLStatementPool('SELECT impuesto FROM vt.ticket LIMIT 1')
			ticket.run(null,function verificacionImpuestoVenta(result:SQLResult):void {
				if (result.data) {
					if (!result.data[0].hasOwnProperty('impuesto')) {
						Loteria.console.log("ADVERTENCIA: Falta el campo 'impuesto' en la tabla vt.ventas")
						new SQLStatementPool('ALTER TABLE vt.ticket ADD impuesto REAL;').run(null,function alterTable_impuesto_vtTicket():void {
							new SQLStatementPool('ALTER TABLE us.taquillas ADD impuesto REAL DEFAULT 0;').run(null,function alterTable_impuesto_usTaquillas():void {
							Loteria.console.log('NUEVO CAMPO REGISTRADO EXITOSAMENTE')
						})
						})
					}
				}
			}) */
			var sesiones:SQLStatementPool = new SQLStatementPool('CREATE TABLE IF NOT EXISTS "us"."sesiones" ("fecha"	TEXT, "tiempo" TEXT, "usuario"	INTEGER,"tipo"	INTEGER);');
			sesiones.run(null,function crearTablaSesion(result:SQLResult):void {
				Loteria.console.log('Sesiones OK')
			},function crearSesiones_error(error:SQLError):void {
				Loteria.console.log('Ocurrio un error al registrar tabla SESIONES',error.details)
			})
			var limites:SQLStatementPool = new SQLStatementPool('CREATE TABLE "us"."limites" ("limiteID"	INTEGER PRIMARY KEY AUTOINCREMENT,"banca"	INTEGER,"grupo"	INTEGER,"monto"	REAL, "fecha" TEXT)');
			limites.run(null,function crearLimites(result:SQLResult):void {
				model.usuarios.nuevoLimite(0,0,1000,function nuevoLimite_result(error:SQLError,result:SQLResult):void {
					if (error) Loteria.console.log('ERROR AL REGISTRAR LIMITE');
				})
				Loteria.console.log('Limites OK')
			},function crearLimites_error(error:SQLError):void {
				if (error.details.indexOf('already exists')<0) {
					Loteria.console.log('Ocurrio un error al registrar tabla LIMITES',error.details)
				}
			})
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