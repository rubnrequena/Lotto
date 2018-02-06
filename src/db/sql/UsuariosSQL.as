package db.sql
{
	import db.SQLStatementPool;
	
	import vos.Usuario;

	public class UsuariosSQL
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
		
		public function UsuariosSQL() {
			
			usuarios = new SQLStatementPool('SELECT * FROM us.usuarios',null,Usuario);
			usuario_id = new SQLStatementPool('SELECT * FROM us.usuarios WHERE usuarioID = :id',null,Usuario);
			usuario_user = new SQLStatementPool('SELECT * FROM us.usuarios WHERE usuario = :usuario');
			usuario_login = new SQLStatementPool('SELECT usuarioID,usuario,nombre,tipo,activo,renta FROM us.usuarios WHERE usuario = :us AND clave = :cl',null,Usuario);
			usuario_nuevo = new SQLStatementPool('INSERT INTO us.usuarios (usuario,clave,nombre,tipo,registrado,activo,renta) VALUES (:usuario,:clave,:nombre,:tipo,:registrado,:activo,:renta)');
			usuario_editar = new SQLStatementPool('UPDATE us.usuarios SET usuario = :usuario, nombre = :nombre, clave = :clave, renta = :renta WHERE usuarioID = :usuarioID');
			usuario_activar = new SQLStatementPool('UPDATE us.usuarios SET activo = :activo WHERE usuarioID = :usuarioID');
			
			permisos = new SQLStatementPool('SELECT meta.usuarioID, bancas.nombre, metaID, campoID, CAST(meta.valor AS INTEGER) valor FROM us.meta LEFT JOIN us.bancas ON bancas.bancaID = meta.bancaID WHERE (meta.usuarioID = 0 OR meta.usuarioID = :usuarioID) GROUP BY meta.bancaID, meta.campoID ORDER BY meta.bancaID');
			meta_nuevo = new SQLStatementPool('INSERT INTO us.meta (usuarioID,bancaID,campoID,valor) VALUES (:usuarioID, :bancaID, :campoID, :valor)');
			permiso_update = new SQLStatementPool('UPDATE us.meta SET valor = :valor WHERE metaID = :meta AND usuarioID = :usuarioID');
			permiso_remove = new SQLStatementPool('DELETE FROM us.meta WHERE metaID = :meta AND usuarioID = :usuarioID');
		}
	}
}