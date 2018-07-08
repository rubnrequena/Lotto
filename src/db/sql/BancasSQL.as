package db.sql
{
	import db.SQLStatementPool;
	
	import vos.Banca;

	public class BancasSQL extends SQLBase
	{
		
		public var login:SQLStatementPool;
		public var bancas:SQLStatementPool;
		public var bancas_id:SQLStatementPool;
		public var bancas_usuario:SQLStatementPool;
		public var banca_nueva:SQLStatementPool;
				
		public var editar:SQLStatementPool;
		
		public var nombres:SQLStatementPool;
		public var nombres_usuario:SQLStatementPool;
		
		public var sql_sorteos_dia:SQLStatementPool;
		public var clave:SQLStatementPool;
		public var activa:SQLStatementPool;
		public var renta:SQLStatementPool;
		public var papelera:SQLStatementPool;
		
		public var meta:SQLStatementPool;
		public var comision:SQLStatementPool;
		
		public var relacion_pago_consulta:SQLStatementPool;
		public var relacion_pago_nuevo:SQLStatementPool;
		public var relacion_pago_editar:SQLStatementPool;
		
		public function BancasSQL() {
			super("bancas.sql");
			
			login = new SQLStatementPool('SELECT bancaID,nombre,usuario,renta,usuarioID,comision,activa FROM us.bancas WHERE usuario = :us AND clave = :cl',null,Banca);
			
			/*meta = new SQLStatementPool('SELECT mt.metaID metaID, meta_info.campo campo, CAST(valor AS INTEGER) valor FROM (SELECT * FROM us.meta WHERE (usuarioID = 0 OR usuarioID = :usuarioID) AND (bancaID = 0 OR bancaID = :bancaID) ORDER BY metaID) AS mt JOIN us.meta_info ON meta_info.metaID = mt.campoID GROUP BY campoID');
			
			editar = new SQLStatementPool('UPDATE us.bancas SET usuario = :usuario, nombre = :nombre, comision = :comision WHERE bancaID = :bancaID');
			activa = new SQLStatementPool('UPDATE us.bancas SET activa = :activa WHERE bancaID = :bancaID');
			comision = new SQLStatementPool('UPDATE us.bancas SET comision = :comision WHERE bancaID = :bancaID');
			clave = new SQLStatementPool('UPDATE us.bancas SET clave = :clave WHERE bancaID = :bancaID');
			renta = new SQLStatementPool('UPDATE us.bancas SET renta = :renta WHERE bancaID = :bancaID');
			papelera = new SQLStatementPool('UPDATE us.bancas SET papelera = :papelera WHERE bancaID = :bancaID');*/
			
			
			var s:String = sentencia("bancas");
			bancas = new SQLStatementPool(s,null,Banca);
			bancas_id = new SQLStatementPool(sentencia("bancas_id"),null,Banca);
			bancas_usuario = new SQLStatementPool(sentencia("bancas_usuario"),null,Banca);
			
			/*banca_nueva = new SQLStatementPool('INSERT INTO us.bancas (usuarioID,nombre,activa,usuario,clave,renta,comision,creacion) VALUES (:usuarioID,:nombre,:activa,:usuario,:clave,:renta,:comision,:creacion)',null);
			nombres = new SQLStatementPool('SELECT bancaID, nombre FROM us.bancas',null);
			nombres_usuario = new SQLStatementPool('SELECT bancaID, nombre FROM us.bancas WHERE usuarioID = :usuarioID',null);
			
			sql_sorteos_dia = new SQLStatementPool('SELECT sorteos.sorteoID, descripcion, cierra, ganador, SUM(monto) monto, SUM(premio) premio FROM us.sorteos LEFT JOIN (SELECT * FROM us.elementos WHERE anulado = 0) as elementos ON sorteos.sorteoID = elementos.sorteoID WHERE sorteos.fecha = :fecha GROUP BY sorteos.sorteoID');*/
			
			scan();
		}
	}
}