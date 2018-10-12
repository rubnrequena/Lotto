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
	
	public class UsuariosModel extends EventDispatcher
	{		
		private var sql:UsuariosSQL;
		private var usr:Usuario;
		
		private var _usuarios:Vector.<Usuario>;
		
		public function UsuariosModel() {
			super();
			sql = new UsuariosSQL;			
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
		public function editar (filtro:Object,cb:Function,error:Function=null):void {
			if (filtro.hasOwnProperty("activo")) {
				sql.usuario_activar.run(filtro,function (r:SQLResult):void {
					
				},error);
			}
			else sql.usuario_editar.run(filtro,cb,error);
		}
		
		public function permisos (filtro:Object,cb:Function):void {
			sql.permisos.run(filtro,cb);
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
		
		public function usuarios (filtro:Object,cb:Function):void {
			if (filtro) {
				if (filtro.hasOwnProperty("id")) sql.usuario_id.run(filtro,cb);
				else if (filtro.hasOwnProperty("usuario")) sql.usuario_user.run(filtro,cb);
				else if (filtro.hasOwnProperty("comercial")) sql.usuarios_comer.run(filtro,cb);
				//filtrar por activos
				//filtrar por tipo
			} else sql.usuarios.run(null,cb);
		}
	}
}