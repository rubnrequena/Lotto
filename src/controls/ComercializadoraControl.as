package controls
{
	import flash.data.SQLResult;
	import flash.errors.SQLError;
	
	import be.aboutme.airserver.Client;
	import be.aboutme.airserver.messages.Message;
	
	import helpers.Code;
	import helpers.DateFormat;
	import helpers.LTool;
	import helpers.Mail;
	import helpers.ObjectUtil;
	
	import models.ModelHUB;
	
	import starling.events.Event;
	import starling.utils.StringUtil;
	
	import vos.Elemento;
	import vos.Sorteo;
	import vos.Taquilla;
	import vos.Usuario;
	
	public class ComercializadoraControl extends Control
	{
		private var usuario:Usuario;
		
		public function ComercializadoraControl(cliente:Client, model:ModelHUB)
		{
			super(cliente, model);
			addEventListener("login",login);
		}
		
		private function taquilla_panic(e:Event,m:Message):void {
			m.data = {usuarioID:usuario.usuarioID};
			_model.taquillas.panic(m.data,function (numTaq:int):void {
				m.data = numTaq;
				_cliente.sendMessage(m);
				measure(m.command);
			});
		}
		private function taquilla_remover(e:Event,m:Message):void {
			if (usuario.tipo==1) m.data.usuarioID = usuario.usuarioID;
			m.data.bancaID = 0;
			m.data.papelera = m.data.papelera;
			_model.taquillas.editar(m.data,function (r:SQLResult):void {
				m.data = {code:r.rowsAffected};
				_cliente.sendMessage(m);
			});
		}
		
		private function taquilla_comisiones(e:Event,m:Message):void {
			//validar usuario y banca de taquilla
			_model.taquillas.comisiones(m.data,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}
		private function taquilla_comision_dl(e:Event,m:Message):void
		{
			_model.taquillas.comision_dl(m.data,function(r:SQLResult):void {
				m.data = r.rowsAffected;
				_cliente.sendMessage(m);
			});
		}
		
		private function taquilla_comision_nv(e:Event,m:Message):void
		{
			_model.taquillas.comision_nv(m.data,function(r:SQLResult):void {
				m.data.comID = r.lastInsertRowID;
				_cliente.sendMessage(m);
			});
		}
		private function conexiones(e:Event,m:Message):void {
			m.data = _model.taquillas.explorarClientes("usuarioID",usuario.usuarioID);
			_cliente.sendMessage(m);
		}
		
		private function transferir(e:Event,m:Message):void {
			_model.taquillas.transferir(m.data.taq,m.data.vnt,function (r:int):void {
				m.data = r;
				_cliente.sendMessage(m);
				measure(m.command);
			});
		}
		private function transferir_grupo (e:Event,m:Message):void {
			_model.bancas.transferir(m.data,function (r:SQLResult):void {
				m.data = r.rowsAffected;
				_cliente.sendMessage(m);
				if (r.rowsAffected>0) _model.bancas.force_update();
				measure(m.command);
			});
		}
		
		private function publicar(e:Event,m:Message):void {
			var taquillas:Array = m.data.taquillas;
			var items:Array = [];
			for each (var taq:int in taquillas) {
				var it:Object = {
					bancaID:m.data.bancaID,
						taquillaID:taq,
						sorteo:m.data.sorteo,
						publico:m.data.publicar
				};
				items.push(it);
			}
			_model.sorteos.publicar(items,function (r:Vector.<SQLResult>):void {
				m.data = r.length;
				_cliente.sendMessage(m);
			});
		}
		private function sorteos_publicos(e:Event,m:Message):void {
			_model.sorteos.publicos(m.data,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}
		private function sorteos_publicos_remover(e:Event,m:Message):void {
			_model.sorteos.publicos_remover(m.data,function (r:SQLResult):void {
				m.data = r.rowsAffected;
				_cliente.sendMessage(m);
			});
		}
		private function sorteos_publicos_editar(e:Event,m:Message):void {
			_model.sorteos.publicos_editar(m.data,function (r:SQLResult):void {
				m.data = r.rowsAffected;
				_cliente.sendMessage(m);
			});
		}
		
		private function monitor(e:Event,m:Message):void {
			m.data.usuarioID = usuario.usuarioID;
			_model.ventas.monitor(m.data,function (r:Object):void {
				m.data = r;
				_cliente.sendMessage(m);
				measure(m.command);
			});
		}
		
		private function sorteos(e:Event,m:Message):void {
			m.data.usuarioID = usuario.usuarioID;
			_model.sorteos.sorteos(m.data,function (r:SQLResult):void {
				m.data = r.data;
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
		
		private function sorteo_premiar (e:Event,m:Message):void {
			if (m.data.sorteoID in _model.ventas.sorteos_premiados) {
				m.data = {code:Code.DUPLICADO};
				_cliente.sendMessage(m);
				return;
			}
			
			var s:Object = {sorteoID:m.data.sorteoID};
			_model.sorteos.sorteo(s,function (sorteo:Sorteo):void {
				if (sorteo) {
					if (_model.ahora<sorteo.cierra) {
						m.data = {code:Code.CERRADO};
						_cliente.sendMessage(m);
						return;
					}
					if (sorteo.ganador>0) {
						m.data = {code:Code.DUPLICADO};
						_cliente.sendMessage(m);
					} else {
						if (_model.mSorteos.verificarSolicitud(solPremios,sorteo.sorteoID)) {							
							var premiador:Object = Loteria.setting.premios.premiacion[sorteo.sorteo] || Loteria.setting.premios.premiacion[0];
							var numSol:int = _model.mSorteos.solicitudPremio(sorteo,m.data.elemento,2);
							if (numSol>=premiador.puntos) {
								var e:Elemento = ObjectUtil.find(m.data.elemento,"elementoID",_model.sistema.elementos);
								Mail.sendAdmin("PREMIACION CONFIRMADA POR USUARIO "+DateFormat.format(null),StringUtil.format(Mail.PREMIO_CONFIRMADO,sorteo.sorteoID,sorteo.descripcion,e.numero,usuario.nombre,Loteria.setting.servidor),null);
								_model.ventas.premiar(sorteo,e,function (sorteo:Object):void {
									m.data = {code:Code.OK};
									_cliente.sendMessage(m);
								});
							} else {
								m.data = {code:Code.NO}
								_cliente.sendMessage(m);
							}
						} else {
							m.data = {code:Code.INVALIDO};
							_cliente.sendMessage(m);
						}
					}
				}
			});
		}
		private function taquilla_editar(e:Event,m:Message):void {
			_model.taquillas.editar(m.data,function (r:SQLResult):void {
				m.data = Code.OK;
				_cliente.sendMessage(m);
			},function (e:SQLError):void {
				m.data = e.detailID;
				_cliente.sendMessage(m);
			});
		}
		private function taquilla_nueva(e:Event,m:Message):void {
			//m.data.usuarioID = usuario.usuarioID;
			_model.taquillas.nueva(m.data,function (id:int):void {
				m.data = id;
				_cliente.sendMessage(m);
			},function (er:SQLError):void {
				m.data = {code:er.errorID,m:er.message};
				_cliente.sendMessage(m);
			});	
		}	
		private function banca_editar(e:Event,m:Message):void {
			_model.bancas.editar(m.data,function (r:SQLResult):void {
				/*if (r.rowsAffected>0) {
					var b:Banca = LTool.findBy("bancaID",m.data.bancaID,_model.bancas.bancas);
					if (m.data.hasOwnProperty("activa")) b.activa = m.data.activa;
					if (m.data.hasOwnProperty("nombre")) b.nombre = m.data.nombre;
					if (m.data.hasOwnProperty("clave")) b.clave = m.data.clave;
					if (m.data.hasOwnProperty("comision")) b.comision = m.data.comision;
				}*/
				if (r.rowsAffected>0) m.data.code = Code.OK;
				else m.data.code = Code.INVALIDO;
				_cliente.sendMessage(m);
			});
		}
		
		private function tope_remover(e:Event,m:Message):void {
			_model.topes.remover(m.data,function (r:SQLResult):void {
				m.data = r.rowsAffected;
				_cliente.sendMessage(m);
			});
		}
		
		private function tope_nuevo(e:Event,m:Message):void {
			m.data.usuarioID = usuario.usuarioID;
			if (m.data.compartido==2) m.data.bancaID = 0;
			_model.topes.nuevo(m.data,function (id:int):void {
				m.data = id;
				_cliente.sendMessage(m);
			});
		}
		
		private function topes(e:Event,m:Message):void {
			m.data.usuarioID = usuario.usuarioID;
			_model.topes.topes(m.data,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
				measure(m.command);
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
		private function taquillas(e:Event,m:Message):void {
			//if (usuario.tipo!=2) m.data.usuarioID = usuario.usuarioID;
			_model.taquillas.buscar(m.data,function (r:SQLResult):void {
				if (r.data.length>200) {
					var block:int = Math.ceil(r.data.length/200);
					for (var i:int = 0; i < block; i++) {
						m.data = r.data.splice(0,100);
						_cliente.sendMessage(m);
					}
					m.data = {code:Code.OK};
					_cliente.sendMessage(m);
				} else {
					m.data = r.data;
					_cliente.sendMessage(m);
				}
			});
		}
		
		private function login(e:Event,m:Message):void {
			_model.comercializadora.login(m.data,function (u:Usuario):void {
				if (u) {
					usuario = u;
					if (u.activo==-10) {
						m.data = {code:u.activo}
						_model.balance.validarUsuario({usID:u.usID},function (r:SQLResult):void {
							m.data.bal = r.data[0];
							_cliente.sendMessage(m);
						});
					} else if (u.activo>Usuario.USUARIO_SUSPENDIDO) {
						controlID = u.usuarioID;
						
						_model.sorteos.sorteos({usuarioID:u.usuarioID},function (sorteos:SQLResult):void {
							_model.comercializadora.usuarios({usuarioID:u.usuarioID},function (bancas:SQLResult):void {
								m.data = {
									us:u,
									bn:bancas.data,
									st:sorteos.data
								};
								addListeners();
								measure(m.command);
								_cliente.sendMessage(m);
							});
						});
						
						initSolicitudesPremios();
					} else {
						m.data = {code:Code.INVALIDO};
						_cliente.sendMessage(m);	
					}
				} else {
					m.data = {code:Code.NO_EXISTE};
					_cliente.sendMessage(m);
				}
			});
		}
		
		private function addListeners():void {
			
			addEventListener("inicio",inicio);			
			addEventListener("sorteos",sorteos);
			addEventListener("sorteo-premiar",sorteo_premiar);
			addEventListener("elementos",elementos);
			
			addEventListener("taquillas",taquillas);
			addEventListener("taquilla-editar",taquilla_editar);
			addEventListener("taquilla-nueva",taquilla_nueva);
			addEventListener("taquilla-panic",taquilla_panic);
			addEventListener("taquilla-remover",taquilla_remover);
			
			addEventListener("taquilla-comisiones",taquilla_comisiones);
			addEventListener("taquilla-comision-nv",taquilla_comision_nv);
			addEventListener("taquilla-comision-dl",taquilla_comision_dl);
			
			addEventListener("taquilla-flock",taquilla_flock);
			addEventListener("taquilla-fpclear",taquilla_fpclear);
			
			addEventListener("topes",topes);
			addEventListener("tope-nuevo",tope_nuevo);
			addEventListener("tope-remover",tope_remover);
			
			addEventListener("usuario-nuevo",usuario_nuevo);
			addEventListener("usuario-editar",usuario_editar);
			addEventListener("usuario-grupos",usuario_grupos);
			
			addEventListener("banca-grupo",banca_grupo);
			addEventListener("banca-nueva",banca_nueva);
			addEventListener("banca-editar",banca_editar);
			addEventListener("banca-remover",grupo_remover);
			
			addEventListener("monitor",monitor);
			
			addEventListener("sorteos-publicos",sorteos_publicos);
			addEventListener("pb_remover",sorteos_publicos_remover);
			addEventListener("pb_editar",sorteos_publicos_editar);
			addEventListener("publicar",publicar);
			
			addEventListener("transferir",transferir);
			addEventListener("transferir-grupo",transferir_grupo);
			addEventListener("conexiones",conexiones);
			
			addEventListener("reporte-general",reporte_general);
			addEventListener("reporte-banca",reporte_banca);
			addEventListener("reporte-recogedor",reporte_recogedor);
			addEventListener("reporte-taquilla",reporte_taquilla);
			
			addEventListener("reporte-ventas",reporte_ventas);
			addEventListener("reporte-diario",reporte_diario);
			addEventListener("reporte-cobros",reporte_cobros);
			addEventListener("reporte-subcobros",reporte_cobros);
			
			//addEventListener("reporte-usuario",reporteUsuario); obsoleto
			
			addEventListener("permiso-nuevo",permiso_nuevo);
			addEventListener("permiso-update",permiso_update);
			addEventListener("permiso-remove",permiso_remove);
			addEventListener("permisos",permisos);			
			
			addEventListener("venta-premios",venta_premios);
			addEventListener("venta-anular",venta_anular);
			
			addEventListener("sms-nuevo",sms_nuevo);
			addEventListener("sms-bandeja",sms_bandeja);
			addEventListener("sms-leer",sms_leer);
			addEventListener("sms-respuestas",sms_respuestas);
			
			addEventListener("balance-padre",balance_padre);
			addEventListener("balance-add",balance_add);
			addEventListener("balance-clientes",balance_clientes);
			addEventListener("balance-us",balance_us);
			addEventListener("balance-pagos",balance_pagos);
			addEventListener("balance-remover",balance_remover);
			addEventListener("balance-pago",balance_pago);
			addEventListener("balance-ppagos",balance_ppagos);
			addEventListener("balance-confirmacion",balance_confirmacion);
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
		private function balance_ppagos(e:Event,m:Message):void
		{
			m.data = {};
			m.data.rID = usuario.usID;
			m.data.inicio = "2018-01-01";
			m.data.fin = "2900-12-31";
			m.data.c = 0;
			_model.balance.pagos_comercial(m.data,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}
		private function balance_pago(e:Event,m:Message):void
		{
			m.data.usID = usuario.usID;
			m.data.fecha = DateFormat.format(_model.ahora);
			m.data.cdo = 0;
			m.data.tiempo = _model.ahora;
			m.data.monto = Math.abs(m.data.monto)*-1;
			_model.balance.nuevo(m.data,function (r:SQLResult):void {
				m.data.balID = r.lastInsertRowID;
				_cliente.sendMessage(m);
			});
		}
		private function balance_remover(e:Event,m:Message):void
		{
			m.data.rID = usuario.usID;
			_model.balance.remover(m.data,function (r:SQLResult):void {
				m.data = r.rowsAffected;
				_cliente.sendMessage(m);
			});
		}
		
		private function balance_pagos(e:Event,m:Message):void
		{
			m.data.rID = usuario.usID;
			m.data.c = 1;
			_model.balance.pagos_comercial(m.data,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}
		
		private function balance_us(e:Event,m:Message):void {
			m.data.rID = usuario.usID;
			m.data.lm = 100;
			_model.balance.usID(m.data,function (r:SQLResult):void {
				if (r.data) {
					var c:String = String(m.data.usID).charAt(0);
					var _id:int = int(String(m.data.usID).slice(1));
					m.data = {bl:r.data};
					if (c=="g") {
						m.data.us = LTool.findBy("bancaID",_id,_model.bancas.bancas);
						_cliente.sendMessage(m);
					} else if (c=="u") {
						_model.usuarios.usuarios({id:_id},function (r:SQLResult):void {
							m.data.us = r.data[0];
							_cliente.sendMessage(m);
						});
					}
				} else {
					m.data = {code:Code.VACIO};
					_cliente.sendMessage(m);
				}
			});
		}
		
		private function balance_clientes(e:Event,m:Message):void
		{
			m.data = {usID:usuario.usID};
			_model.balance.cm_clientes(m.data,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}
		
		private function balance_add(e:Event,m:Message):void
		{
			m.data.resID = usuario.usID;
			m.data.fecha = DateFormat.format(_model.ahora);
			m.data.tiempo = _model.ahora;
			_model.balance.nuevo(m.data,function (r:SQLResult):void {
				m.data.balID = r.lastInsertRowID;
				_cliente.sendMessage(m);
			});
		}
				
		private function balance_padre(e:Event,m:Message):void {
			m.data = {usID:usuario.usID,lm:10};
			_model.balance.usID(m.data,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}
		private function reporte_cobros(e:Event,m:Message):void {
			//if (m.data.g==1) _model.reportes.general_fecha(m.data.s,result);
			if (m.data.g==2) {
				m.data.s.cid = usuario.usuarioID;				
				_model.reportes.cbr_usuarios(m.data.s,result);
			}
			else if (m.data.g==3) _model.reportes.cbr_grupos(m.data.s,result);
			//else if (m.data.g==3) _model.reportes.cbr_comerciales(m.data.s,result);
			
			function result (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
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
		
		private function reporte_general(e:Event,m:Message):void {
			m.data.s.comercial = usuario.usuarioID;
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
		
		private function banca_grupo(e:Event,m:Message):void
		{
			m.data = LTool.findBy("bancaID",m.data.bancaID,_model.bancas.bancas);
			_cliente.sendMessage(m);
		}		
		
		private function usuario_grupos(e:Event,m:Message):void
		{
			m.data = LTool.exploreBy("usuarioID",m.data.usuarioID,_model.bancas.bancas).sortOn("papelera","activa","nombre");
			_cliente.sendMessage(m);
		}
		
		private function usuario_nuevo(e:Event,m:Message):void
		{
			m.data.tipo = 1;
			//m.data.renta = usuario.renta;
			_model.usuarios.nuevo(m.data,function (id:int):void {
				m.data = id;
				_cliente.sendMessage(m);
				
				_model.comercializadora.linkUsuario({
					cID:usuario.usuarioID,
					uID:id
				},null);
			});
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
		
		private function grupo_remover(e:Event,m:Message):void {
			_model.bancas.editar(m.data,function (r:SQLResult):void {
				if (r.rowsAffected>0) m.data = {code:Code.OK};
				else m.data = {code:Code.NO};
				_cliente.sendMessage(m);
			});
		}
		
		private function elementos(e:Event,m:Message):void {
			m.data = {usuarioID:usuario.usuarioID};
			_model.sistema.elementos_us(m.data,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}		
		
		private function inicio(e:Event,m:Message):void {
			m.data = {usuarioID:usuario.usuarioID,fecha:DateFormat.format(_model.ahora)};
			
			_model.reportes.diario(m.data,function (r:SQLResult):void {
				if (r.data) {
					m.data = {
						data:r.data,
						time:_model.ahora
					};
				} else m.data = {code:Code.VACIO,time:_model.ahora};
				_cliente.sendMessage(m);
				measure(m.command);
			});
		}
		
		private function taquilla_fpclear(e:Event,m:Message):void {
			m.data = m.data || {};
			//m.data.usuarioID = usuario.usuarioID;
			_model.taquillas.fingerClear_usuario(m.data,function (r:SQLResult):void {
				m.data.ok = r.rowsAffected;
				_cliente.sendMessage(m);
			});
		}
		
		private function taquilla_flock(e:Event,m:Message):void {
			m.data = m.data || {};
			m.data.usuarioID = usuario.usuarioID;
			_model.taquillas.fingerlock_usuario(m.data,function (r:SQLResult):void {
				m.data.ok = r.rowsAffected;
				_cliente.sendMessage(m);
			});
		}
		
		private function venta_anular(e:Event,m:Message):void {
			//validar ticket
			delete m.data.bancaID;
			_model.ventas.ticket(m.data,function (ticket:Object):void {
				m.data.codigo = m.data.codigo || 0;
				if (ticket && ticket.usuarioID==usuario.usuarioID && ticket.codigo==m.data.codigo) {
					_model.ventas.ventas_elementos({ticket:ticket.ticketID},function (tventas:SQLResult):void {
						var sorteoCerrado:Boolean=false;
						var cierre:Number = _model.ahora;
						for (var i:int = 0; i < tventas.data.length; i++) {
							if (tventas.data[i].cierra<cierre) { sorteoCerrado = true; break; }
						}
						
						if (sorteoCerrado==false) { //validar sorteos
							m.data.tiempo = _model.ahora;
							delete m.data.codigo;
							var _taq:Taquilla = _model.taquillas.buscarCliente("taquillaID",ticket.taquillaID);
							_model.ventas.anular(m.data,_taq,function (r:SQLResult):void {
								_model.bMan.clear(_taq.bancaID); //TODO OPT: DESCONTAR EL MONTO DE CADA ANIMAL
								_model.uMan.clear(usuario.usuarioID); //TODO OPT: DESCONTAR EL MONTO DE CADA ANIMAL
								m.data = r.lastInsertRowID;
								_cliente.sendMessage(m);
								
								if (_taq) {
									m.command = "venta-anular-banca";
									_model.taquillas.sendTo(_taq.taquillaID,m);
								}
							},function (e:SQLError):void {
								Loteria.console.log("ERROR: TICKET",m.data.ticketID," PREVIAMENTE ANULADO");
								m.data.code = Code.DUPLICADO;
								_cliente.sendMessage(m);
							});	
						} else {
							m.data.code = Code.INVALIDO;
							_cliente.sendMessage(m);
						}
					});	
				} else {
					m.data.code = Code.NO_EXISTE;
					_cliente.sendMessage(m);
				}
			});
		}
		private function venta_premios(e:Event,m:Message):void {			
			_model.ventas.ticket(m.data,function (ticket:Object):void {
				if (ticket && ticket.usuarioID==usuario.usuarioID) {
					_model.ventas.ventas_elementos(m.data,function (premios:SQLResult):void {
						ticket.hora = DateFormat.format(ticket.tiempo,DateFormat.masks["default"]);
						m.data = {tk:ticket,prm:premios.data}
						_cliente.sendMessage(m);
					});
				} else {
					m.data = {code:Code.NO_EXISTE};
					_cliente.sendMessage(m);
				}
			});
		}
		
		private function permiso_remove(e:Event,m:Message):void {
			m.data.usuarioID = usuario.usuarioID;
			_model.usuarios.permiso_remove(m.data,function (r:SQLResult):void {
				m.data = r.rowsAffected;
				_cliente.sendMessage(m);
			});
		}
		
		private function permiso_update(e:Event,m:Message):void {
			m.data.usuarioID = usuario.usuarioID;
			_model.usuarios.permiso_update(m.data,function (r:SQLResult):void {
				m.data = r.rowsAffected;
				_cliente.sendMessage(m);
			});
		}
		
		private function permisos(e:Event,m:Message):void {
			m.data = {usuarioID:usuario.usuarioID};
			_model.usuarios.permisos(m.data,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}
		
		private function permiso_nuevo(e:Event,m:Message):void {
			var metas:Array = [];
			for each (var permiso:int in m.data.permisos) {
				metas.push({
					usuarioID:usuario.usuarioID,
					bancaID:m.data.banca,
					campoID:permiso,
					valor:m.data.valor
				});
			}
			_model.usuarios.permiso_nuevo(metas,function (r:Vector.<SQLResult>):void {
				m.data = r.length;
				_cliente.sendMessage(m);
			});
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

		private function reporte_ventas (e:Event,m:Message):void {
			m.data.inicio = DateFormat.toDate(m.data.fecha).time;
			m.data.final = m.data.inicio+DateFormat.DIA;
			delete m.data.fecha;
			_model.reportes.ventas_banca(m.data,function (r:SQLResult):void {
				if (r.data) {
					var l:int = Math.ceil(r.data.length/50);
					for (var i:int = 0; i < l; i++) {
						m.data = {
							data:r.data.splice(0,50),
							last:0
						};
						_cliente.sendMessage(m);	
					}
				}
				m.data.data = null;
				m.data.last = 1;
				_cliente.sendMessage(m);
				measure(m.command);
			});
		}
		
		private function reporte_diario(e:Event,m:Message):void {
			_model.reportes.diario(m.data,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
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
		
		private function reporteUsuario(e:Event,m:Message):void {
			m.data.s.usuarioID = usuario.usuarioID;
			if (m.data.g==0) _model.reportes.general(m.data.s,result); 
			else if (m.data.g==1) _model.reportes.general_sorteo(m.data.s,result);
			else _model.reportes.fecha(m.data.s,result);
			
			function result (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			}
		}
		
		private function sms_nuevo (e:Event,m:Message):void {
			m.data.origen = usuario.usuarioID;
			m.data.tiempo = _model.ahora;
			_model.sms.envBancaGrupo(m.data,function (r:Vector.<SQLResult>):void {
				m.data = {code:Code.OK,n:r.length};
				_cliente.sendMessage(m);
			});
		}
		
		private function sms_bandeja (e:Event,m:Message):void {
			m.data = {bancaID:usuario.usuarioID};
			_model.sms.bandejaBanca(m.data,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}
		
		private function sms_leer (e:Event,m:Message):void {
			_model.sms.leerBanca(m.data,function (r:SQLResult):void {
				if (r.data) {
					if (r.data[0].destino==usuario.usuarioID) {
						m.data = r.data?r.data[0]:null;
					} else m.data = {code:Code.NO_EXISTE};
				} else {
					m.data = {code:Code.NO_EXISTE};
				}
				_cliente.sendMessage(m);
			});
		}
		
		private function sms_respuestas (e:Event,m:Message):void {
			_model.sms.respuestasBanca(m.data,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}
	}
}