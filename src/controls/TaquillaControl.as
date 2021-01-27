package controls
{
	import flash.data.SQLResult;
	import flash.errors.SQLError;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import be.aboutme.airserver.Client;
	import be.aboutme.airserver.messages.Message;
	
	import by.blooddy.crypto.MD5;
	
	import helpers.Code;
	import helpers.DateFormat;
	import helpers.LTool;
	import helpers.Mail;
	import helpers.ObjectUtil;
	import helpers.WS;
	import helpers.bm.EGrupo;
	import helpers.print.ModoExtremo;
	
	import models.ModelEvent;
	import models.ModelHUB;
	
	import starling.events.Event;
	import starling.utils.StringUtil;
	
	import vos.Elemento;
	import vos.Sorteo;
	import vos.Taquilla;
	import vos.Tope;
	import db.sql.SQLAPI;
	import db.SQLStatementPool;
	import starling.core.Starling;
	import vos.Usuario;
	import vos.Limite;
	
	public class TaquillaControl extends Control
	{
		private static const LOG_LOGIN:String = "{0}: LOGIN U:{1} IP:{2} FP:{3}\n";
		
		private var _taquilla:Taquilla;
		private var _meta:Object;
		private var _bancaMeta:Object;
		private var _topes:Vector.<Tope>;
		
		private var msg:Message;
		private var _valTiempo:Number;
		private var _valCod:int;
		private var _conectado:Number;
		private var _init:uint;
		
		private var logFile:File;
		private var logFS:FileStream;
		private var sesionHash:String;

		private var LIMITE:Limite;
		
		public function TaquillaControl(cliente:Client, model:ModelHUB) {
			super(cliente, model);
			
			msg = new Message;
			addEventListener(ModelEvent.LOGIN,login);
			
			_conectado = (new Date).time;
			_init = setTimeout(TC_onInit,500);
			
			function TC_onInit():void {
				msg.command = "init";
				msg.data = {
					t:_conectado
				};
				cliente.sendMessage(msg);
			}
		}
		
		private function addListeners():void {	
			topes_update();
			
			addEventListener("sql",sqlapi)
			addEventListener("venta",venta);
			addEventListener("venta-ultima",venta_ultima);
			addEventListener("venta-anular",venta_anular);
			addEventListener("venta-premios",venta_premios);
			addEventListener("venta-pagar",venta_pagar);
			addEventListener("venta-repetir",venta_repetir);
			addEventListener("fingerprint",taq_fingerprint);
			
			addEventListener("sorteos",sorteos);
			addEventListener("reporte-diario",reporte_diario);
			addEventListener("reporte-sorteo",reporte_sorteo);
			addEventListener("reporte-general",reporte_general);
			addEventListener("reporte-ventas",reporte_ventas);
			
			addEventListener("ticket-anulado",ticket_anulado);
			
			addEventListener("elementos-init",elementos_init);
			
			//addEventListener("notificar",sistema_notificar);
						
			//_model.mSorteos.addEventListener(Event.UPDATE,sorteosModel_update);
			_model.sorteos.addEventListener(ModelEvent.ESTATUS_CHANGE,model_srt_changeEstatus);			
			_model.topes.addEventListener(Event.CHANGE,model_tp_topeNuevo);			
			_model.ventas.addEventListener(ModelEvent.PREMIO,ventasModel_premio);
		}
		
		
		private var sqlAPI:SQLAPI = new SQLAPI('APITaquilla.sql')
		private function sqlapi(e:Event,m:Message):void {
			var comando:String = m.data.comando
			var payload:Object = m.data.data || {};
			payload.padreID = _taquilla.usuarioID
			payload.taquillaID = _taquilla.taquillaID
			var sql:SQLStatementPool = sqlAPI.exec(comando)
			if (!sql) sendMessage(m,{error:'sentencia no existe'})
			else  {
				sql.run(payload,function sql_api_handler (result:SQLResult):void {
				sendMessage(m,result)
			})
			}
		}

		private function elementos_init(e:Event,m:Message):void {
			var tq:Object = {
				fecha:DateFormat.format(new Date),
				taquilla:_taquilla.taquillaID,
				banca:_taquilla.bancaID
			}
			_model.sistema.elementos_gtag(tq,function _elementos_init (r:SQLResult):void {
				for each (var i:Object in r.data) {
					m.data = _model.sistema.elementos_sorteo_min(i.s);
					_cliente.sendMessage(m);
				}
				m.data = {hash:_model.sistema.eleHash};
				_cliente.sendMessage(m);
			});
		}
		
		private function sistema_notificar(e:Event,m:Message):void {
			if (m.data.code==1) {
				WS.emitir(Loteria.setting.plataformas.usuarios.premios,StringUtil.format(WS.NTF_TQ_SORTEO_INV,m.data.sorteo.descripcion,_taquilla.taquillaID,_taquilla.usuarioID,Loteria.setting.servidor));				
			}
		}
		
		private function ticket_anulado(e:Event,m:Message):void {
			_model.ventas.anulado(m.data,function _anulado (r:SQLResult):void {
				if (r.data) {
					m.data = r.data[0];
					m.data.tiempo = DateFormat.format(m.data.tiempo,"dd/mm/yy hh:MM:ss TT");
					_cliente.sendMessage(m);
				} else {
					m.data.code = Code.NO_EXISTE;
					_cliente.sendMessage(m);
				}
			});
		}
		
		private function taq_fingerprint(e:Event,m:Message):void {
			m.data = {
				fp:String(m.data),
				taquillaID:_taquilla.taquillaID	
			};
			_taquilla.fingerprint = m.data.fp;
			initLog();
			_model.taquillas.fingerprint(m.data,function _fingerprint (r:SQLResult):void {
				m.data = r.rowsAffected;
				_cliente.sendMessage(m);
			});
		}
				
		private function reporte_ventas(e:Event,m:Message):void {
			m.data.taquillaID = _taquilla.taquillaID;
			//m.data.bancaID = _taquilla.bancaID; validar banca de taquilla
			m.data.inicio = DateFormat.toDate(m.data.fecha).time;
			m.data.final = m.data.inicio+DateFormat.DIA;
			delete m.data.fecha;
			_model.reportes.ventas(m.data,function _reporte_ventas (r:SQLResult):void {
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
				
		private function venta_repetir(e:Event,m:Message):void {
			_model.ventas.repetir(m.data,function _venta_repetir (r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}
		
		private function topes_update():void {
			_model.topes.topes({bancaID:_taquilla.bancaID,taquillaID:_taquilla.taquillaID,usuarioID:_taquilla.usuarioID},result);
			
			function result (topes:SQLResult):void {
				_topes = Vector.<Tope>(topes.data);
			}
		}
		
		override protected function dispose():void {
			
			Starling.current.removeEventListener(sesionHash,venderHandler);
			//_model.mSorteos.removeEventListener(Event.UPDATE,sorteosModel_update);
			_model.sorteos.removeEventListener(ModelEvent.ESTATUS_CHANGE,model_srt_changeEstatus);			
			_model.topes.removeEventListener(Event.CHANGE,model_tp_topeNuevo);
			_model.ventas.removeEventListener(ModelEvent.PREMIO,ventasModel_premio);
			if (_taquilla) _model.taquillas.dispatchEventWith(Event.CLOSE,false,_taquilla);
			
			_cache = null;
			_meta = null;
			_taquilla = null;
			_topes = null;
			msg = null;
			clearTimeout(_init);
			if (logFS) logFS.close();
			logFS=null;
			logFile=null;
		}
		
		private function model_tp_topeNuevo(e:Event,tope:Tope):void {
			if (tope && _taquilla) {
				if (tope.bancaID==0 || tope.bancaID==_taquilla.bancaID || tope.usuarioID == _taquilla.usuarioID) {
					if (tope.taquillaID==0 || tope.taquillaID==_taquilla.taquillaID) {
						topes_update();
					}
				}
			}
		}
		
		private function model_srt_changeEstatus(e:Event,sorteo:Object):void {
			if (msg && _cliente) {
				msg.command = e.type;
				msg.data = sorteo;
				_cliente.sendMessage(msg);
			}
		}
		
		private function login(e:Event,m:Message):void {
			var fp:String = m.data.fp;
			delete m.data.fp;
			_model.taquillas.login(m.data,_cliente,function _login(taquilla:Taquilla,err:Object):void {
				if (err) {
					m.data = err;
					_cliente.sendMessage(m);
				} else {
					_taquilla = taquilla;
					continuarLogin();
				}
			});
			
			function continuarLogin():void {
				if (!_taquilla) return;
				var efp:String = MD5.hash(_taquilla.fingerprint+_conectado);
				controlID = _taquilla.taquillaID;		
				if (_taquilla.fingerlock==true && _taquilla.fingerprint) {
					if (fp != efp) {
						m.data = {code:Code.INVALIDO};
						sendMessage(m);
						return;
					}
				} else {
					if (fp != efp) {
						msg.command = "fingerprint";
						sendMessage(msg);
					}
				}
				_taquilla.conectado = _model.ahora;
				m.data = {
					taq:_taquilla,
					time:_taquilla.conectado							
				};
				addListeners();
				
				var hoy:String = DateFormat.format(null);
				var f:Object = {fecha:hoy,banca:_taquilla.bancaID,taquilla:_taquilla.taquillaID};
				_model.sorteos.sorteos(f,function login_sorteos (r:SQLResult):void {		
					m.data.sorteos = r.data
					m.data.elementos = _model.sistema.eleHash;
					//registrar api
					sesionHash = MD5.hash(_taquilla.taquillaID+new Date().getTime().toString())
					
					Starling.current.addEventListener(sesionHash,venderHandler);
					m.data.sesion = sesionHash
					sendMessage(m);

					initLimiteMinimo();
					trace('cliente IP',_cliente.socket().remoteAddress);
					_model.usuarios.nuevaSesion(_taquilla.taquillaID,Usuario.TIPO_TAQUILLA)
					_model.taquillas.metas({taquillaID:_taquilla.taquillaID,bancaID:_taquilla.usuarioID},function metaResult (meta:Object):void {
						m.command = "metas";
						m.data = meta;						
						sendMessage(m);
						measure("login");
					})
				});
			}
		}
		private function initLimiteMinimo():void {
			_model.usuarios.buscar_limite(_taquilla.bancaID,function (limite:Limite):void {
				LIMITE = limite;
			})
		}
		private function initLog():void {
			logFile = File.applicationStorageDirectory.resolvePath("logUsers").resolvePath(DateFormat.format(null,"yyyymmdd")).resolvePath("TQ"+_taquilla.taquillaID+".txt");
			logFS = new FileStream;
			logFS.open(logFile,FileMode.APPEND);
			Console.saveTo(
				StringUtil.format(LOG_LOGIN,
					DateFormat.format(_model.ahora,DateFormat.masks.mediumTime), //0.hora
					_taquilla.usuario,//1.usuario
					_cliente.socket().remoteAddress,//2.ip
					_taquilla.fingerprint+":"+int(_taquilla.fingerlock)),//3.huella
				logFile,logFS,false);
		}
		
		private function ventasModel_premio(e:Event,pr:Object):void {
			if (msg && _cliente) {
				msg.command = e.type;
				msg.data = pr;
				_cliente.sendMessage(msg);
			}
		}
		
		private function reporte_general(e:Event,m:Message):void {
			m.data.taquillaID = _taquilla.taquillaID;
			_model.reportes.taquilla(m.data,function _reporte_general (r:SQLResult):void {
				m.data =r.data;
				_cliente.sendMessage(m);
				measure(m.command);
			});
		}
		
		private function venta_premios(e:Event,m:Message):void {
			_model.ventas.ticket(m.data,function _venta_premios_ticket (ticket:Object):void {
				if (ticket && ticket.taquillaID==_taquilla.taquillaID) {
					ticket.hora = DateFormat.format(ticket.tiempo,DateFormat.masks["default"]);
					_model.ventas.ventas_elementos(m.data,function _venta_premios_elementos (premios:SQLResult):void {
						m.data = {tk:ticket,prm:premios.data}
						_cliente.sendMessage(m);
					});
				} else {
					m.data = {code:Code.NO_EXISTE};
					_cliente.sendMessage(m);
				}
			});
		}
		
		private function reporte_sorteo(e:Event,m:Message):void {
			m.data.taquillaID = _taquilla.taquillaID;
			_model.reportes.taquilla(m.data,function _reporte_sorteo (ventas:SQLResult):void {
				m.data = {
					vnt:ventas.data
				}
				_cliente.sendMessage(m);
				measure(m.command);
			});
		}
		
		
		private function venta_pagar(e:Event,m:Message):void {
			_valCod = m.data.cod || 0;
			delete m.data.cod;
			_model.ventas.ticket({ticketID:m.data.tk,codigo:_valCod},function _venta_pagar_ticket (ticket:Object):void {
				if (ticket && ticket.taquillaID==_taquilla.taquillaID && ticket.anulado==0) { //validar taquilla
					_valTiempo = _model.ahora-ticket.tiempo;					
					if (_valTiempo<259200000 && ticket.codigo==_valCod) { // validar ticket (no mayor de 3 dias, codigo de seguridad)
						_model.ventas.pagar({
							id:m.data.id,
							tk:m.data.tk,
							tiempo:_model.ahora
						},function _pagar_venta (r:SQLResult):void {
							//_model.ventas.premios_pagos({pago:m.data.premio,taquillaID:_taquilla.taquillaID,sorteoID:m.data.sorteoID},null);
							m.data.id = r.lastInsertRowID;
							_cliente.sendMessage(m);
							measure(m.command);
						}, function _pagar_venta_error(er:SQLError):void {
							m.data.code = Code.DUPLICADO;
							_cliente.sendMessage(m);
							measure(m.command);
						});
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
		
		private function venta_anular(e:Event,m:Message):void {
			//validar ticket			
			_model.ventas.ticket(m.data,function _venta_anular_ticket(ticket:Object):void {
				m.data.codigo = m.data.codigo || 0;
				if (ticket && ticket.taquillaID==_taquilla.taquillaID && ticket.codigo==m.data.codigo) {
					if (ticket.anulado==false) {
						if (_model.ahora-ticket.tiempo<300000) { //validar vigencia del ticket 5mins
							m.data.tiempo = _model.ahora;
							delete m.data.codigo;
							_model.ventas.anular(m.data,_taquilla,function _venta_anular(r:SQLResult):void {
								_cache=null;								
								m.data = r.lastInsertRowID;
								_cliente.sendMessage(m);
								measure(m.command);
								
								_model.ventas.ventas_elementos({ticket:ticket.ticketID},function _notificar_topes(r:SQLResult):void {
									if (ventasBanca) unmerge(ventasBanca.sorteos,r.data);
									if (ventasUsuario) unmerge(ventasUsuario.sorteos,r.data);
								});
							},function _venta_error (e:SQLError):void {
								m.data.code = Code.DUPLICADO;
								_cliente.sendMessage(m);
							});	
						} else {
							m.data.code = Code.INVALIDO;
							_cliente.sendMessage(m);
						}
					} else {
						m.data.code = Code.DUPLICADO;
						_cliente.sendMessage(m);
					}
				} else {
					m.data.code = Code.NO_EXISTE;
					_cliente.sendMessage(m);
				}
			});
			
			function unmerge (cache:Array,_ventas:Array):void {
				var j:int, i:int; var a:Object,b:Object;
				var vl:int = _ventas.length, cl:int = cache.length;
				for (j = 0; j < vl; j++) {
					a = _ventas[j];
					for (i = 0; i < cl; i++) {
						b = cache[i];
						if (a.sorteoID==b.sorteoID && a.numero==b.numero) {
							b.monto -= a.monto;
							break;
						}
					}
				}
			}
		}
		
		private function venta_ultima(e:Event,m:Message):void {
			//TODO validar que sea del dia actual
			_model.ventas.tickets({ultimo:_taquilla.taquillaID},function _venta_ultima_tickets (r:SQLResult):void {
				if (r.data) {
					m.data = {ticket:r.data[0]};
					m.data.ticket.hora = DateFormat.format(m.data.ticket.tiempo,DateFormat.i18n["default"]);
					_model.ventas.ventas_elementos({ticketID:m.data.ticket.ticketID},venta_ultima_result);
					
					function venta_ultima_result (ventas:SQLResult):void {
						m.data.ventas = ventas?ventas.data:[];
						_cliente.sendMessage(m);
					}
				}
			});
		}
		
		private function sorteosModel_update(e:Event,data:Object):void {
			if (msg && _cliente) {
				if (data.fecha==DateFormat.format(_model.ahora)) {
					msg.command = "sorteos-update";
					msg.data = data;
					_cliente.sendMessage(msg);
				}
			}
		}
		
		private function reporte_diario(e:Event,m:Message):void {
			m.data.taquillaID = _taquilla.taquillaID;
			_model.reportes.diario(m.data,function _reporte_diario(r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
				measure(m.command);
			});
		}
		
		private function sorteos(e:Event,m:Message):void {
			_model.sorteos.sorteos(m.data,function _sorteos(r:SQLResult):void {
				m.data = r.data;
				_cliente.sendMessage(m);
			});
		}
		
		private var ultVenta:Object;
		private var _ventas:Array
		private var _sorteo:Sorteo;
		private var _cache:Array;

		private var ventasBanca:EGrupo;
		private var ventasUsuario:EGrupo;
		
		private  var invalidos:Array = [];

		private function venderHandler(e:Event,data:Object):void {
			var event:String = e.type+"_callback"
			vender(data,_vender_handler);
			function _vender_handler (data:Object):void {
				if (data.tk) Loteria.console.log("[Venta:HTTP:"+data.tk.taquillaID+"]",data.tk.ticketID, data.vt.length,"jugadas")
				Starling.current.dispatchEventWith(event,false,data)
			}
		}
		private function vender (data:Object,cb:Function):void {
			var i:int;
			var meta:Object = data.m || {};
			if (ultVenta && !meta.hasOwnProperty("rw")) {
				var mt:Number=0;
				var mn:int=0;
				var len:int = data.v.length
				for(i = 0; i < len; i++) {
					mt+= data.v[i].monto;
					mn+= data.v[i].numero;
				}
				var unums:Array = ultVenta.vt.map(function _numeros (num:Object,i:int,a:Array):int { return num.numero });
				var unum:int=0;
				for each(var num:int in unums) unum += num;
				var ahora:Number = new Date().time;
				var tiempo:Number = ultVenta.tk.tiempo+Loteria.setting.taquilla.ticketDuplicado;
				if (unum==mn && mt==ultVenta.tk.monto && len==ultVenta.vt.length && tiempo-ahora>0) {
					data = {code:Code.DUPLICADO,venta:data};
					cb(data)
					return;
				}
			}
			
			var t:int = getTimer();
			_ventas = data.v as Array;
			if (_ventas.length==0) { // validar ventas
				data = {code:Code.VACIO};
				cb(data);
				return;
			}		
			//validar duplicados
			_ventas.sortOn(["sorteoID","numero"],Array.NUMERIC);
			var j:int;
			for (i = _ventas.length-1; i > 0; i--) {
				if (_ventas[i].sorteoID==_ventas[i-1].sorteoID && _ventas[i].numero==_ventas[i-1].numero) {
					_ventas[i-1].monto += _ventas[i].monto;
					_ventas.removeAt(i);
				}
			}

			//validar jugada minima
			if (esInferiorAlMinimoPermitido(_ventas)) {
				data = {code:Code.JUGADA_MINIMA_PERMITIDA,monto:LIMITE.monto};
				cb(data);
				return;
			}

			//validar disponibilidad de sorteos
			invalidos.length=0;
			for (i = 0; i < _ventas.length; i++) {
				_sorteo = _model.mSorteos.getSorteo(_ventas[i].sorteoID);
				if (_sorteo && _sorteo.abierta && _sorteo.cierra>_model.ahora) continue;
				else invalidos.push(_ventas[i].sorteoID);
			}
			
			if (invalidos.length>0) {
				data = {code:Code.INVALIDO,sorteos:invalidos};
				cb(data);
			} else {
				//validar topes
				t=getTimer();				
				//seleccionar validacion de topes				
				var debeValidar:Boolean;
				debeValidar = LTool.exist("compartido",2,_topes);
				if (debeValidar) validarTopeUsuario();
				else {
					debeValidar = LTool.exist("compartido",1,_topes);
					if (debeValidar) validarTopeBanca();
					else validarTopeTaquilla();
				}
				
				function validarTopeUsuario():void {
					ventasUsuario = _model.uMan.findGrupo(_taquilla.usuarioID);
					if (ventasUsuario) {
						validarTopes(_ventas,ventasUsuario.sorteos,2);						
						validarTopeBanca();
					} else {
						_model.ventas.ventas_elementos({
							fecha:DateFormat.format(_model.ahora),
							usuarioID:_taquilla.usuarioID
						},function _validarTopeUsuario (ventas_banca:SQLResult):void {
							ventasUsuario = _model.uMan.registrar(_taquilla.usuarioID,ventas_banca.data);
							validarTopeUsuario();
						});
					}	
				}
				function validarTopeBanca():void {
					ventasBanca = _model.bMan.findGrupo(_taquilla.bancaID);
					if (ventasBanca) {
						validarTopes(_ventas,ventasBanca.sorteos,1);
						validarTopeTaquilla();
					} else {
						_model.ventas.ventas_elementos({
							fecha:DateFormat.format(_model.ahora),
							bancaID:_taquilla.bancaID
						},function _validarTopeBanca (ventas_banca:SQLResult):void {
							ventasBanca = _model.bMan.registrar(_taquilla.bancaID,ventas_banca.data);
							validarTopeBanca();
						});
					}
				}
				function validarTopeTaquilla():void {
					if (_cache) validarTaquilla();
					else {
						_model.ventas.ventas_elementos({
							fecha:DateFormat.format(_model.ahora),
							taquillaID:_taquilla.taquillaID
						},function _validarTopeTaquilla (ventas_taquilla:SQLResult):void {
							_cache = ventas_taquilla.data || [];
							validarTaquilla();
						});
					}
				}
				
				function validarTaquilla ():void {
					validarTopes(_ventas,_cache,0);
					if (invalidos.length>0) { // VENTA INVALIDA
						data = {code:Code.TOPE_TAQUILLA_EXEDIDO,elementos:invalidos}
						cb(data);
					} else { // VENTA VALIDA
						realizarVenta();
					}
					invalidos.length = 0;
				}
				function realizarVenta ():void {					
					_model.ventas.venta(_ventas,_taquilla,realizarVenta_handler);
					function realizarVenta_handler  (ticket:Object,ventasID:Array,ids:Array):void {
						ticket.hora = DateFormat.format(ticket.tiempo,DateFormat.i18n["default"]);
						ultVenta = {
							tk:ticket,
							vt:ventasID
						};
						data = ultVenta;						
						t=getTimer();
						merge(_cache);
						if (ventasBanca) merge(ventasBanca.sorteos);
						if (ventasUsuario) merge(ventasUsuario.sorteos);
						data.format = "print";
						
						if (meta.hasOwnProperty("mail")) {
							data.format = "mail";
							
							var body:Array = ['<table border="0">'];
							var cs:int=0; var el:Elemento;
							for (var k:int = 0; k < _ventas.length; k++) {
								if (cs!=_ventas[k].sorteoID) body.push('<tr><td colspan="3" style="padding-top:10px;"><b>'+_model.mSorteos.getSorteo(_ventas[k].sorteoID).descripcion+'</b></td></tr>');
								cs=_ventas[k].sorteoID;
								el = _model.sistema.elemento(_ventas[k].numero);
								body.push('<tr><td>'+el.numero+"</td><td>"+el.descripcion+"</td><td>"+_ventas[k].monto+'</td></tr>');
							}
							
							MonitorSistema.monitor.ms_last_desc = "venta_mail";
							Mail.send(meta.mail,"SRQ VENTAS - VENTA CONFIRMADA",StringUtil.format(Mail.VENTA_CONFIRMADA,
								_taquilla.nombre,
								ticket.hora,
								ticket.ticketID,
								ticket.codigo,
								ticket.monto,
								body.join("<br/>")+"</table>"								
							),function mail_sent ():void {
								//mail send
							});
						}
						if (meta.hasOwnProperty("ws")) {
							MonitorSistema.monitor.ms_last_desc = "venta_ws";
							data.format = "ws";
							data.ws = meta.ws;						
							WS.enviar(meta.ws,ModoExtremo.imprimirVentas_extremo(_ventas,ticket,_taquilla,_model));
						}
						cb(data);
					}
				}
				function merge (cache:Array):void {
					var a:Object,b:Object; var f:Boolean;
					var vl:int = _ventas.length, cl:int = cache?cache.length:0;
					for (j = 0; j < vl; j++) {
						f=false;
						a = _ventas[j];
						for (i = 0; i < cl; i++) {
							b = cache[i];
							if (a.sorteoID==b.sorteoID && a.numero==b.numero) {
								f=true;
								b.monto += a.monto;
								break;
							}
						}
						if (f==false) {
							if (cache) cache.push(ObjectUtil.copy(a));
							else cache = [ObjectUtil.copy(a)];
						}
					}
				}
			}
			function esInferiorAlMinimoPermitido(ventas:Array):Boolean {
				var len:int = ventas.length;
				for(var i:int = 0; i < len; i++) {
					var venta:Object = ventas[i];
					if (venta.monto<LIMITE.monto) return true
				}
				return false
			}
		}

		private function venta(e:Event,m:Message):void {
			vender(m.data,venta_handler)

			function venta_handler (result:Object):void {
				var msg:Message = new Message()
				msg.command="venta";
				msg.data = result;
				_cliente.sendMessage(msg)
				if (result && result.tk)
				Loteria.console.log("[Venta:SOCK:"+result.tk.taquillaID+"] #"+result.tk.ticketID);
        //Loteria.console.log("[Venta:SOCK:"+result.tk.taquillaID+"]",result.tk.ticketID, result.vt.length,"jugadas")
			}
		}
		
		public function smsResult (err:Object,data:Object=null):void {
			var m:Message = new Message;
			m.command = "sms-result";						
			if (err) m.data = err;
			else m.data = {
					num:data.numero,
					id:data._id
			};
			_cliente.sendMessage(m);
		}
		private function validarTopes (porJugar:Array,jugadas:Array,compartido:int=0):void {
			var tope:Tope; var sorteo:Sorteo;
			var i:int, j:int, index:int, tpl:int = _topes.length; 
			var mj:Object; var validar:Boolean=false;
			for each (var venta:Object in porJugar) {
				tope=null;
				sorteo = _model.mSorteos.getSorteo(venta.sorteoID);
				for (i = 0; i < tpl; i++) {
					if ((_topes[i].sorteo==sorteo.sorteo || _topes[i].sorteo==0) && (_topes[i].sorteoID==venta.sorteoID || _topes[i].sorteoID==0) && compartido==_topes[i].compartido) {
						if ((_topes[i].elemento==venta.numero || _topes[i].elemento==0) && compartido==_topes[i].compartido) {
							tope = _topes[i]; break;
						}
					}
				}
				if (tope) {
					tope = _topes[i];
					if (jugadas && jugadas.length>0) {						
						for (i = 0; i < jugadas.length; i++) {
							mj = jugadas[i];
							if (mj.sorteoID==venta.sorteoID && mj.numero==venta.numero) {
								var sum:Number = mj.monto+venta.monto;
								if (sum>tope.monto) { // sumatoria de jugada exede tope
									sum = tope.monto-mj.monto>0?tope.monto-mj.monto:0;
									addInvalido({s:venta.sorteoID,n:venta.numero,td:sum});
									break;
								}
							} else if (venta.monto > tope.monto) { // jugada exede tope
								venta.monto = tope.monto;
								addInvalido({s:venta.sorteoID,n:venta.numero,td:tope.monto});
								break;
							}
						}
					} else if (venta.monto > tope.monto) { // jugada exede tope
						venta.monto = tope.monto;
						addInvalido({s:venta.sorteoID,n:venta.numero,td:tope.monto});
					}
				}
			}
		}		
		private function addInvalido (item:Object):void {
			var l:int = invalidos.length;
			for (var i:int = l-1; i > -1; i--) {
				if (invalidos[i].n==item.n) {
					if (invalidos[i].td>item.td) {
						invalidos.removeAt(i); break;
					} else return;
				}
			}			
			invalidos.push(item);
		}
	}
}