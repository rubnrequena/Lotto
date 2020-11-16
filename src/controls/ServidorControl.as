package controls
{
	import flash.data.SQLResult;
	import flash.errors.SQLError;
	import flash.utils.getTimer;
	
	import be.aboutme.airserver.Client;
	import be.aboutme.airserver.messages.Message;
	
	import helpers.Code;
	import helpers.DateFormat;
	import helpers.Mail;
	import helpers.ObjectUtil;
	import helpers.WS;
	
	import models.ModelHUB;
	
	import starling.events.Event;
	import starling.utils.StringUtil;
	
	import vos.Elemento;
	import vos.Sorteo;
	import vos.sistema.Admin;
	import models.SorteosModel;
	import db.sql.SQLAPI;
	import db.SQLStatementPool;
	
	public class ServidorControl extends Control
	{
		private var msg:Message;
		private var usuario:Admin;
		
		public function ServidorControl(cliente:Client, model:ModelHUB) {
			super(cliente, model);
			msg = new Message;		
			addEventListener("login",login);
		}
		
		private function login(e:Event,m:Message):void {
			_model.servidor.login(m.data,function (usr:Admin):void {
				usuario = usr; 
				if (usr) {
					Loteria.console.log('ADMIN',usr.usuario,"inicia sesion");
					m.data = {
						code:Code.OK,
						usr:usr
					};
					if (usr.nivel==1) addListeners_admin();
					else addListeners_premiar();
          addListeners();
					_cliente.sendMessage(m);
					
					_model.servidor.sorteos({adminID:usuario.adminID},function (s:SQLResult):void {
						m.command = "init";
						m.data = {sorteos:s.data};
						_cliente.sendMessage(m);
					});
					
					initSolicitudesPremios();
				} else {
					m.data = {code:Code.NO_EXISTE}
					_cliente.sendMessage(m);
				}
			});
		}
		private function addListeners():void {
			addEventListener("sql",sqlapi)
			addEventListener("premio-bot-lista",premioBot_lista);
			addEventListener("premio-bot-nuevo",premioBot_nuevo);
			addEventListener("premio-bot-remover",premioBot_remover);
    }
		private function addListeners_premiar():void {
			addEventListener("inicio",inicio);
			addEventListener("lsorteos",lsorteos);
			addEventListener("sorteo",sorteo);
			addEventListener("sorteos",sorteos);
			addEventListener("sorteo-registrar",sorteo_registrar);
			addEventListener("sorteo-premiar",sorteo_premiar);
			addEventListener("sorteo-reiniciar",sorteo_reiniciar);
			addEventListener("sorteo-editar",sorteo_editar);
			addEventListener("sorteo-num-hist",sorteo_numHist);
			addEventListener("sorteo-monitor-vnt",sorteo_monitor_vnt);
			addEventListener("sorteo-pendientes",sorteo_pendientes);
			addEventListener("elementos",elementos);
			
			addEventListener("monitor",monitor);			
			addEventListener("ticket",ticket);
			
			addEventListener("reporte-sorteo",reporte_sorteo);			
			addEventListener("reporte-sorteo-global",reporte_sorteo_global);
		}
		
		private function addListeners_admin():void {
			addEventListener("inicio",inicio);
			
			addEventListener("lsorteos",lsorteos);
			addEventListener("presorteos",presorteos);
			addEventListener("presorteo-nuevo",presorteo_nuevo);
			addEventListener("presorteo-remover",presorteo_remover);
			
			addEventListener("sorteo",sorteo);
			addEventListener("sorteos",sorteos);
			addEventListener("sorteo-registrar",sorteo_registrar);
			addEventListener("sorteo-premiar",sorteo_premiar);
			addEventListener("sorteo-reiniciar",sorteo_reiniciar);
			addEventListener("sorteo-remover",sorteo_remover);
			addEventListener("sorteo-editar",sorteo_editar);
			addEventListener("sorteo-num-hist",sorteo_numHist);
			addEventListener("sorteo-monitor-vnt",sorteo_monitor_vnt);
			addEventListener("sorteo-pendientes",sorteo_pendientes);
			
			addEventListener("elemento-nuevo",elemento_nuevo);
			addEventListener("elementos",elementos);
			addEventListener("elemento-nuevo-zodiaco",elemento_nv_zodiaco);
			
			addEventListener("usuarios",usuarios);
			addEventListener("usuario-nuevo",usuario_nuevo);
			addEventListener("usuario-editar",usuario_editar);
			addEventListener("usuario-asignar",usuario_asignar);
			addEventListener("usuario-listaSuspender",usuarioLSuspender);
			addEventListener("usuario-susprem",usuario_suspremover);
			addEventListener("usuario-suspnvo",usuario_suspnuevo);
			
			addEventListener("comerciales",usuario_comercializadoras);
			
			addEventListener("bancas",bancas);
			addEventListener("bancas-nombres",bancas_nombres);
			addEventListener("banca-nueva",banca_nueva);
			addEventListener("banca-editar",banca_editar);
			addEventListener("banca-relacion",banca_relacion);
			addEventListener("banca-remover",banca_remover);
			
			addEventListener("taquillas",taquillas);
			addEventListener("taquilla-nueva",taquilla_nueva);
			addEventListener("taquilla-editar",taquilla_editar);
			addEventListener("taquilla-flock",taquilla_lock);
			addEventListener("taquilla-fpclear",taquilla_clear);
			
			addEventListener("reporte-general",reporte_general);
			addEventListener("reporte-comercial",reporte_comercial);
			addEventListener("reporte-cobros",reporte_cobros);
			addEventListener("reporte-subcobros",reporte_cobros);
			
			addEventListener("reporte-banca",reporte_banca);
			addEventListener("reporte-recogedor",reporte_recogedor);
			addEventListener("reporte-taquilla",reporte_taquilla);
			
			addEventListener("reporte-sorteo",reporte_sorteo);			
			addEventListener("reporte-sorteo-global",reporte_sorteo_global);
						
			addEventListener("topes",topes);
			addEventListener("tope-nuevo",tope_nuevo);
			
			addEventListener("venta-anular",venta_anular);
			addEventListener("monitor",monitor);
			
			addEventListener("ticket",ticket);
			
			addEventListener("sql-command",sql_command);
			addEventListener("sys-monitor",sys_monitor);
			
			addEventListener("sys-midas",sys_midas);
			addEventListener("sys-mant",sys_mant);
			
			addEventListener("sorteos-usuarios",usuarios_sorteos);
			addEventListener("sorteo-usuario",usuario_sorteo);
						
			addEventListener("balance-add",balance_add);
			addEventListener("balance-general",balance_general);
			addEventListener("balance-pagos",balance_pagos);
			addEventListener("balance-ppagos",balance_ppagos);
			addEventListener("balance-confirmacion",balance_confirmacion);
			addEventListener("balance-remover-pend",balance_rem_pendiente);
			
			/*_model.mSorteos.addEventListener(Event.OPEN,sorteo_abierto);
			_model.mSorteos.addEventListener(Event.CLOSE,sorteo_cerrado);*/
		}
		
		private var sqlAPI:SQLAPI = new SQLAPI()
		private function sqlapi(e:Event,m:Message):void {
			var comando:String = m.data.comando
			var payload:Object = m.data.data || {};
			payload.padreID = usuario.adminID
			payload.id = usuario.adminID
			delete m.data.comando;
			var sql:SQLStatementPool = sqlAPI.exec(comando)
			if (!sql) sendMessage(m,{error:'sentencia no existe'})
			else  {
				sql.run(payload,function (result:SQLResult):void {
				sendMessage(m,result)
			})
			}
		}
		private function usuario_comercializadoras(e:Event,m:Message):void
		{
			_model.comercializadora.comercializadoras(null,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}
		
		private function usuario_suspnuevo(e:Event,m:Message):void
		{
			m.data.resID = usuario.usID;
			_model.usuarios.suspender_nuevo(m.data,function (r:SQLResult):void {
				m.data = r.lastInsertRowID;
				_cliente.sendMessage(m);
			});
		}
		
		private function usuario_suspremover(e:Event,m:Message):void
		{
			m.data.resID = usuario.usID;
			_model.usuarios.suspender_remover(m.data,function (r:SQLResult):void {
				m.data = r.lastInsertRowID;
				_cliente.sendMessage(m);
			});
		}
		
		private function usuarioLSuspender(e:Event,m:Message):void {
			_model.usuarios.listaSuspender(usuario.usID,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}
		
		private function balance_rem_pendiente(e:Event,m:Message):void
		{
			m.data.rID = usuario.usID;
			_model.balance.remover_pend(m.data,function (r:SQLResult):void {
				m.data.code = r.rowsAffected;
				_cliente.sendMessage(m);
			});
		}
		
		private function balance_confirmacion(e:Event,m:Message):void {
			m.data.rID = usuario.usID;
			m.data.monto = Math.abs(m.data.monto)*-1;
			m.data.tiempo = _model.ahora;
			_model.balance.confirmar_pago(m.data,function (r:SQLResult):void {
				m.data = r.rowsAffected;
				_cliente.sendMessage(m);
			});
		}
		
		private function balance_pagos(e:Event,m:Message):void
		{
			m.data.rID = usuario.usID;
			m.data.c = 1;
			_model.balance.pagos_operador(m.data,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}
		private function balance_ppagos(e:Event,m:Message):void
		{
			m.data = {};
			m.data.rID = usuario.usID;
			m.data.inicio = "2018-01-01";
			m.data.fin = "2900-12-31";
			m.data.c = 0;
			_model.balance.pagos_operador(m.data,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}
		
		private function balance_general(e:Event,m:Message):void
		{
			if (m.data==null) m.data = {rID:usuario.usID};
			else m.data.rID = usuario.usID;
			_model.balance.operador(m.data,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}
		
		private function balance_add(e:Event,m:Message):void
		{
			m.data.resID = "a"+usuario.adminID;
			m.data.fecha = DateFormat.format(_model.ahora);
			m.data.tiempo = _model.ahora;
			_model.balance.nuevo(m.data,function (r:SQLResult):void {
				m.data.balID = r.lastInsertRowID;
				_cliente.sendMessage(m);
			});
		}
		
		private function reporte_cobros(e:Event,m:Message):void {
			//if (m.data.g==1) _model.reportes.general_fecha(m.data.s,result);
			if (m.data.g==2) _model.reportes.cbr_usuarios(m.data.s,result);
			else if (m.data.g==3) _model.reportes.cbr_comerciales(m.data.s,result);
			
			function result (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			}
		}
		
		private function reporte_comercial(e:Event,m:Message):void
		{
			//m.data.s.comercial = usuario.usuarioID;
			if (m.data.g==0) _model.reportes.general(m.data.s,result);
			else if (m.data.g==1) _model.reportes.general_fecha(m.data.s,result);
			else if (m.data.g==2) {
				_model.reportes.comercial(m.data.s,result);
			}
			
			function result (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			}
		}
		
		private function sorteo_monitor_vnt(e:Event,m:Message):void {
			_model.servidor.monitor_venta_tickets(m.data,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}
		
		
		private function sorteo_pendientes(e:Event,m:Message):void
		{
			m.data.aID = usuario.adminID;
			_model.sorteos.pendientes(m.data,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}
		
		private function sorteo_numHist(e:Event,m:Message):void {
			_model.servidor.historia_numero(m.data,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}
		
		private function usuario_asignar(e:Event,m:Message):void {
			_model.comercializadora.linkUsuario({
				cID:m.data.cid,
				uID:m.data.uid
			},function (r:SQLResult):void {
				m.data = r.lastInsertRowID;
				_cliente.sendMessage(m);
			});
		}
		
		private function usuario_sorteo(e:Event,m:Message):void {
			if (m.data.hasOwnProperty("usuario")) {
				_model.usuarios.usuarios({usuario:m.data.usuario},function (usuario:SQLResult):void {
					if (usuario.data) {
						_model.servidor.usuario_reg_sorteo({sorteo:sorteoPremiar,usuarioID:usuario.data[0].usuarioID},function (r:SQLResult):void {
							m.data = {code:Code.OK};
							_cliente.sendMessage(m);
						});						
					} else {
						m.data = {code:Code.NO_EXISTE};
						_cliente.sendMessage(m);
					}
				})
			} else if (m.data.hasOwnProperty("sid")) {
				m.data.sorteo = sorteoPremiar;
				_model.servidor.usuario_del_sorteo(m.data,function (r:SQLResult):void {
					m.data = {code:Code.OK};
					_cliente.sendMessage(m);
				});
			}
		}
		
		private var sorteoPremiar:int;
		private function usuarios_sorteos(e:Event,m:Message):void
		{
			_model.servidor.sorteos({adminID:usuario.adminID},function (s:SQLResult):void {
				if (s.data && s.data.length==1) { 
					sorteoPremiar = s.data[0].sorteoID;
					_model.servidor.usuario_sorteos({sorteo:sorteoPremiar},result_sorteos);
				} else _model.servidor.usuario_sorteos(null,result_sorteos);
				
				function result_sorteos (r:SQLResult):void {
					m.data = r.data;
					_cliente.sendMessage(m);
				};
			});
		}
		
		private function sys_mant (e:Event,m:Message):void {
			_model.sistema.mant_baseDatos(m.data.fecha,function (r:Array):void {
				m.data = {code:r.shift()};
				m.data.meta = r;
				_cliente.sendMessage(m);
			},null); //capturar errores
		}
		private function sys_midas(e:Event,m:Message):void
		{
			_model.reportes.midas(m.data,function midasResult (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
				measure(m.command);
			});
		}
		
		private function sys_monitor(e:Event,m:Message):void {
			if (m.data.m=="ms") m.data = MonitorSistema.rendimiento;
			else if (m.data.m=="acc") m.data = MonitorSistema.acciones_contar; 
			_cliente.sendMessage(m);
		}
		
		private function sql_command(e:Event,m:Message):void {
			var sql:String = m.data.sql;
			var time:int = getTimer();
			_model.servidor.sqlc(sql,
				function (r:SQLResult):void {
					if (r.data) {
						var l:int = Math.ceil(r.data.length/50);
						for (var i:int = 0; i < l; i++) {
							m.data = {
								code:Code.OK,
								d:r.data.splice(0,50),
								last:0
							};
							_cliente.sendMessage(m);
						}
					}
					m.data.d = undefined;
					m.data.code = Code.OK;
					m.data.s = sql;			
					m.data.last = 1;
					m.data.time = getTimer()-time;
					measure(m.command);
					_cliente.sendMessage(m);
					
					/*measure(m.command);
					m.data = {code:Code.OK,s:m.data.sql,d:r};
					_cliente.sendMessage(m);*/
				},
				function (error:SQLError):void {
					m.data = {code:Code.INVALIDO,s:sql,error:error,last:1}
					_cliente.sendMessage(m);
				}
			);
		}
		
		private function usuario_editar(e:Event,m:Message):void {
			_model.usuarios.editar(m.data,function (r:SQLResult):void {
				m.data = {code:Code.OK};
				_cliente.sendMessage(m);
			},function (e:SQLError):void {
				m.data = {code:Code.NO};
				_cliente.sendMessage(m);
			});
		}
		
		private function ticket(e:Event,m:Message):void
		{
			_model.ventas.ticket(m.data,function (ticket:Object):void {
				if (ticket) {
					ticket.hora = DateFormat.format(ticket.tiempo,DateFormat.masks["default"]);
					_model.ventas.ventas_elementos(m.data,function (premios:SQLResult):void {
						m.data = {tk:ticket,prm:premios.data}
						_cliente.sendMessage(m);
					});
				} else {
					m.data = {code:Code.NO_EXISTE};
					_cliente.sendMessage(m);
				}
			});
		}
		
		private function sorteo_editar(e:Event,m:Message):void {
			_model.sorteos.editar_abierta(m.data,function (r:SQLResult):void {
				var estado:String = m.data.abierta?"ABRE":"CIERRA"
				Loteria.console.log(StringUtil.format('USUARIO {0}: {1} SORTEO #{2}',usuario.usuario,estado,m.data.sorteo))
				_model.mSorteos.iniciar();
				m.data = r.rowsAffected;
				_cliente.sendMessage(m);
			});
		}
		
		private function monitor(e:Event,m:Message):void {
			_model.ventas.monitor(m.data,function (r:Object):void {
				var usuarios:Array = r.t || [];
				if (usuarios.length>0) {
					m.data = {reporte:"usuarios",data:usuarios}
				_cliente.sendMessage(m);

				var numeros:Array = r.n || [];
				var len:int = numeros.length;
				var batch:int = 200;
				var max:int = Math.ceil(len/batch);
				var i:int
				for(var index:int = 0; index < max; index++) 	{
					i=index*batch
					m.data = {reporte:"numeros",data:numeros.slice(i,i+batch)}
					_cliente.sendMessage(m);
				}
				}
				m.data = {reporte:"end"}
				_cliente.sendMessage(m);
				measure(m.command);
			});
		}
		
		private function banca_editar(e:Event,m:Message):void {
			_model.bancas.editar(m.data,function (r:SQLResult):void {
				m.data = r.rowsAffected>0?Code.OK:Code.INVALIDO;
				_cliente.sendMessage(m);
			});
		}
		
		private function banca_relacion(e:Event,m:Message):void {
			_model.bancas.relacion_pago(m.data,function (r:SQLResult):void {
				m.data = r.rowsAffected;
				_cliente.sendMessage(m);
			});
		}
		private function banca_remover(e:Event,m:Message):void {
			_model.bancas.editar(m.data,function (r:SQLResult):void {
				if (r.rowsAffected>0) m.data = {code:Code.OK};
				else m.data = {code:Code.NO};
				_cliente.sendMessage(m);
			});
		}
		
		private function lsorteos(e:Event,m:Message):void {
			m.data = _model.sistema.sorteos;
			_cliente.sendMessage(m);
		}
		
		private function reporte_general(e:Event,m:Message):void {
			if (m.data.g==0) _model.reportes.general(m.data.s,result);
			else if (m.data.g==1) _model.reportes.general_fecha(m.data.s,result);
			else if (m.data.g==2) _model.reportes.usuarios(m.data.s,result);
			else if (m.data.g==3) _model.reportes.comerciales(m.data.s,result);
			
			function result (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			}
		}
		
		private function venta_anular(e:Event,m:Message):void {
			var a:Array = new Array(m.data.length);
			for (var i:int = 0; i < a.length; i++) {
				a[i] = {ticketID:m.data[i],tiempo:_model.ahora}
			}
			//TODO comparar la suma de los tickets enviados, con la suma
			// de las lineas afectadas por los resultados del SQL
			// regresar la diferencia o el total de tickets anulados
			_model.ventas.anular_batch(a,function (r:Vector.<SQLResult>):void {
				var t:int;
				for each (var a:SQLResult in r) {
					t += a.rowsAffected;
				}
				m.data = t;
				_cliente.sendMessage(m);
			},onError);
			
			function onError(e:SQLError):void {
				m.data = 0;
				_cliente.sendMessage(m);
				//Loteria.console.log(e.toString());
			}
		} 
		
		private function bancas_nombres(e:Event,m:Message):void {
			_model.bancas.nombres(m.data,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}
		
		override protected function dispose():void {
			_model.mSorteos.removeEventListener(Event.OPEN,sorteo_abierto);
			_model.mSorteos.removeEventListener(Event.CLOSE,sorteo_cerrado);
		}
		
		private function taquilla_editar(e:Event,m:Message):void {
			_model.taquillas.editar(m.data,function (r:SQLResult):void {
				m.data = Code.OK;
				_cliente.sendMessage(m);
			},function (e:SQLError):void {
				m.data = {code:Code.DUPLICADO};
				_cliente.sendMessage(m);
			});
		}
		
		private function taquilla_lock(event:Event,m:Message):void {
			_model.taquillas.fingerlock(m.data,function (res:SQLResult):void {
				m.data = res.rowsAffected
				_cliente.sendMessage(m)
			})
		}
		private function taquilla_clear (event:Event,m:Message):void {
			_model.taquillas.fingerclear(m.data,function (res:SQLResult):void {
				m.data = res.rowsAffected
				_cliente.sendMessage(m)
			})
		}
		
		private function tope_nuevo(e:Event,m:Message):void {
			if (m.data.compartido==2) m.data.bancaID = 0;
			if (m.data.elemento!="") {
				if (m.data.sorteo==0) {
					m.data = {error:'Es obligatorio indicar el sorteo al que sera asignado el tope por numero'}
					return _cliente.sendMessage(m);
				}
				var elemento:Object = _model.sistema.elemento_num(m.data.elemento,m.data.sorteo)
				if (!elemento) {
					m.data = {error:'Numero invalido o no existe para el sorteo seleccionado'}
					return _cliente.sendMessage(m);
				} else m.data.elemento = elemento.elementoID
			} else m.data.elemento = 0
			_model.topes.nuevo(m.data,function (id:int):void {
				m.data = id;
				_cliente.sendMessage(m);
			});
		}
		
		private function topes(e:Event,m:Message):void {
			_model.topes.topes(m.data,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}
		
		private function reporte_sorteo(e:Event,m:Message):void {
			_model.reportes.sorteo(m.data,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});			
		}
		
		private function reporte_sorteo_global (e:Event,m:Message):void {
			_model.servidor.sorteos({adminID:usuario.adminID},function (s:SQLResult):void {
				if (s.data) {
					//m.data.d.sorteo = s.data[0].sorteoID;
					m.data.d.aID = usuario.adminID;
					if (m.data.a==1) _model.reportes.sorteo_global_fecha(m.data.d,result);
					else if (m.data.a==2) _model.reportes.sorteo_global_grupo(m.data.d,result);
					else _model.reportes.sorteo_global(m.data.d,result);
				} else {
					//null
				}
				
				function result (r:SQLResult):void {
					m.data = r.data;
					_cliente.sendMessage(m);
				};
			});
		}
		private function premioBot_lista(e:Event,m:Message):void {
			 _model.sorteos.bot_lista(m.data.operadora,function (r:SQLResult):void {
					  sendMessage(m,r.data)
					})
		}
		private function premioBot_nuevo(e:Event,m:Message):void {
		  _model.sorteos.bot_nuevo(m.data.operadora,m.data.sorteo,m.data.relacion,m.data.fecha,usuario,
        function (error:SQLError,registro:Object):void {
          if (error) Loteria.console.log("ERROR: "+error.details)
          else sendMessage(m,registro)
        })
		}
		private function premioBot_remover(e:Event,m:Message):void {
		  _model.sorteos.bot_remover(m.data.botID,usuario.adminID,function (r:SQLResult):void {
        sendMessage(m,r)
      })
		}
		
		private function reporte_taquilla(e:Event,m:Message):void {
			//TODO: validar que la taquilla pertenezca a la banca
			_model.reportes.taquilla(m.data,reporte);
			
			function reporte(r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			}
		}
		
		private function reporte_banca(e:Event,m:Message):void {
			if (m.data.g==0) _model.reportes.comercial(m.data.s,result);
			//else  _model.reportes.fecha(m.data.s,result);
			
			function result (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
				measure(m.command);
			}
		}		
		private function reporte_recogedor(e:Event,m:Message):void {
			if (m.data.g==0) _model.reportes.comercial(m.data.s,result);
			//else  _model.reportes.fecha(m.data.s,result);
			
			function result (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
				measure(m.command);
			}
		}
		
		
		private function sorteo_cerrado(e:Event,s:Sorteo):void {
			msg.command = "sorteo-cierra";
			msg.data = s;
			_cliente.sendMessage(msg);
		}
		
		private function sorteo_abierto(e:Event,s:Sorteo):void {
			msg.command = "sorteo-abre";
			msg.data = s;
			_cliente.sendMessage(msg);
		}
		
		private function taquillas(e:Event,m:Message):void {
			_model.taquillas.buscar(m.data,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}
		private function taquilla_nueva(e:Event,m:Message):void {
			_model.taquillas.nueva(m.data,function (id:int):void {
				m.data = id;
				_cliente.sendMessage(m);
			},function (er:SQLError):void {
				m.data = {code:er.errorID,m:er.message};
				_cliente.sendMessage(m);
			});	
		}		
		
		private function bancas(e:Event,m:Message):void {
			_model.bancas.buscar(m.data,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}
		private function banca_nueva(e:Event,m:Message):void {
			_model.bancas.nueva(m.data,function (r:SQLResult):void {
				m.data = r.lastInsertRowID;
				_cliente.sendMessage(m);
			},function (er:SQLError):void {
				Loteria.console.log("ERROR",er.details,er.message);
				m.data = er.detailID*-1;
				_cliente.sendMessage(m);
			});
		}
		
		private function usuarios(e:Event,m:Message):void {
			_model.usuarios.usuarios(m.data,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}
		
		private function usuario_nuevo(e:Event,m:Message):void {
			var cid:int = m.data.cid;
			delete m.data.cid;
			_model.usuarios.nuevo(m.data,function (id:int):void {
				if (m.data.tipo==1) {
					_model.comercializadora.linkUsuario({
						cID:cid,
						uID:id
					},null);
				}
				m.data = id;
				_cliente.sendMessage(m);
			});
		}
		
		
		private static var _solPremios:Object = {};
		private var solPremios:Array;
		private function initSolicitudesPremios():void
		{
			if (_solPremios.hasOwnProperty(usuario.usuario)) {
				solPremios = _solPremios[usuario.usuario];
			} else {
				solPremios = [];
				_solPremios[usuario.usuario] = solPremios; 
			}
		}	
		
		private function sorteo_premiar(e:Event,m:Message):void {
			if (m.data.sorteoID in _model.ventas.sorteos_premiados) {
				m.data = {code:Code.DUPLICADO};
				_cliente.sendMessage(m);
				return;
			}
			var s:Object = {sorteoID:m.data.sorteoID};	
			_model.sorteos.premio(s,function (r:SQLResult):void {				
				if (r.data) {
					if (r.data[0].abierta==true) {
						m.data = {code:Code.CERRADO};
						_cliente.sendMessage(m);
					} else if (r.data[0].ganador>0) {
						_model.ventas.sorteos_premiados[m.data.sorteoID]=true;
						m.data = {code:Code.DUPLICADO};
						_cliente.sendMessage(m);
					} else {
						if (_model.mSorteos.verificarSolicitud(solPremios,m.data.sorteoID)) {							
							var e:Elemento = ObjectUtil.find(m.data.elemento,"elementoID",_model.sistema.elementos);
							Loteria.console.log(usuario.usuario,"PREMIA SORTEO","#"+m.data.sorteoID,"NUM",e.descripcion);
							_model.sorteos.sorteo(s,function (sorteo:Sorteo):void {
								var premiador:Object = Loteria.setting.premios.premiacion[sorteo.sorteo] || Loteria.setting.premios.premiacion[0];
								var numSol:int = _model.mSorteos.solicitudPremio(sorteo,m.data.elemento,usuario.nivel==1?100:20);
								if (numSol>=premiador.puntos) {
									_model.ventas.premiar(sorteo,e,function (srt:Object):void {
										m.data = {code:Code.OK};
										_cliente.sendMessage(m);										
									//verificar si estaba pendiente
										WS.emitir(WS.premios,StringUtil.format('*SORTEO PENDIENTE PREMIADO*\n#{0} {1}',sorteo.sorteoID,sorteo.descripcion))
									/* if (SorteosModel.sorteosPendientes.indexOf(sorteo.sorteoID)>-1) {
									} */
									});
								} else {
									m.data = {code:Code.NO};
									_cliente.sendMessage(m);
								}
							});
						} else {
							m.data = {code:Code.INVALIDO};
							_cliente.sendMessage(m);
						}
					}
				} else {
					m.data = {code:Code.NO_EXISTE};
					_cliente.sendMessage(m);
				}
			});
		}		
		private function sorteo_reiniciar(e:Event,m:Message):void {
			Loteria.console.log(usuario.usuario,"REINICIA SORTEO","#"+m.data.sorteoID);
			_model.sorteos.sorteo(m.data,function (sorteo:Sorteo):void {
				_model.ventas.reiniciar_sorteo(m.data,function (r:SQLResult):void {
					if (r) {
						var i:int = solPremios.indexOf(m.data.sorteoID);
						solPremios.removeAt(i);
						_model.mSorteos.reiniciarPuntos(sorteo);
						var body:String = StringUtil.format(Mail.PREMIO_REINICIADO,
							sorteo.sorteoID, //0
							sorteo.descripcion, //1
							sorteo.fecha, //2
							usuario.usuario //3
						);
						WS.enviar(WS.admin,body);
						m.data = r.rowsAffected;
						_cliente.sendMessage(m);
					} else {
						m.data = {code:Code.OCUPADO,s:sorteo};
						_cliente.sendMessage(m);
					}
				});
			});
		}
		private function sorteo_remover(e:Event,m:Message):void {
			_model.sorteos.remover_sorteo(m.data,function (res:Vector.<SQLResult>):void {
				_model.sistema.update_elementos();
				_model.sistema.update_sorteos();
				m.data = Code.OK;
				_cliente.sendMessage(m);
			});
		}
		
		private function sorteo(e:Event,m:Message):void {
			_model.sorteos.sorteo(m.data,function (s:Sorteo):void {
				m.data = s;
				_cliente.sendMessage(m);
			});
		}
		private function sorteos(e:Event,m:Message):void {
			m.data.adminID = usuario.adminID;
			_model.sorteos.sorteos(m.data,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}
		private function elementos(e:Event,m:Message):void {
			if (m.data.hasOwnProperty("sorteo")) {
				m.data = _model.sistema.elementos_sorteo(m.data.sorteo);
				_cliente.sendMessage(m);
			} else if (m.data.hasOwnProperty("msorteo")) {
				m.data = _model.sistema.elementos_sorteo_min(m.data.msorteo);
				_cliente.sendMessage(m);
			} else if (m.data.hasOwnProperty("csorteo")) {
				var sorteos:Array = _model.sistema.elementos_sorteo_min(m.data.csorteo);
				m.data = sorteos.map(function (item:Object,a:*,b:*):* {
					var i:Object = {
						id: item.id,
						n: item.n,
						d: item.d
					}
					if (item.d==item.n) delete i.d
					return i;
				})
				_cliente.sendMessage(m);
			} else if (m.data.hasOwnProperty("sorteos")) {
				var elm:Vector.<Elemento> =_model.sistema.elementos_sorteos(m.data.sorteos); 
				while (elm.length>0) {
					m.data = elm.splice(0,100);
					_cliente.sendMessage(m);
				}
				m.data = "end";
				_cliente.sendMessage(m);
			}
		}
		private function elemento_nuevo(e:Event,m:Message):void {
			_model.sistema.elemento_nuevo(m.data,function (r:SQLResult):void {
				m.data = r.lastInsertRowID;
				_cliente.sendMessage(m);
			});
		}
		private function elemento_nv_zodiaco(e:Event,m:Message):void {
			for each (var d:Object in m.data.numeros) {
				d.sorteo = m.data.sorteo;
				d.adicional = m.data.adicional;
			}
			
			var s:Object = {sorteo:m.data.sorteo};
			_model.sistema.elementos_limpiar(s,function (r:SQLResult):void {
				_model.sistema.elemento_nuevo(m.data.numeros,function (r:*):void {
					m.data = r.length;
					_model.sorteos.convertir_zodiaco(s,null);
					_model.sistema.update_elementos();
					_model.sistema.update_sorteos();
					_cliente.sendMessage(m);
				});
			});
		}
		
		private function sorteo_registrar(e:Event,m:Message):void {
			var v:Vector.<int> = new Vector.<int>;
			_model.sorteos.pre_sorteos(null,function (r:SQLResult):void {
				var sorteos:Array = m.data.sorteos;
				_model.sorteos.sorteos({gfecha:m.data.fecha},function (srt:SQLResult):void {
					var i:int, j:int;
					//validar duplicados
					if (srt.data) { // sorteos registrados
						for (i = m.data.sorteos.length-1; i >= 0; i--) {
							for (j = 0; j < srt.data.length; j++) {
								if (sorteos[i]==srt.data[j].sorteo) sorteos.removeAt(i);
							}
						}	
					}
					if (sorteos.length>0) {
						// procesar presorteos
						for (i = 0; i < sorteos.length; i++) {
							for (j = 0; j < r.data.length; j++) {
								if (sorteos[i]==r.data[j].sorteo) {
									v.push(r.data[j].sorteoID);
								}
							}
						}
						//registrar
						_model.sorteos.registrar(v,m.data.fecha,function (results:Vector.<SQLResult>):void {
							m.data = [];
							for each (var r:SQLResult in results) m.data.push(r.lastInsertRowID);
							_model.mSorteos.iniciar();
							_cliente.sendMessage(m);
						});
					} else {
						m.data = [];
						_cliente.sendMessage(m);
					}
				});
			});
			
		}
		
		private function presorteo_nuevo(e:Event,m:Message):void {
			_model.sorteos.nuevo(m.data,function (r:SQLResult):void {
				m.data = r.lastInsertRowID;
				_cliente.sendMessage(m);
			});
		}
		private function presorteo_remover(e:Event,m:Message):void {
			_model.sorteos.remover(m.data,function (r:SQLResult):void {
				m.data = r.rowsAffected;
				_cliente.sendMessage(m);
			});	
		}
		
		private function presorteos(e:Event,m:Message):void {
			_model.sorteos.pre_sorteos(null,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}
		
		private function inicio(e:Event,m:Message):void {
			var now:Date = new Date;
			if (!m.data) m.data = {fecha:DateFormat.format(now)};
			_model.servidor.est_inicio(m.data,function (r:SQLResult):void {
				if (r.data) {
					m.data = {
						data:r.data,
						time:DateFormat.format(now,DateFormat.masks.mediumTime)
					};
				} else m.data = {code:Code.VACIO,time:now.time};
				_cliente.sendMessage(m);
			});
		}
		

	}
}