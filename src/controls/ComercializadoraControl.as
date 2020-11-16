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
	import models.Notificaciones;
	import starling.utils.execute;
	import db.SQLStatementPool;
	import db.sql.SQLAPI;
	
	public class ComercializadoraControl extends Control
	{
		private var usuario:Usuario;
		
		public function ComercializadoraControl(cliente:Client, model:ModelHUB) {
			super(cliente, model);
			addEventListener("login",login);
		}
		
		private function addListeners():void {
			addEventListener("sql",sqlapi)
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
      addEventListener("grupo-comision-nv",grupo_comision_nv);
      addEventListener("banca_comision_nv",banca_comision_nv);
			
			addEventListener("taquilla-flock",taquilla_flock);
			addEventListener("taquilla-fpclear",taquilla_fpclear);
			
			addEventListener("topes",topes);
			addEventListener("tope-nuevo",tope_nuevo);
			addEventListener("tope-remover",tope_remover);
			
			addEventListener("usuario",usuario_config)
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

			addEventListener("comision_producto_nv",comision_producto_nuevo);
			addEventListener("comision_producto_rm",comision_producto_remover);

			addEventListener("comisiones_banca",comisiones_banca);
			addEventListener("comisiones_grupo",comisiones_grupo);
			
      //reporte 2.0
      addEventListener("reporte",reporte)
			
			addEventListener("permiso-nuevo",permiso_nuevo);
			addEventListener("permiso-update",permiso_update);
			addEventListener("permiso-remove",permiso_remove);
			addEventListener("permisos",permisos);			
			
			addEventListener("venta-premios",venta_premios);
			addEventListener("venta-anular",venta_anular);
						
			addEventListener("balance-padre",balance_padre);
			addEventListener("balance-add",balance_add);
			addEventListener("balance-clientes",balance_clientes);
			addEventListener("balance-us",balance_us);
			addEventListener("balance-pagos",balance_pagos);
			addEventListener("balance-remover",balance_remover);
			addEventListener("balance-pago",balance_pago);
			addEventListener("balance-ppagos",balance_ppagos);
			addEventListener("balance-confirmacion",balance_confirmacion);
			
			addEventListener("usuario-listaSuspender",usuarioLSuspender);
			addEventListener("usuario-susprem",usuario_suspremover);
			addEventListener("usuario-suspnvo",usuario_suspnuevo);

			addEventListener('chat-leer',function (e:Event,m:Message):void {
        _model.sms.leer(m.data.origen,usuario.usID,10,function (res:Array):void {
					var uID:* = /\d+/.exec(m.data.origen)
					_model.usuarios.usuarios({uid:uID[0]},function (usuario:Usuario):void {
					  m.data = {
							mensajes:res,
							origen:{
								usID:usuario.usID,
								nombre:usuario.nombre,
								contacto:usuario.contacto
							}
						};
					  _cliente.sendMessage(m);						
					})
        })
      });
			addEventListener('chat-bandeja',function (e:Event,m:Message):void {
        _model.sms.bandejaEntrada(usuario.usID,function (res:SQLResult):void {
					m.data = res.data;
					_cliente.sendMessage(m);
        })
      });
			addEventListener('chat-recibidos',function chatRecibidos(e:Event,m:Message):void {
				_model.sms.recibidos(usuario.usID,function chatRecibidos_controlResult(chats:Array):void {
					m.data = chats;
					_cliente.sendMessage(m);
				})
			})
			addEventListener('chat-enviados',function chatEnviados(e:Event,m:Message):void {
				_model.sms.enviados(usuario.usID,function chatEnviados_result(res:SQLResult):void {
					m.data = res.data
					_cliente.sendMessage(m)
				})
			})
			addEventListener('chat-destinos',function (e:Event,m:Message):void {
				if (usuario.tipo==2) {
					var destinos:Array = [{usID:'u1',nombre:'SISTEMA'}];
					_model.comercializadora.usuarios({usuarioID:usuario.usuarioID},function (usuarios:SQLResult):void {

						destinos = destinos.concat(usuarios.data.map(function (item:Object,idx:int,data:Array):Object {
							return {
								usID:item.usID,
								nombre: item.nombre
							}
						}))

						m.data = destinos;
						_cliente.sendMessage(m);
					})
				}
			});
			addEventListener('chat-nuevo',function (e:Event,m:Message):void {
				m.data.origen = usuario.usID
				m.data.origenNombre = usuario.nombre
				_model.sms.nuevo(m.data,function (res:SQLResult):void {
					if (res.lastInsertRowID>0) m.data = {ok:res.lastInsertRowID}
					else m.data = {error:'Mensaje no enviado'}
					_cliente.sendMessage(m)
				})
			})
			Notificaciones.listeners.addEventListener(Notificaciones.MENSAJE_NUEVO,notificacion_msgNuevo)
		}

		private var sqlAPI:SQLAPI = new SQLAPI()
		private function sqlapi(e:Event,m:Message):void {
			var comando:String = m.data.comando
			var payload:Object = m.data.data || {};
			payload.padreID = usuario.usuarioID
			delete m.data.comando;
			var sql:SQLStatementPool = sqlAPI.exec(comando)
			if (!sql) sendMessage(m,{error:'sentencia no existe'})
			else  {
				sql.run(payload,function (result:SQLResult):void {
				sendMessage(m,result)
			})
			}
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
		private function taquilla_comision_dl(e:Event,m:Message):void {
			_model.taquillas.comision_dl(m.data,function(r:SQLResult):void {
				m.data = r.rowsAffected;
				_cliente.sendMessage(m);
			});
		}		
		private function taquilla_comision_nv(e:Event,m:Message):void {
			if (m.data.hasOwnProperty("taquillaID")==false) m.data.taquillaID = 0;
			if (m.data.hasOwnProperty("grupoID")==false) m.data.grupoID = 0;
			if (m.data.hasOwnProperty("bancaID")==false) m.data.bancaID = 0;
			_model.taquillas.comision_nv(m.data,function(r:SQLResult):void {
				m.data.comID = r.lastInsertRowID;
				_cliente.sendMessage(m);
			});
		}
		private function grupo_comision_nv (e:Event, m:Message):void {
		m.data.taquillaID = 0;
		_model.taquillas.comision_nv(m.data,function(r:SQLResult):void {
			m.data.comID = r.lastInsertRowID;
			sendMessage(m);
		});
		}
		private function banca_comision_nv (e:Event, m:Message):void {
		m.data.grupoID = 0
		m.data.taquillaID = 0;
		_model.taquillas.comision_nv(m.data,function(r:SQLResult):void {
			m.data.comID = r.lastInsertRowID;
			sendMessage(m);
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
			m.data.comercialID = usuario.usuarioID;
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
				if (r.data.length<100) {
					m.data = r.data;
				  _cliente.sendMessage(m);
          measure(m.command);
				} else {
          if (m.data.force==true) {
            var rango:int = 100
            var len:int = Math.floor(r.data.length/rango)
            var dd:Array 
            for(var i:int = 0; i < len; i++) {
              dd = r.data.slice(rango*i,rango*(i+1))
              m.data = dd
              _cliente.sendMessage(m)
            }
          } else {
            m.data = {message:'Demasiados registros para mostrar, por favor seleccione un grupo'}
            _cliente.sendMessage(m)
          }
				}				
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
				if (r.data) {
					if (r.data.length>100) {
						var block:int = Math.ceil(r.data.length/100);
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
					} else if (u.activo==Usuario.ACTIVO) {
						controlID = u.usuarioID;
						var usuarioID:int = usuario.usuarioID
						if (usuario.tipo==3) usuarioID = parseInt(usuario.contacto)
						_model.sorteos.sorteos({usuarioID:u.usuarioID},function (sorteos:SQLResult):void {
							//TODO: remover y efecutar una consulta aparte
							_model.comercializadora.usuarios({usuarioID:usuarioID},function (bancas:SQLResult):void {
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
						_model.balance.usID({usID:usuario.usID,lm:10},function (r:SQLResult):void {
							if (r.data && r.data[0].balance>0) {
								m.data = {code:Code.SUSPENDIDO,info:r.data[0]};
								addEventListener("balance-pago",balance_pago);
							} else {
								m.data = {code:Code.SUSPENDIDO};
							}
							_cliente.sendMessage(m);
						});
					}
				} else {
					m.data = {code:Code.NO_EXISTE};
					_cliente.sendMessage(m);
				}
			});
		}
		
	private function comisiones_usuario(e:Event,m:Message):void {
		_model.usuarios.comisiones_usuario(m.data,function (r:SQLResult):void {
			m.data = r.data;
			sendMessage(m)
		})
	}
		private function comisiones_banca(e:Event,m:Message):void {
			m.data.usuario = usuario.usuarioID
				_model.usuarios.comisiones_banca(m.data,function (r:Array):void {
					m.data = r;
					sendMessage(m)
				});
		}

		private function comisiones_grupo(e:Event,m:Message):void {
			_model.usuarios.comisiones_grupo(m.data,function (r:SQLResult):void {
					m.data = r.data;
					sendMessage(m)
				});
		}

		private function comision_producto_nuevo (e:Event,m:Message):void {
			var comisionPrevia:Object = {usuario:m.data.usuario,operadora:m.data.operadora,tipo:m.data.tipo}
			_model.usuarios.comisiones_usuario(comisionPrevia,function (comisiones:SQLResult):void {
				if (comisiones.data) {
					m.data = {error:'comision existe'}
					sendMessage(m)
				}
				else {
					_model.usuarios.comision_producto_nuevo(m.data,function (r:SQLResult):void {
						m.data.comId = r.lastInsertRowID
						sendMessage(m)
					})
				}
			})
			
		}
		private function comision_producto_remover (e:Event,m:Message):void {
			_model.usuarios.comision_producto_remover(m.data,function (r:SQLResult):void {
				sendMessage(m,{ok:r.rowsAffected})
			})
		}

    private function reporte (e:Event,m:Message):void {
      m.data.comercial = usuario.usuarioID
      var s:Object = {inicio: m.data.inicio, fin: m.data.fin, comercial: usuario.usuarioID}
      _model.reportes.usuario(s,result)

      function result(r:SQLResult):void {
        sendMessage(m,r.data)
      }
    }
		private function notificacion_msgNuevo (e:Event,mensaje:Object):void {
			if (_cliente && usuario) {
				if (usuario.usID==mensaje.destino) {
					var m:Message = new Message
					m.command = 'chat-msgNuevo'
					m.data = mensaje
					_cliente.sendMessage(m)
				}
			}
		}
		override protected function dispose ():void {
			super.dispose()
			Notificaciones.listeners.removeEventListener(Notificaciones.MENSAJE_NUEVO,notificacion_msgNuevo);
		}
		
		private function usuario_suspnuevo(e:Event,m:Message):void {
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

				if (usuario.activo==false) {
					_model.balance.usID({usID:usuario.usID,lm:10},function (r:SQLResult):void {
						if (!r.data) return;
						if (r.data[0].d>0) { //sigue suspendido
							m.data = {code:Code.SUSPENDIDO,msg:"Su credito es insuficiente, comuniquese con su administrador"}
							_cliente.sendMessage(m);
						} else {
							_model.usuarios.editar({activo:3,usuarioID:usuario.usuarioID},function (r:SQLResult):void {
								m.data = {code:Code.OK,msg:"Pago recibido exitosamente, el usuario será activado temporalmente mientras se confirma su pago."}
								_cliente.sendMessage(m);
							})
						}

					})
				} else {
					_cliente.sendMessage(m);
				}
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
      var grupo:String = m.data.agrupar.split(",")[0]
      var descripcion:String = m.data.agrupar.split(",")[1]
      delete m.data.agrupar
      delete m.data.s
			if (usuario.tipo==3) {
				m.data.comercial = parseInt(usuario.contacto);
				trace("data",JSON.stringify(m.data))
			}
			else m.data.comercial = usuario.usuarioID;
      _model.reportes.usuario(m.data,function (r:SQLResult):void {
        var reporte:Array = agrupar(r.data,grupo)
        sendMessage(m,reporte)
      })
      function agrupar(reportes:Array,campo:String):Array {
        var grupos:Object = {}
        var grupo:Object
        for each(var reporte:Object in reportes) {
          grupo= grupos[reporte[campo]]
          if (grupo) {
            grupo.jg += reporte.jg
            grupo.pr += reporte.pr
            grupo.cm += reporte.cm
            grupo.prt += reporte.prt
          } else {
            reporte.desc = reporte[descripcion]
            reporte.tipo = campo;
            grupos[reporte[campo]] = reporte
          }
        }
        var resultado:Array=[]
        for(var llave:String in grupos) {
          resultado.push(grupos[llave])
        }
        return resultado
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

		private function usuario_config(e:Event,m:Message):void {
			m.data.usuarioID = usuario.usuarioID;
			_model.usuarios.clave(m.data,function (res:SQLResult):void {
				m.data = {
					ok: res.rowsAffected
				}
				_cliente.sendMessage(m)
			})
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
			m.data = {
				comercialID:usuario.usuarioID,
				fecha:m.data.fecha
			};
			
			
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
			_model.taquillas.fingerlock_usuario(m.data,function (r:SQLResult):void {
				m.data.ok = r.rowsAffected;
				_cliente.sendMessage(m);
			});
		}
		
		private function venta_anular(e:Event,m:Message):void {
			esMiTicket(m.data,function (ticket:*):void {
        m.data.codigo = m.data.codigo || 0;
        if (ticket && ticket.codigo==m.data.codigo) {
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
			esMiTicket(m.data,function (ticket:*):void {
          if (ticket) {
            _model.ventas.ventas_elementos({ticketID:ticket.ticketID},function (premios:SQLResult):void {
              m.data = {tk:ticket,prm:premios.data}       
					    _cliente.sendMessage(m);
            });
          } else {
            m.data = {code:Code.NO_EXISTE};  
					  _cliente.sendMessage(m);
          } 
      })


    }

    private function esMiTicket (ticket:Object,cb:Function):void {
      _model.ventas.ticket(ticket,function (ticket:Object):void {
          if (ticket) {
            ticket.hora = DateFormat.format(ticket.tiempo,DateFormat.masks["default"]);
            _model.usuarios.usuario_comercial(ticket.usuarioID,function (comercial:Usuario):void {
              if (comercial.usuarioID==usuario.usuarioID) cb(ticket);
              else cb(false)
            })
				} else cb(false)
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
			_model.usuarios.permiso_update(m.data,function (r:SQLResult):void {
				m.data = r.rowsAffected;
				_cliente.sendMessage(m);
			});
		}
		
		private function permisos(e:Event,m:Message):void {
			_model.usuarios.permisos(m.data,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}
		
		private function permiso_nuevo(e:Event,m:Message):void {
			var metas:Array = [];
			for each (var permiso:int in m.data.permisos) {
        var _permiso:Object = {
					usuarioID:m.data.usuarioID,
					bancaID:m.data.bancaID,
					campoID:permiso,
					valor:m.data.valor
				}
        _model.usuarios.permisos_campo(permiso,_permiso.usuarioID, _permiso.bancaID,function (r:Array):void {
          if (r) return sendMessage(m,{error:r[0].campo,errorMsg:'uno de los permisos ya se encuentra asignado'})
        })
				metas.push(_permiso);
			}
			_model.usuarios.permiso_nuevo(metas,function (r:Vector.<SQLResult>):void {
				m.data = r.length;
				_cliente.sendMessage(m);
			});
		}
		
		private function reporte_banca(e:Event,m:Message):void {
			if (m.data.g==0) _model.reportes.usuarios(m.data.s,result);
			else _model.reportes.fecha(m.data.s,result);
			
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
				
	}
}