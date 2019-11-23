package models
{
	import db.DB;
	import db.SQLStatementPool;
	import db.sql.VentasSQL;

	import flash.data.SQLResult;
	import flash.errors.SQLError;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	import helpers.Backup;
	import helpers.ObjectUtil;
	import helpers.WS;

	import starling.core.Starling;
	import starling.events.Event;
	import starling.utils.StringUtil;
	import starling.utils.execute;

	import vos.Elemento;
	import vos.PremioAproximacion;
	import vos.Sorteo;
	import vos.Taquilla;
	
	public class VentasModel extends Model
	{
		private var sql:VentasSQL;
		private var config:Object;
		
		private var ahora:Date;
		private var ventasID:Array;
		private var tmr:Timer;
		
		private var firstTicket:int;
		private var firstVenta:int;
		private var lastTicket:int;
		private var lastVenta:int;
		private var commitTicket:SQLStatementPool;
		private var commitElementos:SQLStatementPool;
		private var commitLastElementos:SQLStatementPool;
		private var commitLastTicket:SQLStatementPool;
		
		public var lastID:int;
		
		private var lockVentas:Boolean=false;
		private var t:int, t2:int;
		
		private var pagando:Boolean;
		private var anulando:Boolean;
				
		public function VentasModel(owner:ModelHUB)
		{
			config = Loteria.setting.premios || {pagaPorAproximacion:[]}
			super(owner);
			sql = new VentasSQL;
			ventasID = [];
			
			commitTicket = new SQLStatementPool('INSERT INTO vt.ticket SELECT * FROM "temp"."ch_ticket" WHERE ticketID > :fticket AND ticketID <= :lticket');			
			commitElementos = new SQLStatementPool('INSERT INTO vt.elementos SELECT * FROM "temp"."ch_elementos" WHERE ventaID > :fventa AND ventaID <= :lventa');
			
			commitLastTicket = new SQLStatementPool('SELECT * FROM ticket ORDER BY ticketID DESC LIMIT 1');
			commitLastElementos = new SQLStatementPool('SELECT * FROM elementos ORDER BY ventaID DESC LIMIT 1');
			
			tmr = new Timer(5000);
			tmr.addEventListener(TimerEvent.TIMER,commitment);
			tmr.start();
			
			Starling.current.nativeStage.nativeWindow.addEventListener("closing",function (e:*):void {						
				if (!lockVentas || lastTicket>firstTicket) {
					e.preventDefault();
					lockVentas=true;
					dispatchEventWith(Event.CLOSE);
					Loteria.console.log("CERRANDO SISTEMA: ",lastTicket-firstTicket," TICKETS PENDIENTES POR PROCESAR");
				}
			});
			owner.sistema.addEventListener("init-mant-db",function ():void {
				tmr.stop();
				dispatchEventWith(Event.CLOSE);
			});
			owner.sistema.addEventListener("end-mant-db",function ():void {
				tmr.start();
			});
		}
		
		private function commitment (event:TimerEvent):void {
			if (lastTicket>firstTicket) {
				t = getTimer();
				DB.batch(Vector.<SQLStatementPool>([
					commitTicket,commitElementos
				]),onCommit,onError,[{fticket:firstTicket,lticket:lastTicket},{fventa:firstVenta,lventa:lastVenta}]);
				
				firstTicket = lastTicket;
				firstVenta = lastVenta;
			}
		}
		private function onError (r:SQLError):void {
			lockVentas=true; //prevenir ventas fantasmas
			tmr.stop();
			Loteria.console.log("COMMIT ERROR",r.errorID,r.message,r.details);
			WS.emitir(WS.soporte,"CODIGO ROJO, VENTAS SUSPENDIDAS\nSe ha detenido las ventas para evitar una perdida de informacion"+r.details);
		}
		private function onCommit(result:Vector.<SQLResult>):void {
			//checkQueue();
			Loteria.console.log("COMMIT COMPLETE [",result[0].rowsAffected,result[0].lastInsertRowID-(result[0].rowsAffected-1)+"|"+result[0].lastInsertRowID,getTimer()-t+"ms");
		}
		
		private var v:Object;
		public function venta (ventas:Array,taquilla:Taquilla,cb:Function):void {
			if (lockVentas) return;
			
			var vt:Object; // TODO: object pool
						
			var m:Number=0;
			var ID:int = ++lastID;
			
			for each (v in ventas) { 
				m += Number(v.monto.toFixed(2));
			}			
			
			vt = {
				taquillaID:taquilla.taquillaID,
				bancaID:taquilla.bancaID,
				monto:Number(m.toFixed(2)),
				tiempo:owner.ahora,
				ticketID:ID,
				codigo:getRandomArbitrary(1000,9999)
			};
			sql.venta.run(vt,function (rt:SQLResult):void {
				lastTicket = ID;
				if (firstTicket==0) firstTicket = lastTicket -1;
				for each (v in ventas) { 
					v.ticketID = ID;
					v.taquillaID = taquilla.taquillaID;
					v.bancaID = taquilla.bancaID;
				}
				sql.venta_elemento.batch_nocommit(ventas,function (rv:Vector.<SQLResult>):void {
					ventasID.length = 0;
					for (var i:int = 0; i < rv.length; i++) {						
						lastVenta = rv[i].lastInsertRowID;
						ventas[i].ventaID = rv[i].lastInsertRowID;
						if (firstVenta==0) firstVenta = lastVenta -1;
						ventasID[i] = rv[i].lastInsertRowID;
					}
					execute(cb,vt,ventas,ventasID);
					dispatchEventWith(ModelEvent.VENTA,vt);
				},ventaModel_venta_error);
			});
			function ventaModel_venta_error (e:SQLError):void {
				Loteria.console.log("ERROR:",e.details,'ventasModel.as:venta()');
			}
			function getRandomArbitrary(min:int, max:int):int {
				return Math.random() * (max - min) + min;
			}
		}
		
		public function ticket (ticket:Object,cb:Function):void {
			if (ticket.hasOwnProperty("codigo")) sql.ticket_codigo.run(ticket,result); 
			else sql.ticket.run(ticket,result);
			
			function result (r:SQLResult):void {
				execute(cb,r.data?r.data[0]:null);
			}
		}
		
		public function premios (ticket:Object,cb:Function):void {
			//optimizar: reducir campos devueltos al cliente
			sql.ticket_premios.run(ticket,cb);
		}
		public function premios_pagos (f:Object,cb:Function):void {
			sql.reporte_gen_upd_pago.run(f,cb);
		}
		
		private var queuePremios:Array=[];
		public var sorteos_premiados:Object={}; 
		/*protected function checkQueue ():void {
			if (queuePremios.length>0) {
				var prm:Object = queuePremios.shift();
				var f:Function = prm.f;
				f.apply(null,prm.a);
			}
		}*/
		public function premiar (sorteo:Sorteo,elemento:Elemento,cb:Function):void {
			sorteos_premiados[sorteo.sorteoID]=true;			
			var srt:Object = {numero:elemento.elementoID,sorteoID:sorteo.sorteoID};			
			tmr.stop();
			
			t = getTimer();
			var relacion:Array; 
						
			sql.premiar.run(srt,function (r:SQLResult):void {				
				sql.relacion_pago.run({sorteo:sorteo.sorteo},premiar);	
			});
			
			function premiar (rel:SQLResult):void {
				relacion = rel.data;
				if (relacion==null || relacion.length==0) return;
				var len:int = rel.data.length;
				var premios:Array = []; var prm:Object;
								
				prm = ObjectUtil.copy(srt);
				prm.paga = relacionar(0).valor+elemento.adicional;
				
				var premioAprox:PremioAproximacion
				if (SQLStatementPool.DEFAULT_CONNECTION.inTransaction==false) SQLStatementPool.DEFAULT_CONNECTION.begin();
				sql.premiar_ventas_v2_alltemp.run(prm,function ():void {
					premioAprox = new PremioAproximacion(config.pagaPorAproximacion[sorteo.sorteo]);
					if (premioAprox.esValido) {	
						sql.premiar_ventas_v2_all.run(prm,function (r:SQLResult):void { premiarRuca(-1,premioAprox.premio); });
					} else sql.premiar_ventas_v2_all.run(prm,premiarOtros);
				});

				function premiarRuca (num:int,paga:int,continuar:Boolean=false):void {
					if (elemento.numero==premioAprox.numAbajo && num==-1) prm.numero = elemento.elementoID + 99;
					else if (elemento.numero==premioAprox.numArriba && num==1) prm.numero = elemento.elementoID - 99;
					else prm.numero = elemento.elementoID + num;
								
					prm.paga = paga;
					sql.premiar_ventas_v2_alltemp.run(prm,function ():void {
						sql.premiar_ventas_v2_all.run(prm,function (r:SQLResult):void {
							if (continuar) premiarOtros(r)
							else premiarRuca(1,premioAprox.premio,true);
						});						
					});	
				}
				
				function premiarOtros(r:SQLResult):void {
					if (relacion.length>1) {					
						var rl:Object;
						for (var i:int = 1; i < len; i++) {
							prm = ObjectUtil.copy(srt);
							prm.bancaID = relacion[i].bancaID;
							rl = relacionar(prm.bancaID);
							prm.paga = rl.valor+elemento.adicional;
							premios.push(prm);
						}
						
						sql.premiar_ventas_v2_temp.batch_nocommit(premios,function ():void {
							sql.premiar_ventas_v2.batch_nocommit(premios,premiar_complete,premiar_error);
						},premiar_error);
					} else {
						premiar_complete(null);
					}
				}			
			}
			
			function premiar_complete (r:Vector.<SQLResult>):void {
				guardarReportes();	
				sorteo.ganador = elemento.elementoID;
				execute(cb,sorteo);
				//verificar si estaba pendiente
				if (SorteosModel.sorteosPendientes.indexOf(sorteo.sorteoID)>-1) {
					WS.emitir(WS.premios,StringUtil.format('*SORTEO PENDIENTE PREMIADO*\n#{0} {1}',sorteo.sorteoID,sorteo.descripcion))
				}

				dispatchEventWith(ModelEvent.PREMIO,false,sorteo);
			}
			function premiar_error (e:SQLError):void {
				tmr.start();
				Loteria.console.log("[",e.name,"]",e.detailID,e.details);
				sorteos_premiados[sorteo.sorteoID]=false;				
			}
			
 			function guardarReportes():void {		
				sql.reporte_nuevo.run({sorteoID:sorteo.sorteoID},function reporte_nuevo_complete (r:SQLResult):void {
					Loteria.console.log(getTimer()-t+"ms, REPORTE REGISTRADO CON EXITO, #"+sorteo.sorteoID,sorteo.descripcion);
					Backup.reporte(sorteo.sorteoID);
					if (SQLStatementPool.DEFAULT_CONNECTION.inTransaction) SQLStatementPool.DEFAULT_CONNECTION.commit();
					tmr.start();					
				},function reporte_nuevo_error (r:SQLError):void {
					WS.emitir(WS.premios,"SRQ ERROR: IMPOSIBLE PREMIAR SORTEO <p>Sorteo #"+sorteo.sorteoID+" "+sorteo.descripcion+'</p>');
					Loteria.console.log("[",r.name,"]",r.detailID,r.details);
					if (SQLStatementPool.DEFAULT_CONNECTION.inTransaction) SQLStatementPool.DEFAULT_CONNECTION.commit();
					tmr.start(); //en caso de fallar, seguir guardando ventas					
					sorteos_premiados[sorteo.sorteoID]=false;
				});
			}
			function relacionar (banca:int):Object {
				var len:int = relacion.length, i:int;
				for (i = 0; i < len; i++) {
					if (relacion[i].bancaID==banca) return relacion[i];
				}
				return 0;
			}
		}
		
		public function reiniciar_sorteo (sorteo:Object,cb:Function):void {			
			sorteo.numero = 0;
			delete sorteos_premiados[sorteo.sorteoID];
			sql.premiar.run(sorteo,function (r:SQLResult):void {
				delete sorteo.numero;
				sql.premiar_reinicio_temp.run(sorteo,function (r:SQLResult):void {
					sql.premiar_reinicio.run(sorteo);
				});
				
				Loteria.console.log("PREMIO REINICIADO CON EXITO");
				execute(cb,r);
			});
		}
		public function ventas_elementos (s:Object,cb:Function):void {
			if (s.hasOwnProperty("taquillaID")) sql.ventas_elemento_sorteos_taquilla.run(s,cb);
			else if (s.hasOwnProperty("bancaID")) sql.ventas_elemento_sorteos_banca.run(s,cb);
			else if (s.hasOwnProperty("usuarioID")) sql.ventas_elemento_sorteos_usuario.run(s,cb);
			else if (s.hasOwnProperty("ticketID")) sql.ventas_elementos_ticket.run(s,cb);
			else if (s.hasOwnProperty("ticket")) sql.ventas_elementos_ticketID.run(s,cb);
			else sql.ventas_elemento_sorteos.run(s,cb);
		}
		public function venta_elemento (s:Object,cb:Function):void {
			sql.ventas_elementos_ventaID.run(s,cb);
		}
		public function repetir (t:Object,cb:Function):void {
			sql.ventas_elementos_repetir.run(t,cb);
		}		
		
		public function tickets (s:Object,cb:Function):void {
			if (s.hasOwnProperty("ultimo")) sql.tickets_ultimo.run(s,cb);
		}
		
		public function anular (ticket:Object,taquilla:Taquilla,cb:Function,err:Function):void {
			sql.anular.run(ticket,anular_result,err); 
			
			function anular_result (tk:SQLResult):void {
				execute(cb,tk);
				dispatchEventWith(Event.REMOVED,{tk:ticket,taq:taquilla});
			}
		}
		public function anulado (ticket:Object,cb:Function):void {
			sql.anulado.run(ticket,cb);
		}
		
		public function anular_batch (tickets:Array,cb:Function,error:Function=null):void {
			sql.anular.batch_nocommit(tickets,cb,error);
		}
		
		public function pagar(ticket:Object,cb:Function,err:Function=null):void {
			sql.pagar.run(ticket,cb,err);
		}
		public function monitor (s:Object,cb:Function):void {
			if (s.hasOwnProperty("bancaID")) {
				sql.jugadas_banca_taq.run(s,function (taq:SQLResult):void {
					sql.jugadas_banca_num.run(s,function (num:SQLResult):void {
						execute(cb,{t:taq.data,n:num.data});
					});
				});
			} else if (s.hasOwnProperty("usuarioID")) {
				sql.jugadas_usuario_bnc.run(s,function (taq:SQLResult):void {
					sql.jugadas_usuario_num.run(s,function (num:SQLResult):void {
						execute(cb,{t:taq.data,n:num.data});
					});
				});	
			} else if (s.hasOwnProperty("comercialID")) {
				sql.jugadas_comercial_bnc.run(s,function (taq:SQLResult):void {
					sql.jugadas_comercial_num.run(s,function (num:SQLResult):void {
						execute(cb,{t:taq.data,n:num.data});
					});
				});		
			} else {
				sql.jugadas_srv_banca.run(s,function (taq:SQLResult):void {
					sql.jugadas_srv_num.run(s,function (num:SQLResult):void {
						execute(cb,{t:taq.data,n:num.data});
					});
				});
			}
		}
		
		public function jugadas_banca (s:Object,cb:Function):void {
			if (s.hasOwnProperty("sorteoID")) sql.jugadas_banca_sorteo.run(s,cb);
			else sql.jugadas_banca.run(s,cb);
		}
		
		public function remover(taq:Object,cb:Function):void {
			sql.remover_taq.run(taq,cb);
		}
	}
}