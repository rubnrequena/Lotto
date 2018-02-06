package models
{
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	import flash.filesystem.File;
	import flash.net.Responder;
	
	import db.SQLStatementPool;
	import db.sql.ServidorSQL;
	
	import starling.events.EventDispatcher;
	import starling.utils.execute;
	
	public class ServidorModel extends EventDispatcher
	{
		private var sql:ServidorSQL;
		private var sql_stat:SQLStatement;
		
		public function ServidorModel()
		{
			super();
			var rootDB:File = new File(Loteria.setting.db.root);
			var sistemaDB:File = rootDB.resolvePath("sistema.sqlite");
			var usuariosDB:File = rootDB.resolvePath("usuarios.sqlite");
			var ventasDB:File = rootDB.resolvePath("ventas.sqlite");
			
			sql_stat = new SQLStatement;
			sql_stat.sqlConnection = SQLStatementPool.ADMIN_CONN;		
			
			sql = new ServidorSQL;
		}
		
		public function login (s:Object,cb:Function):void {
			sql.login.run(s,function login_result (r:SQLResult):void {
				if (r.data) execute(cb,r.data[0]);
				else execute(cb,null);
			});
		}
		
		public function sorteos (s:Object,cb:Function):void {
			sql.sorteos_admin.run(s,cb);
		}
		public function numeros (s:Object,cb:Function):void {
			sql.numeros_admin.run(s,cb);
		}
		public function est_inicio (fecha:String,cb:Function):void {
			sql.sorteos_dia.run({fecha:fecha},cb);
		}
		public function sqlc (sentencia:String,cb:Function,err:Function):void {
			if (SQLStatementPool.ADMIN_CONN.inTransaction) {
				execute(err,new SQLError("Conexion ocupada","Conexion ocupada","Conexion ocupada",404));
			} else {
				sql_stat.text = sentencia;
				sql_stat.execute(-1,new Responder(cb,err));
			}
		}
		public function usuario_reg_sorteo (s:Object,cb:Function):void {
			sql.usuario_reg_sorteo.run(s,cb);
		}
		public function usuario_del_sorteo (s:Object,cb:Function):void {
			sql.usuario_del_sorteo.run(s,cb);
		}
		public function usuario_sorteos (s:Object,cb:Function):void {
			if (s.hasOwnProperty("sorteo")) sql.usuario_sorteo_id.run(s,cb);
			else sql.usuario_sorteos.run(s,cb);
		}
	}
}