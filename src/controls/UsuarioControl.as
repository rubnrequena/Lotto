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
	
	import vos.Banca;
	import vos.Elemento;
	import vos.Sorteo;
	import vos.Taquilla;
	import vos.Usuario;
	import helpers.ArrayUtil;
	
	public class UsuarioControl extends Control
	{
		private var usuario:Usuario;
		
		public function UsuarioControl(cliente:Client, model:ModelHUB)
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
			m.data.usuarioID = usuario.usuarioID;
			m.data.bancaID = 0;
			m.data.papelera = m.data.papelera;
			_model.taquillas.editar(m.data,function (r:SQLResult):void {
				m.data = {code:r.rowsAffected};
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
			m.data.usuarioID = usuario.usuarioID;
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
				if (r.rowsAffected>0) {
					var b:Banca = LTool.findBy("bancaID",m.data.bancaID,_model.bancas.bancas);
					if (m.data.hasOwnProperty("activa")) b.activa = m.data.activa;
					if (m.data.hasOwnProperty("nombre")) b.nombre = m.data.nombre;
					if (m.data.hasOwnProperty("clave")) b.clave = m.data.clave;
					if (m.data.hasOwnProperty("comision")) b.comision = m.data.comision;
				}
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
			if (m.data.elemento=="") m.data.elemento = 0
			else {
				var elemento:Elemento = m.data.elemento = _model.sistema.elemento_num(m.data.elemento,m.data.sorteo)
				if (!elemento) {
					m.data = {error:'Numero invalido o no existe para el sorteo seleccionado'}
					return _cliente.sendMessage(m);
				}
				else m.data.elemento = elemento.elementoID
			}
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
		private function taquilla(e:Event,m:Message):void {
			m.data.usuarioID = usuario.usuarioID;
			_model.taquillas.buscar(m.data,function (r:SQLResult):void {
				m.data = r.data[0];		
				_model.taquillas.metas({taquillaID:m.data.taquillaID, bancaID: m.data.usuarioID},function (meta:Object):void {
					m.data.meta = meta;
					_cliente.sendMessage(m);
				});				
			});
		}
		private function taquillas(e:Event,m:Message):void {
			m.data.usuarioID = usuario.usuarioID;
			_model.taquillas.buscar(m.data,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}
		private function taquilla_metas(e:Event,m:Message):void {
			var a:int=0;
			for (var meta:String in m.data.meta) {
				a++;
				var ometa:Object = {
					valor:m.data.meta[meta],
					campo:meta,
					taquillaID:m.data.taq,
					bancaID:usuario.usuarioID
				};
				_model.taquillas.meta(ometa,taquillas_meta_result);
			}
			
			if (a==0) {
				m.data = m.data.meta;
				_cliente.sendMessage(m);
			}
			
			var n:int=0;
			function taquillas_meta_result (r:SQLResult):void {
				n++;
				if (n==a) {
					m.data = m.data.meta;
					_cliente.sendMessage(m);
				}
			}
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
      m.data.bancaID = usuario.usuarioID
			_model.taquillas.comision_dl(m.data,function(r:SQLResult):void {
				m.data = r.rowsAffected;
				_cliente.sendMessage(m);
			});
		}
		
		private function taquilla_comision_nv(e:Event,m:Message):void
		{
			m.data.bancaID = usuario.usuarioID
			_model.taquillas.buscar_taqID(m.data.taquillaID,function (err:String,taquilla:Object):void {
				if (err) {
          sendMessage(m,{error:err})
        } else {
					m.data.grupoID = taquilla.bancaID
				  _model.taquillas.comision_nv(m.data,function(r:SQLResult):void {
				    m.data.comID = r.lastInsertRowID;
            sendMessage(m);
			    });
				}
			})
		}
    private function grupo_comision_nv (e:Event, m:Message):void {
      m.data.bancaID = usuario.usuarioID
      m.data.taquillaID = 0;
      _model.taquillas.comision_nv(m.data,function(r:SQLResult):void {
        m.data.comID = r.lastInsertRowID;
        sendMessage(m);
      });
    }
    
    private function banca_comision_nv (e:Event, m:Message):void {
      m.data.bancaID = usuario.usuarioID
      m.data.grupoID = 0
      m.data.taquillaID = 0;
      _model.taquillas.comision_nv(m.data,function(r:SQLResult):void {
        m.data.comID = r.lastInsertRowID;
        sendMessage(m);
      });
    }
		private function login(e:Event,m:Message):void {
			_model.usuarios.login(m.data,function (u:Usuario):void {
				if (u) {
					usuario = u;
					if (u.activo==Usuario.USUARIO_ACTIVO) {
						controlID = u.usuarioID;						
						_model.sorteos.sorteos({usuarioID:u.usuarioID},function (sorteos:SQLResult):void {
              _model.usuarios.permisos_banca({usuarioID:usuario.usuarioID},function (permisos:SQLResult):void {
                m.data = {
								us:u,
								bn:LTool.exploreBy("usuarioID",usuario.usuarioID,_model.bancas.bancas).sortOn("papelera","activa","nombre"),
								st:sorteos.data,
                permisos:permisos.data
							};
							addListeners();
							measure(m.command);
							_cliente.sendMessage(m);
							
							_model.balance.usID({usID:usuario.usID,lm:10},function (r:SQLResult):void {
								m.command = "balance-padre";
								m.data = r.data;
								_cliente.sendMessage(m);
							});
              })
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
		
		private function addListeners():void {
			
			addEventListener("inicio",inicio);			
			addEventListener("sorteos",sorteos);
			addEventListener("sorteo-premiar",sorteo_premiar);
			addEventListener("elementos",elementos);
			
			addEventListener("taquilla",taquilla);
			addEventListener("taquillas",taquillas);
			addEventListener("taquilla-editar",taquilla_editar);
			addEventListener("taquilla-nueva",taquilla_nueva);
			addEventListener("taquilla-panic",taquilla_panic);
			addEventListener("taquilla-remover",taquilla_remover);
			addEventListener("taquilla-metas",taquilla_metas);
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
			
			addEventListener("banca-nueva",banca_nueva);
			addEventListener("banca-editar",banca_editar);
			addEventListener("banca-remover",banca_remover);
			addEventListener("banca-relacion",banca_relacion);
      addEventListener("banca-comisiones",banca_comisiones);
      addEventListener("banca-comisiones-nueva",comision_nueva);
      addEventListener("banca-comisiones-remover",comision_remover);
			
			addEventListener("monitor",monitor);
			addEventListener("reporte-general",reporte_general);
			
			addEventListener("sorteos-publicos",sorteos_publicos);
			addEventListener("pb_remover",sorteos_publicos_remover);
			addEventListener("pb_editar",sorteos_publicos_editar);
			addEventListener("publicar",publicar);
			
			addEventListener("transferir",transferir);
			addEventListener("conexiones",conexiones);
			
			addEventListener("reporte-usuario",reporteUsuario);
			addEventListener("reporte-taquilla",reporteTaquilla);
			addEventListener("reporte-banca",reporte_banca);
			addEventListener("reporte-ventas",reporte_ventas);
			addEventListener("reporte-diario",reporte_diario);
			addEventListener("reporte-sorteo",reporte_sorteo);
			
			addEventListener("permiso-nuevo",permiso_nuevo);
			addEventListener("permiso-update",permiso_update);
			addEventListener("permiso-remove",permiso_remove);
			addEventListener("permisos",permisos);
			
			
			addEventListener("venta-premios",venta_premios);
			addEventListener("venta-anular",venta_anular);
			
			addEventListener("balance-padre",balance_padre);
			addEventListener("balance-pago",balance_pago);
			
			addEventListener("suspension-info",suspension_info);

			//Mensajes
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
				_model.usuarios.destinos({uID:usuario.usuarioID},function (usuarios:SQLResult):void {
						m.data = usuarios.data
						_cliente.sendMessage(m)
					})
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
		}
		
		private function suspension_info(e:Event,m:Message):void
		{
			
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
		
		private function balance_padre(e:Event,m:Message):void {
			m.data = {usID:usuario.usID,lm:10};
			_model.balance.usID(m.data,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}
		
		private function banca_relacion(e:Event,m:Message):void {
			_model.bancas.relacion_pago(m.data,function (r:SQLResult):void {
				m.data = r.rowsAffected;
				_cliente.sendMessage(m);
			});
		}

    private function banca_comisiones (e:Event,m:Message):void {
      m.data.bancaID = usuario.usuarioID
      _model.taquillas.comisiones(m.data,function (r:SQLResult):void {
        sendMessage(m,r.data)
      })
    }
    private function comision_nueva (e:Event,m:Message):void {
      m.data.taquillaID = 0;
      m.data.bancaID = usuario.usuarioID
      _model.taquillas.comision_nv(m.data,function (r:SQLResult):void {
        m.data = r.data
        sendMessage(m)
      })
    }
    private function comision_remover (e:Event,m:Message):void {
      m.data.bancaID = usuario.usuarioID
			_model.taquillas.comision_dl(m.data,function(r:SQLResult):void {
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
					var data:Array = ArrayUtil.split(r.data,50)
					for each(var d:Array in data) {
						sendMessage(m,d)
					}
					sendMessage(m,{code:"fin"})
				} else sendMessage(m,{code:Code.VACIO,time:_model.ahora});
				measure(m.command);
			});
		}
		
		private function taquilla_fpclear(e:Event,m:Message):void {
			m.data = m.data || {};
			m.data.usuarioID = usuario.usuarioID;
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
			if (m.data.g==0) _model.reportes.general(m.data.s,result);
			else if (m.data.g==1) _model.reportes.general_sorteo(m.data.s,result);
			else  _model.reportes.fecha(m.data.s,result);
			
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
		private function reporte_sorteo(e:Event,m:Message):void {
			m.data.usuarioID = usuario.usuarioID
			_model.reportes.banca(m.data,function (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}

		private function reporteTaquilla(e:Event,m:Message):void {
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

		
		
		private function reporte_general(e:Event,m:Message):void {
      var grupo:String = m.data.agrupar.split(",")[0]
      var descripcion:String = m.data.agrupar.split(",")[1]
      delete m.data.agrupar
      delete m.data.s
			_model.usuarios.usuario_comercial(usuario.usuarioID,function (comercial:Usuario):void {
				m.data.comercial = comercial.usuarioID
				m.data.banca = usuario.usuarioID;
				_model.reportes.usuario(m.data,function (r:SQLResult):void {
					var reporte:Array = agrupar(r.data,grupo)
					sendMessage(m,reporte)
				})
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
	}
}