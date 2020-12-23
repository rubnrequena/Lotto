package models
{
	import flash.data.SQLResult;
	
	import db.sql.ComerSQL;
	
	import starling.events.EventDispatcher;
	import starling.utils.execute;
	
	import vos.Usuario;
	
	public class ComercializadoraModel extends EventDispatcher
	{
		private var cm:Usuario;
		private var sql:ComerSQL = new ComerSQL;
		
		public function ComercializadoraModel() {
			super();
		}
		
		public function comercializadoras (s:Object,cb:Function):void {
			sql.comercializadoras.run(s,cb);
		}
		
		public function login (login:Object,cb:Function):void {
			sql.login.run(login,function (r:SQLResult):void {
				cm = r.data?r.data[0]:null;
				execute(cb,cm);
				//registrar ultimo login de usuario
				dispatchEventWith(ModelEvent.LOGIN,false,cm);
			});
		}
		
		public function usuarios (cm:Object,cb:Function):void {
			sql.usuarios.run(cm,cb);
		}
		public function hijos (comercialID:int,cb:Function):void {
			sql.hijos.run({comercialID:comercialID},cb)
		}
		
		public function linkUsuario (data:Object,cb:Function):void {
			sql.link.run(data,cb);
		}
		public function tope_nuevo (data:Object,cb:Function):void {
			sql.tope_nuevo.run(data,cb)
		}
		public function tope_remover (elemento:int,comercial:int,cb:Function):void {
			sql.tope_delete.run({
				elemento:elemento,
				comercial: comercial
			},cb)
		}
	}
}