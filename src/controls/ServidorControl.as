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
					Loteria.console.log(usr.usuario,"inicia sesion");
					m.data = {
						code:Code.OK,
						usr:usr
					};
					if (usr.nivel==1) addListeners();
					else addListeners2();
					_cliente.sendMessage(m);
					
					ObjectUtil.clear(m.data);
					m.command = "init";					
					m.data.sorteos = _model.sistema.sorteos;
					
					if (Loteria.setting.servidor!="local") {
						if (usr.nivel==1) {
							var u:Object = Loteria.setting.plataformas;
							WS.enviar(Loteria.setting.plataformas.usuarios.admin,StringUtil.format("[{1}][JV] Administrador *{0}* Inicio sesion",usr.usuario,Loteria.setting.servidor));
						} else if (usr.nivel==2) {
							WS.enviar(Loteria.setting.plataformas.usuarios.admin,StringUtil.format("[{1}][JV] Premiador *{0}* Inicio sesion",usr.usuario,Loteria.setting.servidor));
						}
					}
					
					_model.servidor.numeros({adminID:usr.adminID},function (r:SQLResult):void {
						//m.data.elem = r.data;
						_cliente.sendMessage(m);
					});
					
					initSolicitudesPremios();
				} else {
					m.data = {code:Code.NO_EXISTE}
					_cliente.sendMessage(m);
				}
			});
		}
		
		private function addListeners2():void {
			addEventListener("inicio",inicio);
			addEventListener("lsorteos",lsorteos);
			addEventListener("sorteo",sorteo);
			addEventListener("sorteos",sorteos);
			addEventListener("sorteo-registrar",sorteo_registrar);
			addEventListener("sorteo-premiar",sorteo_premiar);
			addEventListener("sorteo-reiniciar",sorteo_reinciar);
			addEventListener("sorteo-editar",sorteo_editar);
			addEventListener("sorteo-num-hist",sorteo_numHist);
			addEventListener("sorteo-monitor-vnt",sorteo_monitor_vnt);
			addEventListener("elementos",elementos);
			
			addEventListener("monitor",monitor);			
			addEventListener("ticket",ticket);
			
			addEventListener("reporte-sorteo",reporte_sorteo);			
			addEventListener("reporte-sorteo-global",reporte_sorteo_global);
		}
		
		private function addListeners():void {
			addEventListener("inicio",inicio);
			
			addEventListener("lsorteos",lsorteos);
			addEventListener("presorteos",presorteos);
			addEventListener("presorteo-nuevo",presorteo_nuevo);
			addEventListener("presorteo-remover",presorteo_remover);
			
			addEventListener("sorteo",sorteo);
			addEventListener("sorteos",sorteos);
			addEventListener("sorteo-registrar",sorteo_registrar);
			addEventListener("sorteo-premiar",sorteo_premiar);
			addEventListener("sorteo-reiniciar",sorteo_reinciar);
			addEventListener("sorteo-editar",sorteo_editar);
			addEventListener("sorteo-num-hist",sorteo_numHist);
			addEventListener("sorteo-monitor-vnt",sorteo_monitor_vnt);
			
			addEventListener("elemento-nuevo",elemento_nuevo);
			addEventListener("elementos",elementos);
			addEventListener("elemento-nuevo-zodiaco",elemento_nv_zodiaco);
			
			addEventListener("usuarios",usuarios);
			addEventListener("usuario-nuevo",usuario_nuevo);
			addEventListener("usuario-editar",usuario_editar);
			addEventListener("usuario-asignar",usuario_asignar);
			
			addEventListener("bancas",bancas);
			addEventListener("bancas-nombres",bancas_nombres);
			addEventListener("banca-nueva",banca_nueva);
			addEventListener("banca-editar",banca_editar);
			addEventListener("banca-relacion",banca_relacion);
			addEventListener("banca-remover",banca_remover);
			
			addEventListener("taquillas",taquillas);
			addEventListener("taquilla-nueva",taquilla_nueva);
			addEventListener("taquilla-editar",taquilla_editar);
			
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
				_model.mSorteos.iniciar();
				m.data = r.rowsAffected;
				_cliente.sendMessage(m);
			});
		}
		
		private function monitor(e:Event,m:Message):void {
			_model.ventas.monitor(m.data,function (r:Object):void {
				m.data = r;
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
				Loteria.console.log(e.toString());
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
		
		private function tope_nuevo(e:Event,m:Message):void {
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
					m.data.d.sorteo = s.data[0].sorteoID;
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
					if (r.data[0].ganador>0) {
						_model.ventas.sorteos_premiados[m.data.sorteoID]=true;
						m.data = {code:Code.DUPLICADO};
						_cliente.sendMessage(m);
					} else {
						if (_model.mSorteos.verificarSolicitud(solPremios,m.data.sorteoID)) {							
							Loteria.console.log(usuario.usuario,"PREMIA SORTEO","#"+m.data.sorteoID,"NUM",m.data.elemento);
							_model.sorteos.sorteo(s,function (sorteo:Sorteo):void {
								var premiador:Object = Loteria.setting.premios.premiacion[sorteo.sorteo] || Loteria.setting.premios.premiacion[0];
								var numSol:int = _model.mSorteos.solicitudPremio(sorteo,m.data.elemento,usuario.nivel==1?100:20);
								if (numSol>=premiador.puntos) {
									var e:Elemento = ObjectUtil.find(m.data.elemento,"elementoID",_model.sistema.elementos);
									var body:String = StringUtil.format(Mail.PREMIO_CONFIRMADO,
										sorteo.sorteoID, //0
										sorteo.descripcion, //1
										e.numero, //2
										usuario.usuario, //3
										Loteria.setting.servidor //4
									);
									//WS.emitir(Loteria.setting.plataformas.usuarios.premios,body);
									Mail.sendAdmin("[SRQ]["+sorteo.fecha+"] SORTEO PREMIADO",body,null);
									_model.ventas.premiar(sorteo,e,function (srt:Object):void {
										m.data = {code:Code.OK};
										_cliente.sendMessage(m);
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
		private function sorteo_reinciar(e:Event,m:Message):void {
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
							usuario.usuario, //3
							Loteria.setting.servidor //4
						);
						Mail.sendAdmin("[ADM] SORTEO REINICIADO",body,null);
						WS.enviar(Loteria.setting.plataformas.usuarios.admin,body);
						m.data = r.rowsAffected;
						_cliente.sendMessage(m);
					} else {
						m.data = {code:Code.OCUPADO,s:sorteo};
						_cliente.sendMessage(m);
					}
				});
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
			m.data = _model.sistema.elementos_sorteo(m.data.sorteo);
			_cliente.sendMessage(m);
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
			
			_model.sistema.elemento_nuevo(m.data.numeros,function (r:*):void {
				m.data = r.length;
				_cliente.sendMessage(m);
			});
			/*_model.sistema.elementos_limpiar({sorteo:m.data.sorteo},function (r:SQLResult):void {});*/
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