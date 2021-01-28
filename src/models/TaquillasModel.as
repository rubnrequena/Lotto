package models
{
	import flash.data.SQLResult;
	import flash.errors.SQLError;
	import flash.events.Event;
	
	import be.aboutme.airserver.Client;
	import be.aboutme.airserver.messages.Message;
	
	import db.DB;
	import db.SQLStatementPool;
	import db.sql.TaquillasSQL;
	
	import helpers.DateFormat;
	
	import starling.events.EventDispatcher;
	import starling.utils.StringUtil;
	import starling.utils.execute;
	
	import vos.Taquilla;
	import flash.utils.getTimer;
	import by.blooddy.crypto.MD5;
	import vos.Sesion;
	import helpers.Code;
	
	public class TaquillasModel extends EventDispatcher
	{			
		private var sql:TaquillasSQL;
		
		private var taquillas:Vector.<Taquilla>;
		private var clientes:Vector.<Client>;
		private var msgDuplicado:Message;
		private var sessions:Array;
		
		public function TaquillasModel() {
			super();
			sql = new TaquillasSQL;
			sessions = new Array;
			
			taquillas = new Vector.<Taquilla>;
			clientes = new Vector.<Client>;
			msgDuplicado = new Message;
			msgDuplicado.command = 'duplicado';
			
			//addEventListener(starling.events.Event.CLOSE,onClose);
		}
		
		private function onClose(e:starling.events.Event,taq:Taquilla):void { 
			var i:int = buscarClienteIndex("taquillaID",taq.taquillaID);
			if (i>-1) {
				/*clientes[i].sendMessage(msgDuplicado); //FIX 170413: desconectar taquilla duplicada
				clientes.removeAt(i);*/
				taquillas.removeAt(i);
			}
		}
		public function httpSesion(session:String):Sesion {
			var i:int;
			for each(var s:Sesion in sessions) {
				if (s.hash==session) {
					if (s.esValida) return s;
					else {
						sessions.removeAt(i);
						return null;
					}
				}
				i++;
			}
			return null;
		}
		public function httpLogin (usuario:String,clave:String,res:Function):void {
			sql.taquilla_login.run({"usuario":usuario,"clave":clave},function (r:SQLResult):void {
				if (!r.data) {res({error:"usuario no existe"}); return};
				var taq:Taquilla = r.data[0];
				if (taq.activa==0) {res({error:"usuario inactivo"}); return};
				//TODO: notificar inicio de sesion a otros usuarios
				//registra sesion
				var now:int = getTimer();

				var sesion:Sesion = new Sesion(taq);
				sessions.push(sesion);
				res({"sesion":sesion.hash,"taq":taq});
			});
		}
		public function login (login:Object,cl:Client,cb:Function):void {
			sql.taquilla_login.run(login,function (r:SQLResult):void {
				if (r.data) {
					var taq:Taquilla = r.data[0];
					if (taq.estaActiva!=5) {
						execute(cb,null,{code:Code.SUSPENDIDO}); return
					}
					if (!taq.fingerlock) {
						for (var i:int = 0; i < taquillas.length; i++) { // prevenir sesiones multiples
							if (login.usuario==taquillas[i].usuario) {
								clientes[i].sendMessage(msgDuplicado);
								clientes[i].close();
								//clientes.removeAt(i).dispatchEvent(new flash.events.Event("close"));
								//taquillas.removeAt(i);
							}
						}
					}
					taquillas.push(taq);
					clientes.push(cl);
					cl.addEventListener(Event.CLOSE,cliente_onClose);
					execute(cb,taq);
				} else execute(cb,null,{code:Code.NO_EXISTE});
				//registar ultimo login de taquilla
				//dispatchEventWith(ModelEvent.LOGIN,null,taq);
			});
		}
		
		protected 	function cliente_onClose(event:Event):void {
			var i:int = clientes.indexOf(event.target as Client);
			if (i>-1) {
				clientes.removeAt(i);
				taquillas.removeAt(i);
			}
		}
		public function explorarClientes (campo:String,valor:*):Vector.<Taquilla> {
			var c:Vector.<Taquilla> = new Vector.<Taquilla>;
			for each (var taq:Taquilla in taquillas) {
				if (taq[campo]==valor) c.push(taq);
			}
			return c;
		}
		public function buscarClienteIndex (campo:String,valor:*):int {
			var len:int = taquillas.length;
			for (var i:int = 0 ; i < len; i++) {
				if (valor==taquillas[i][campo]) return i;
			}
			return -1;
		}
		public function buscarCliente (campo:String,valor:*):Taquilla {
			var len:int = taquillas.length-1;
			for (var i:int = len; i >= 0; i--) {
				if (valor==taquillas[i][campo]) return taquillas[i];
			}
			return null;
		}
		public function executeCliente (campo:String,valor:*,exe:Function):void {
			var len:int = taquillas.length-1;
			for (var i:int = len; i >= 0; i--) {
				if (valor==taquillas[i][campo]) execute(exe,taquillas[i],i);
			}
		}
		public function desconectarCliente (index:int):void {
			if (index>-1) {
				var c:Client = clientes[index]
				c.close();
				//clientes.removeAt(index);
				//taquillas.removeAt(index);
			}
		}
		public function buscar_taqID(taquillaID:int,cb:Function):void {
			sql.taquilla_id.run({id:taquillaID},function (r:SQLResult):void {
				if (!r.data) execute(cb,'taquilla no existe')
        else execute(cb,null,r.data.pop())
			});
		}
		public function buscar (filtro:Object,cb:Function):void {
			if (filtro) {
				if (filtro.hasOwnProperty("id")) {
					if (filtro.hasOwnProperty("usuarioID")) sql.taquilla_id_usuario.run(filtro,cb);
					else if (filtro.hasOwnProperty("bancaID")) sql.taquilla_id_banca.run(filtro,cb);
					else sql.taquilla_id.run(filtro,cb);
				}
				else if (filtro.hasOwnProperty("usuario")) sql.taquillas_usuario.run(filtro,cb);
				else if (filtro.hasOwnProperty("usuariol")) sql.taquillas_usuariol.run(filtro,cb);
				else if (filtro.hasOwnProperty("banca")) sql.taquillas_banca.run(filtro,cb);
				else if (filtro.hasOwnProperty("usuarioID")) sql.taquillas_banca_usr.run(filtro,cb);
				else if (filtro.hasOwnProperty("usr")) sql.taquilla_usuario.run(filtro,cb);
			} else sql.taquillas.run(null,cb,null,100);
		}
		
		public function buscar_activa (filtro:Object,cb:Function):void {
			if (filtro.hasOwnProperty("banca")) sql.taquillas_banca_act.run(filtro,cb);
			else if (filtro.hasOwnProperty("usuario")) sql.taquillas_usuario_act.run(filtro,cb); 
		}
		
		public function nueva (taq:Object,cb:Function,error:Function):void {
			taq.usuario = StringUtil.trim((taq.usuario as String).toLowerCase());
			taq.clave = (taq.clave as String).toLowerCase();
			taq.creacion = DateFormat.format(null,DateFormat.masks["default"]);
			buscar({usr:taq.usuario},function (r:SQLResult):void {
				if (r.data) {
					var e:SQLError = new SQLError("INSERT INTO us.taquilla");
					execute(error,e);
				} else {
					sql.taquilla_nueva.run(taq,function (r:SQLResult):void {
						taq.taquillaID = r.lastInsertRowID;
						execute(cb,r.lastInsertRowID);
						dispatchEventWith(Event.ADDED,false,taq);
					},error);
				}
			});
		}
		public function remover (filtro:Object,cb:Function):void {
			if (filtro.hasOwnProperty("taquillaID")) {
				if (filtro.hasOwnProperty("bancaID")) sql.taquilla_rem_bid.run(filtro,removerHandler);
				else if (filtro.hasOwnProperty("usuarioID")) sql.taquilla_rem_uid.run(filtro,removerHandler);
			}
			//else if (filtro.hasOwnProperty("usuarioID")) sql.taquilla_rem_us.run(filtro,removerHandler);
			
			function removerHandler (r:SQLResult):void {
				execute(cb,r.rowsAffected);
				dispatchEventWith(Event.REMOVED,filtro);
			}
		}
		public function editar_activa (taq:Object,cb:Function):void {
			//TODO: validar banca
			sql.taquilla_edt_activa.run(taq,function (r:SQLResult):void {
				if (taq.activa==false) {
					var i:int = buscarClienteIndex("taquillaID",taq.taquillaID);
					desconectarCliente(i);
				}
				execute(cb,r);
			});
		}
		public function panic (filtro:Object,cb:Function):void {
			if (filtro.hasOwnProperty("bancaID")) {
				sql.panic_banca.run(filtro,bancaHandler);	
			} else if (filtro.hasOwnProperty("usuarioID")) {
				sql.panic_usuario.run(filtro,usuarioHandler);
			}
			
			function bancaHandler (r:SQLResult):void {
				executeCliente("bancaID",filtro.bancaID,desconectar);
				execute(cb,r.rowsAffected);
			}
			function usuarioHandler (r:SQLResult):void {
				executeCliente("usuarioID",filtro.usuarioID,desconectar);
				execute(cb,r.rowsAffected);
			}
			
			function desconectar (taq:Taquilla,index:int):void {
				Loteria.console.log("DESCONECTANDO",taq.nombre);
				clientes[index].close();
			}
		}
		public function editar (taq:Object,cb:Function,error:Function=null):void {
			if (taq.hasOwnProperty("clave")) sql.taquilla_edt_clave.run(taq,cb);
			else if (taq.hasOwnProperty("papelera")) sql.taquilla_edt_papelera.run(taq,cb);
			else if (taq.hasOwnProperty("activa")) {
				sql.taquilla_edt_activa.run(taq,function (r:SQLResult):void {
					execute(cb,r);
					if (taq.activa==false) {
						var i:int = buscarClienteIndex("taquillaID",taq.taquillaID);
						desconectarCliente(i);
					}
				});
			}
			else sql.taquilla_editar.run(taq,cb,error);
		}
		public function meta (s:Object,cb:Function):void {
			sql.meta.run(s,function (r:SQLResult):void {
				if (r.rowsAffected>0) execute(cb,r);
				else sql.meta_nuevo.run(s,cb);
			});
		}
		public function metas (s:Object,cb:Function):void {
			sql.metas.run(s,function result (r:SQLResult):void {
				var m:Object = {};
				for each (var row:Object in r.data) m[row.campo] = row.valor;
				execute(cb,m);
			});
		}
		public function meta_campo (s:Object,cb:Function):void {
			sql.meta_campo.run(s,cb);
		}
		
		public function transferir (taq:Object,ventas:Boolean,cb:Function):void {
			var result:int=0;
			sql.transferir.run(taq,function (r:SQLResult):void {
				result=1;
				if (ventas) {
					db.DB.batch(Vector.<SQLStatementPool>([
						sql.transferir_reportes,
						sql.transferir_ventas,
						sql.transferir_topes,
						sql.transferir_sorteos,
						sql.transferir_relacion
					]),onComplete,onError,taq);
				} else execute(cb,result);
			});
			
			function onComplete ():void {
				result=2;
				execute(cb,result);
			}
			function onError (e:SQLError):void {
				execute(cb,result);
			}
		}
		
		
		public function sendTo (taquillaID:int,msg:Message):void {
			var i:int = buscarClienteIndex("taquillaID",taquillaID);
			if (i>-1) {
				clientes[i].sendMessage(msg);
			}
		}
		
		public function fingerprint(data:Object,cb:Function):void {
			sql.fingerprint.run(data,cb);
		}
		
		public function fingerClear_grupo (data:Object,cb:Function):void {
			if (data.hasOwnProperty("taquillaID")) sql.fingerclear_grp.run(data,cb);
			else sql.fingerclear_grp_all.run(data,cb);
		} 
		public function fingerClear_usuario (data:Object,cb:Function):void {
			if (data.hasOwnProperty("taquillaID")) sql.fingerclear_usr.run(data,cb);
			else sql.fingerclear_usr_all.run(data,cb);
		} 
		
		public function fingerlock_grupo (data:Object,cb:Function):void {
			if (data.hasOwnProperty("taquillaID")) sql.fingerlock_grp.run(data,cb);
			else sql.fingerlock_grp_all.run(data,cb);
		}
		public function fingerlock_usuario (data:Object,cb:Function):void {
			if (data.hasOwnProperty("taquillaID")) sql.fingerlock_usr.run(data,cb);
			else sql.fingerlock_usr_all.run(data,cb)
		}
		public function fingerlock (data:Object,cb:Function):void {
			if (data.hasOwnProperty("taquillaID")) sql.fingerlock.run(data,cb);
		}
		public function fingerclear (data:Object,cb:Function):void {
			if (data.hasOwnProperty("taquillaID")) sql.fingerclear.run(data,cb);
		}
	
		public function comisiones (data:Object,cb:Function):void {
			if (data.hasOwnProperty("taquillaID")) sql.comisiones_taquilla.run(data,cb);
			else if (data.hasOwnProperty("grupoID")) sql.comisiones_grupo.run(data,cb);
			else if (data.hasOwnProperty("bancaID")) sql.comisiones_banca.run(data,cb);
		}
		public function comision_nv (data:Object,cb:Function):void {
			sql.comision_nueva.run(data,cb);
		}
		public function comision_dl(data:Object,cb:Function):void {
			sql.comision_remover.run(data,cb);
		}
		public function estaActiva (id:int,cb:Function):void {
			sql.taquilla_activa.run({tID:id},function (res:SQLResult):void {
				if (res.data) execute(cb,true);
				else execute(cb,false);
			});
		}

		public function meta_remover_banca(metaID:int,cb:Function):void {
			sql.meta_remover_banca.run({metaID:metaID},cb)
		}
		public function meta_registrar_banca(data:Object,cb:Function):void {
			sql.meta_validar_existe.run(data,function (r:SQLResult):void {
				if (r.data) {
					var meta:Object = r.data[0]
					sql.meta_actualizar_banca.run({metaID:meta.metaID,valor:data.valor},cb)
				} else sql.meta_registrar_banca.run(data,cb)
			})
			
		}

		public function sesiones(fecha:String,bancaID:int,cb:Function):void {
			var params:Object = {
				fecha:fecha,
				bancaID:bancaID
			}
			sql.sesiones.run(params,function (result:SQLResult):void {
				cb(result.data)
			})
		}
	}
}