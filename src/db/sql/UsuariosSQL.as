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
		public var usuarios_comer:SQLStatementPool;
		public var listaSuspender:SQLStatementPool;
		public var suspender_nuevo:SQLStatementPool;
		public var suspender_remover:SQLStatementPool;
		public var usuario_comer:SQLStatementPool;
		
		public function UsuariosSQL() {
			super('usuarios.sql');
			
			usuarios = new SQLStatementPool(sentencia("usuarios"),null,Usuario);
			usuario_id = new SQLStatementPool(sentencia("usuario_id"),null,Usuario);
			usuario_login = new SQLStatementPool(sentencia("usuario_login"),null,Usuario);
			
			scan();
		}
	}
}