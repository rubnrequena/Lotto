package db.sql
{
	import db.SQLStatementPool;
	
	import vos.Usuario;

	public class UsuariosSQL extends SQLBase
	{
		public var usuarios:SQLStatementPool;
		public var usuario_login:SQLStatementPool;
		public var usuario_id:SQLStatementPool;
		public var usuario_user:SQLStatementPool;
		public var usuario_nuevo:SQLStatementPool;
		
		public var permisos:SQLStatementPool;
		public var permiso_update:SQLStatementPool;
		public var meta_nuevo:SQLStatementPool;
		public var permiso_remove:SQLStatementPool;
		public var usuario_editar:SQLStatementPool;
		public var usuario_activar:SQLStatementPool;
		public var cm_login:SQLStatementPool;
		
		public function UsuariosSQL() {
			super('usuarios.sql');
			
			usuarios = new SQLStatementPool(sentencia("usuarios"),null,Usuario);
			usuario_id = new SQLStatementPool(sentencia("usuario_id"),null,Usuario);
			usuario_login = new SQLStatementPool(sentencia("usuario_login"),null,Usuario);
			
			/*usuario_user = new SQLStatementPool('');
			usuario_nuevo = new SQLStatementPool('');
			usuario_editar = new SQLStatementPool('');
			usuario_activar = new SQLStatementPool('');
			
			permisos = new SQLStatementPool('');
			meta_nuevo = new SQLStatementPool('');
			permiso_update = new SQLStatementPool('');
			permiso_remove = new SQLStatementPool('');*/
			
			
			
			scan();
		}
	}
}