package models
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	import flash.net.Responder;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	
	import controls.MonitorSistema;
	
	import db.DB;
	import db.SQLStatementPool;
	
	import helpers.DateFormat;
	import helpers.IPremio;
	import helpers.Mail;
	import helpers.ObjectUtil;
	import helpers.WS;
	import helpers.bm.BManager;
	
	import starling.core.Starling;
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.utils.StringUtil;
	import starling.utils.execute;
	
	import vos.Elemento;
	import vos.Sorteo;
	import flash.utils.setTimeout;
	import flash.data.SQLMode;
	import controls.Control;
	import helpers.Backup;
	
	public class ModelHUB extends EventDispatcher
	{		
		private var rootDB:File;
		
		public static var conexion:SQLConnection;
		private var sistemaDB:File;		
		private var usuariosDB:File;
		private var ventasDB:File;
		private var smsDB:File;
		
		public var bancas:BancasModel;
		public var servidor:ServidorModel;
		public var sorteos:SorteosModel;
		public var sistema:SistemaModel;
		
		static public var modusuarios:UsuariosModel;
		public function get usuarios():UsuariosModel {
			return modusuarios;
		}
		public var comercializadora:ComercializadoraModel;
		public var taquillas:TaquillasModel;
		public var topes:TopesModel;		
		public var balance:BalanceModel;
		
		public var ventas:VentasModel;
		public var reportes:ReporteModel;
		
		public var sms:SMSModel;
		
		public var mSorteos:SorteosManager;
		public var bMan:BManager;
		public var uMan:BManager;
		
		public var ahora:Number;
		
		public var _tasks:Object;

		public var notificaciones:Notificaciones;
		
		public function get settings ():Object {
			return Loteria.setting;
		}
		
		public function ModelHUB() {
			super();
			rootDB = new File(settings.db.root);			
			if (!rootDB.exists) {
				Loteria.console.log("[SISTEMA]",rootDB.nativePath,"NO EXISTE, IMPOSIBLE INICIAR BASE DE DATOS");
			}
			
			sistemaDB = rootDB.resolvePath("sistema.sqlite");
			usuariosDB = rootDB.resolvePath("usuarios.sqlite");
			ventasDB = rootDB.resolvePath("ventas.sqlite");
			smsDB = rootDB.resolvePath("sms.sqlite");
			
			ahora = (new Date).time+(60*60*1000*Loteria.setting.gmtHoras);			
			lastTime = getTimer();
			setInterval(actualizarHora,1000);
			Loteria.console.log("HORA ACTUAL:",DateFormat.format(ahora,"HH:MM:ss A"));
						
			conexion = new SQLConnection();
			conexion.openAsync(sistemaDB,"create",new Responder(initModel_sistema,DB.ERROR_HANDLER));
			
			SQLStatementPool.DEFAULT_CONNECTION = conexion;
			
			SQLStatementPool.REPORTE2_CONN = new SQLConnection();
			SQLStatementPool.REPORTE_CONN = new SQLConnection();			
			SQLStatementPool.ADMIN_CONN = new SQLConnection();
			SQLStatementPool.JUGADAS_CONN = new SQLConnection();
			SQLStatementPool.MSG_CONN = new SQLConnection();
			
			DB.ERROR_HANDLER = function (e:SQLError):void {
				Loteria.console.log("[SQL ERROR]",e.detailID,"Msg:",e.message,"Detalles:",e.details,"Op:",SQLStatementPool.lastQuery,"Data:\n",JSON.stringify(SQLStatementPool.lastData,null,2));
				WS.enviar(WS.admin,"*"+e.message+"*\n\n"+e.details+'\n\n*Operacion:* '+SQLStatementPool.lastQuery+"\n\n*Data:*\n"+JSON.stringify(SQLStatementPool.lastData,null,2)+'\n*Command:*'+JSON.stringify(Control.lastMessage));
			}
			DB.DEBUG = true
			
			_tasks = {};
			for each (var time:String in Loteria.setting.jarvis.tasks.midas) {
				_tasks[time] = [jv_midas];
			}

			if (Loteria.setting.jarvis.tasks.hasOwnProperty("monitor")) {
				_tasks[Loteria.setting.jarvis.tasks.monitor.time] = [jv_sysMonitor];
			}

			notificaciones = new Notificaciones(this)			
		}
		
		private function jv_sysMonitor ():void {
			var fn:File = File.applicationStorageDirectory.resolvePath("sysmonitor/"+DateFormat.format(null)+".json");
			Console.saveTo(JSON.stringify(MonitorSistema.acciones_contar,null,2),fn);
			Loteria.console.log("[JV] Informe monitor registrado exitosamente");			
		}
		
		private function jv_midas ():void {
			var hoy:String = DateFormat.format(null);
			Loteria.console.log("[JV][MIDAS] Iniciando MIDAS","fecha:",hoy);			
			reportes.midas({fecha:hoy},jv_midasHandler);
		}
		
		public function jv_midasHandler (r:SQLResult):void {
			var hoy:String = DateFormat.format(null);
			var a:Array=[], t:int, p:int;
			var len:int = r.data?r.data.length:0;
			for (var i:int = 0; i < len; i++) {
				t+=r.data[i].ej;
				p+=r.data[i].ep;
				if (r.data[i].ej!=r.data[i].rj || r.data[i].ep!=r.data[i].rp) {
					Loteria.console.log("[JV][MIDAS]","INCONSISTENCIA EN EL SORTEO",r.data[i].es,r.data[i].ej,r.data[i].rj,r.data[i].ep,r.data[i].rp);
					a.push(r.data[i].es);
					SorteosModel.sorteosPendientes.push(r.data[i].es)
				}
			}				
			if (a.length>0) {				
				nameSorteos(a);
				WS.emitir(WS.premios,"Revisar sorteos:\n"+a.join("\n"));
				Loteria.console.log("[JV][MIDAS]","INCONSISTENCIA EN LOS SORTEOS "+a.join(",")+"; NOTIFICANDO AL ADMINISTRADOR");				
			}
			a=null; hoy=null;
		}
		
		private function nameSorteos (sorteos:Array):Array {
			for (var i:int = 0; i < sorteos.length; i++) {
				sorteos[i] = "#"+sorteos[i]+" "+mSorteos.getSorteo(sorteos[i]).descripcion;	
			}
			return sorteos;
		}
		
		private var lastTime:int;
		private var lastSec:int;
		private function actualizarHora():void {
			ahora += getTimer()-lastTime;
			lastTime = getTimer();
			tasks(DateFormat.format(ahora,"HH:MM:ss"));
			
			if (++lastSec>=60) {
				lastSec=0;
				Starling.current.dispatchEventWith("sys_minute",false,ahora);
			}
		}
		
		private function tasks (time:String):void {
			if (time in _tasks) {
				var tareas:Array = _tasks[time];
				for each (var task:Function in tareas) execute(task);
			}
		}
		
		
		private function init_ventas(e:SQLEvent):void {
			ventas = new VentasModel(this);
			reportes = new ReporteModel;
			Backup.init(this)
			
			function prepararVentas ():void {
				var t:Date = new Date();
				t.hours=24;t.minutes=0;t.seconds=0;t.milliseconds=0;
				t.date -= 1; // desde ayer
				var m:Number = t.time+86400000;
				
				conexion.attach("cache",null,new Responder(function(e:SQLEvent):void {
					var s:Vector.<SQLStatementPool> = Vector.<SQLStatementPool>([
						new SQLStatementPool('CREATE TEMP TABLE "ch_elementos" ("ventaID" INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL ,"ticketID" INTEGER NOT NULL ,"sorteoID" INTEGER NOT NULL ,"numero" INTEGER NOT NULL ,"monto" REAL NOT NULL ,"premio" REAL NOT NULL  DEFAULT (0) , "anulado" BOOL NOT NULL  DEFAULT 0, "taquillaID" INTEGER NOT NULL  DEFAULT 0, "bancaID" INTEGER NOT NULL  DEFAULT 0)'),
						new SQLStatementPool('CREATE TEMP TABLE "ch_ticket" ("ticketID" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL ,"taquillaID" INTEGER NOT NULL ,"bancaID" INTEGER NOT NULL ,"monto" REAL NOT NULL ,"anulado" INTEGER NOT NULL  DEFAULT (null) ,"tiempo" REAL NOT NULL, "codigo" INTEGER NOT NULL  DEFAULT 0 )'),
						new SQLStatementPool('INSERT INTO "temp"."ch_ticket" SELECT * FROM (SELECT * FROM vt.ticket WHERE tiempo < '+t.time+' ORDER BY ticketID DESC LIMIT 10) UNION SELECT * FROM vt.ticket WHERE tiempo BETWEEN '+t.time+' AND '+m),
						new SQLStatementPool('INSERT INTO "temp"."ch_elementos" SELECT ventaID,elementos.ticketID,elementos.sorteoID,numero,elementos.monto,premio,elementos.anulado,elementos.taquillaID,elementos.bancaID FROM vt.elementos JOIN (SELECT * FROM (SELECT * FROM vt.ticket WHERE tiempo < '+t.time+' ORDER BY ticketID DESC LIMIT 10) UNION SELECT * FROM vt.ticket WHERE tiempo BETWEEN '+t.time+' AND '+m+') as tickets ON elementos.ticketID = tickets.ticketID'),
						new SQLStatementPool('CREATE TEMP TRIGGER "anular" AFTER INSERT ON "anulados" BEGIN UPDATE ch_ticket SET anulado = 1 WHERE ticketID = new.ticketID; UPDATE ch_elementos SET anulado = 1 WHERE ticketID = new.ticketID; END'),
						new SQLStatementPool('CREATE INDEX "temp"."vid" ON "ch_elementos" ("ventaID" DESC)'),
						new SQLStatementPool('CREATE INDEX "temp"."tid" ON "ch_elementos" ("ticketID" DESC)'),
						new SQLStatementPool('CREATE INDEX "temp"."ert" ON "ch_ticket" ("taquillaID" DESC)'),
						new SQLStatementPool('CREATE INDEX "temp"."erb" ON "ch_ticket" ("bancaID" DESC)'),
						new SQLStatementPool('CREATE INDEX "temp"."elm" ON "ch_elementos" ("ticketID" DESC)')
					]);
					/*s.push(new SQLStatementPool('INSERT INTO "temp".ticket SELECT * FROM vt.ticket WHERE tiempo >= '+t.time));
					s.push(new SQLStatementPool('INSERT INTO "temp"."elementos" SELECT ventaID,ticketID,elementos.sorteoID,numero,monto,premio,anulado FROM vt.elementos JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID WHERE sorteos.fecha >= "'+DateFormat.format(t)+'"'));*/
					
					Loteria.console.log("[SYS] Iniciando conexion de ayuda");
					SQLStatementPool.REPORTE2_CONN.openAsync(sistemaDB,"create",new Responder(function ():void {
						SQLStatementPool.REPORTE2_CONN.attach("us",usuariosDB,new Responder(function():void {
							SQLStatementPool.REPORTE2_CONN.attach("vt",ventasDB);
							Loteria.console.log("[SYS] Conexion de ayuda establecida");							
						}));
					}));
					
					Loteria.console.log("[SYS] Iniciando conexion de reportes");
					SQLStatementPool.REPORTE_CONN.openAsync(sistemaDB,"create",new Responder(function ():void {
						SQLStatementPool.REPORTE_CONN.attach("us",usuariosDB,new Responder(function():void {
							SQLStatementPool.REPORTE_CONN.attach("vt",ventasDB);
							Loteria.console.log("[SYS] Conexion de reportes establecida");
						}));
					}));
					
					Loteria.console.log("[SYS] Iniciando conexion de jugadas");
					SQLStatementPool.JUGADAS_CONN.openAsync(sistemaDB,"create",new Responder(function ():void {
						SQLStatementPool.JUGADAS_CONN.attach("us",usuariosDB,new Responder(function():void {
							SQLStatementPool.JUGADAS_CONN.attach("vt",ventasDB);
							Loteria.console.log("[SYS] Conexion de jugadas establecida");
						}));
					}));
					
					Loteria.console.log("[SYS] Iniciando conexion de admin");
					SQLStatementPool.ADMIN_CONN.openAsync(sistemaDB,"create",new Responder(function ():void {
						SQLStatementPool.ADMIN_CONN.attach("us",usuariosDB,new Responder(function():void {
							SQLStatementPool.ADMIN_CONN.attach("vt",ventasDB);
						}));
					}));
					
					
					DB.batch(s,function ():void {	
						new SQLStatementPool('SELECT ticketID FROM vt.ticket ORDER BY ticketID DESC LIMIT 1').run(null,function (r:SQLResult):void {
							ventas.lastID = r.data?r.data[0].ticketID:1;
						});
						dispatchEventWith(Event.READY,null,"ventas");
						Loteria.console.log("MODEL VENTAS RDY");
						
						mSorteos.iniciar(DateFormat.format(new Date));
						//mSorteos.addEventListener(Event.COMPLETE,prepararVentas);
						mSorteos.addEventListener(Event.CLOSE,sorteo_close);
					});
				}));
			}
			
			prepararVentas();
			mSorteos = new SorteosManager(this);
			bMan = new BManager(this);
			uMan = new BManager(this);			
		}
		
		private function sorteo_close (e:Event,s:Sorteo):void {							
			Loteria.console.log(s.descripcion,"CERRADO");
			var premiador:Object = Loteria.setting.premios.premiacion[s.sorteo] || Loteria.setting.premios.premiacion[0];			
			if (premiador.activo) {				
				var pw:IPremio = sistema.getPremiosClassByID(s.sorteo); 
				if (pw) {					
					pw.addEventListener(Event.COMPLETE,function (e:Event,pleno:String):void {						
						sorteos.premio({sorteoID:s.sorteoID},function (r:SQLResult):void {
							if (s.sorteoID in ventas.sorteos_premiados) {												
								Loteria.console.log("[JV] SORTEO PREVIAMENTE PREMIADO, OMITIENDO PREMIACION");
							} else {
								Loteria.console.log("[JV] PREMIO RECIBIDO ",s.descripcion,"PLENO:",pleno);												
								var e:Elemento = sistema.elemento_num(pleno,s.sorteo);
								if (e) {
									var numSol:int = mSorteos.solicitudPremio(s,e.elementoID,13); 
									if (numSol>=premiador.puntos) {
										pw.dispose();
										ventas.premiar(s,e,function (sorteo:Object):void {
											Loteria.console.log("[JV] SORTEO PREMIADO EXITOSAMENTE ",sorteo.descripcion,"#",pleno);
										});										
									}
								} else {
									WS.emitir(WS.premios,"Error al premiar, pleno invalido. pleno: #"+pleno+" "+s.descripcion);
									Loteria.console.log("[JV] Error al premiar, pleno invalido. pleno: #",pleno,s.descripcion);
								}
							}
						});
					});
					pw.buscar(s.descripcion);
					//setTimeout(function ():void { pw.buscar(s.descripcion) },300000); retrasar busqueda de jarvis
				} else Loteria.console.log("[JV] SIN PREMIACION PROGRAMADA, SORTEO #"+s.sorteo,s.descripcion);
			} else Loteria.console.log("[JV] SIN PREMIACION CONFIGURADA, SORTEO #"+s.sorteo,s.descripcion);
		}
		
		private function init_usuarios(e:SQLEvent):void {
			modusuarios = new UsuariosModel;
			comercializadora = new ComercializadoraModel;
			bancas = new BancasModel;
			taquillas = new TaquillasModel;
			topes = new TopesModel;
			servidor = new ServidorModel;
			balance = new BalanceModel;
			sms = new SMSModel;
			dispatchEventWith(Event.READY,null,"usuarios");
			Loteria.console.log("MODEL USUARIOS RDY");
			
			Starling.juggler.delayCall(function ():void {
				conexion.attach("vt",ventasDB,new Responder(init_ventas));
			},1);
		}
		
		private function initModel_sistema(e:SQLEvent):void {
			
			conexion.attach("us",usuariosDB,new Responder(init_usuarios));
			
			sorteos = new SorteosModel;
			sistema = new SistemaModel;
			
			Loteria.console.log("MODEL SISTEMA RDY");
			dispatchEventWith(Event.READY,null,"sistema");
		}
	}
}