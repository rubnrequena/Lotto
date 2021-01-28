package models
{
	import flash.data.SQLResult;
	import flash.errors.SQLError;
	
	import db.DB;
	import db.sql.UsuariosSQL;
	
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.utils.StringUtil;
	import starling.utils.execute;
	
	import vos.Usuario;
	import helpers.DateFormat;
	import vos.Limite;
	import vos.Taquilla;
	
	public class UsuariosModel extends EventDispatcher
	{		
		private var sql:UsuariosSQL;
		private var usr:Usuario;
		private const rID:RegExp = /\d+/;
		public var LIMITES:Array = []
				
		public function UsuariosModel() {
			super();
			sql = new UsuariosSQL;			
		}
		
		public function listaSuspender (usuario:String,cb:Function):void {
			sql.listaSuspender.run({resID:usuario},cb);
		}
		
		public function suspender_nuevo (data:Object,cb:Function):void {
			sql.suspender_nuevo.run(data,cb);
		}
		public function suspender_remover (data:Object,cb:Function):void {
			sql.suspender_remover.run(data,cb);
		}
		
		public function nuevo (usuario:Object,cb:Function):void {			
			usuario.registrado = (new Date).time;
			usuario.clave = StringUtil.trim(usuario.clave).toLowerCase();
			usuario.usuario = StringUtil.trim(usuario.usuario).toLowerCase();
			sql.usuario_nuevo.run(usuario,function (r:SQLResult):void {
				usuario.usuarioID = r.lastInsertRowID;
				execute(cb,r.lastInsertRowID);
				dispatchEventWith(Event.ADDED,false,usuario);
			},function (e:SQLError):void {
				execute(DB.ERROR_HANDLER,e);
				execute(cb,-1);
			});
		}
		
		public function login (login:Object,cb:Function):void {
			sql.usuario_login.run(login,function (r:SQLResult):void {
				usr = r.data?r.data[0]:null;
				execute(cb,usr);
				//registrar ultimo login de usuario
				dispatchEventWith(ModelEvent.LOGIN,false,usr);
			});
		}
		public function editar (filtro:Object,cb:Function=null,error:Function=null):void {
			if (filtro.hasOwnProperty("activo")) {
				sql.usuario_activar.run(filtro,cb);
			}
			else sql.usuario_editar.run(filtro,cb,error);
		}
		public function clave (usuario:Object,cb:Function):void {
			sql.usuario_clave.run(usuario,cb)
		}
		
		public function permisos (filtro:Object,cb:Function):void {
			      sql.permisos.run(filtro,cb);
		}
		public function permisos_banca (filtro:Object,cb:Function):void {
			sql.permisos_banca.run(filtro,cb);
		}
		public function permisos_campo (campo:int,usuarioID:int,bancaID:int,cb:Function):void {
			sql.permiso_tipo.run({
				campo: campo,
				usuarioID: usuarioID,
				bancaID:bancaID
			},function (r:SQLResult):void {
			  execute(cb,r.data)
			})
		}
		public function permiso_nuevo (metas:Array,cb:Function):void {
			sql.meta_nuevo.batch_nocommit(metas,cb);
		}
		public function permiso_update (meta:Object,cb:Function):void {
			sql.permiso_update.run(meta,cb);
		}
		public function permiso_remove (meta:Object,cb:Function):void {
			sql.permiso_remove.run(meta,cb);
		}
		public function usuario (usID:String,cb:Function,error:Function=null):void {
			var indice:String = usID.charAt(0);
			var uID:int = rID.exec(usID)[0];
			if (indice=='c') sql.comercialID.run({id:uID},usuarioResult)
			else if (indice=="u"||indice=="a") sql.usuarioID.run({id:uID},usuarioResult)
			else if (indice=="g") sql.bancaID.run({id:uID},usuarioResult)
			else if (indice=="t") sql.taquillaID.run({id:uID},usuarioResult)

			function usuarioResult(usuarios:SQLResult):void {
				if (usuarios.data) execute(cb,usuarios.data[0])
				else execute(error,'usuario no existe',usID);
			}
		}
		
		public function usuarios (filtro:Object,cb:Function):void {
			if (filtro) {
				if (filtro.hasOwnProperty("id")) sql.usuario_id.run(filtro,cb);
				else if (filtro.hasOwnProperty('uid')) {
					sql.usuario_id.run({id:filtro.uid},function (res:SQLResult):void {
						if (res.data) execute(cb,res.data[0])
						else execute(cb,null)
					})
				} else if (filtro.hasOwnProperty("usuario")) sql.usuario_user.run(filtro,cb);
				else if (filtro.hasOwnProperty("comercial")) sql.usuarios_comer.run(filtro,cb);
				//filtrar por activos
				//filtrar por tipo
			} else sql.usuarios.run(null,cb);
		}
		public function usuario_comer (uID:int,cb:Function):void {
			sql.usuario_comer.run({uid:uID},cb);
		}
		public function usuario_comercial(usuarioID:int,cb:Function):void {
			sql.usuario_comercial.run({usuarioID:usuarioID},function (res:SQLResult):void {
				if (res.data) cb(res.data[0])
				else cb(null)
			});
		}
		public function destinos (s:Object,cb:Function):void {
			if (s.hasOwnProperty('uID')) sql.mensajes_destinos.run(s,cb)
		}

		public function comision_producto_nuevo (s:Object,cb:Function):void {
			sql.comision_producto_nuevo.run(s,cb)
		}
		public function comision_producto_remover (s:Object,cb:Function):void {
			sql.comision_producto_remover.run(s,cb)
		}

		public function comisiones_banca(s:Object,cb:Function):void {
			sql.comisiones_banca.run(s,function (r:SQLResult):void {
				execute(cb,r.data)
			});
		}
		public function comisiones_usuario (s:Object,cb:Function):void {
			sql.comisiones_usuario.run(s,cb);
		}
		public function comisiones_grupo(s:Object,cb:Function):void {
			sql.comisiones_grupo.run(s,cb);
		}

		public function nuevaSesion (usuarioID:int,tipo:int,ip:String):void {
			var ahora:Date = new Date();
			var params:Object = {
				usuario:usuarioID,
				tipo:tipo,
				fecha:DateFormat.format(ahora),
				tiempo: DateFormat.format(ahora,DateFormat.masks.mediumTime),
				ip:ip
			}
			sql.nueva_sesion.run(params,null)
		}

		public function nuevoLimite (banca:int,grupo:int,monto:Number,cb:Function):void {
			var params:Object = {
				banca:banca,
				grupo:grupo,
				monto:monto,
				fecha:DateFormat.format(null,DateFormat.masks.isoDateTime)
			}
			sql.limite_nuevo.run(params,function limiteNuevo_ok(result:SQLResult):void {
				cb(null,result)
			},function limiteNuevo_error(error:SQLError):void {
				cb(error,null)
			})
		}
/* 
		public function limites(cb:Function):void {
			sql.limites.run(null,function (result:SQLResult):void {
				cb(result.data)
			})
		} */

		public function buscar_limite (grupo:int,cb:Function):void {
			var params:Object = {
				grupo:grupo
			}
			sql.buscar_limite.run(params,function (result:SQLResult):void {
				if (!result.data) cb(null);
				else cb(result.data[0]) 
			})
		}
	}
}