package db.sql
{
	import db.SQLStatementPool;
	
	import vos.Usuario;
	import vos.UsuarioMin;

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
		public var usuario_clave:SQLStatementPool;
		public var usuario_editar:SQLStatementPool;
		public var usuario_activar:SQLStatementPool;
		public var usuarios_comer:SQLStatementPool;
		public var listaSuspender:SQLStatementPool;
		public var suspender_nuevo:SQLStatementPool;
		public var suspender_remover:SQLStatementPool;
		public var usuario_comer:SQLStatementPool;

		public var mensajes_destinos:SQLStatementPool;

		public var bancaID:SQLStatementPool;
		public var taquillaID:SQLStatementPool;
		public var usuarioID:SQLStatementPool;
		public var comercialID:SQLStatementPool;
		
		public function UsuariosSQL() {
			super('usuarios.sql');
			
			usuarios = new SQLStatementPool(sentencia("usuarios"),null,Usuario);
			usuario_id = new SQLStatementPool(sentencia("usuario_id"),null,Usuario);
			usuario_login = new SQLStatementPool(sentencia("usuario_login"),null,Usuario);
			
			bancaID = new SQLStatementPool(sentencia('bancaID'),null,UsuarioMin)
			taquillaID = new SQLStatementPool(sentencia('taquillaID'),null,UsuarioMin)
			usuarioID = new SQLStatementPool(sentencia('usuarioID'),null,UsuarioMin)
			comercialID = new SQLStatementPool(sentencia('comercialID'),null,UsuarioMin)

			scan();
		}
	}
}