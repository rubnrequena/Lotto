package db.sql
{	
	import db.SQLStatementPool;
	
	import vos.Taquilla;

	public class TaquillasSQL
	{
		
		public var taquilla_nueva:SQLStatementPool;
		public var taquillas:SQLStatementPool;
		public var taquilla_id:SQLStatementPool;
		public var taquillas_usuario:SQLStatementPool;
		public var taquillas_banca:SQLStatementPool;
		
		public var taquilla_login:SQLStatementPool;
		public var taquilla_rem_bid:SQLStatementPool;
		public var taquilla_rem_uid:SQLStatementPool;
		public var taquilla_rem_us:SQLStatementPool;
		public var taquilla_edt_activa:SQLStatementPool;
		public var taquilla_editar:SQLStatementPool;
		public var taquilla_edt_clave:SQLStatementPool;
		public var taquilla_edt_papelera:SQLStatementPool;
		
		public var panic_banca:SQLStatementPool;		
		public var panic_usuario:SQLStatementPool;
		public var panic_off_banca:SQLStatementPool;
		public var panic_off_usuario:SQLStatementPool;
		
		public var metas:SQLStatementPool;
		public var meta:SQLStatementPool;
		public var meta_campo:SQLStatementPool;
		public var meta_nuevo:SQLStatementPool;
		public var taquillas_banca_usr:SQLStatementPool;
		public var taquillas_lista_banca:SQLStatementPool;
		
		public var transferir:SQLStatementPool;
		public var transferir_ventas:SQLStatementPool;
		public var transferir_reportes:SQLStatementPool;
		public var transferir_topes:SQLStatementPool;
		public var transferir_sorteos:SQLStatementPool;
		public var transferir_relacion:SQLStatementPool;
		
		public var fingerprint:SQLStatementPool;
		public var fingerlock_grp:SQLStatementPool;
		public var fingerlock_grp_all:SQLStatementPool;
		public var fingerlock_usr:SQLStatementPool;
		public var fingerlock_usr_all:SQLStatementPool;
		public var fingerclear_grp:SQLStatementPool;
		public var fingerclear_grp_all:SQLStatementPool;
		public var fingerclear_usr:SQLStatementPool;
		public var fingerclear_usr_all:SQLStatementPool;
		public var taquilla_usuario:SQLStatementPool;
		public var taquilla_id_banca:SQLStatementPool;
		public var taquilla_id_usuario:SQLStatementPool;
		public var taquillas_banca_act:SQLStatementPool;
		public var taquillas_usuario_act:SQLStatementPool;
		public var taquillas_usuariol:SQLStatementPool;
		
		public function TaquillasSQL() {
			
			taquillas = new SQLStatementPool('SELECT * FROM us.taquillas',null,Taquilla);
			taquillas_usuario = new SQLStatementPool('SELECT * FROM us.taquillas WHERE usuarioID = :usuario',null,Taquilla);
			taquillas_usuariol = new SQLStatementPool('SELECT nombre n, taquillaID id FROM us.taquillas WHERE usuarioID = :usuariol AND papelera = 0 AND activa = 1 ORDER BY nombre ASC');
			taquillas_banca = new SQLStatementPool('SELECT * FROM us.taquillas WHERE bancaID = :banca',null,Taquilla);
			
			taquillas_usuario_act = new SQLStatementPool('SELECT * FROM us.taquillas WHERE usuarioID = :usuario AND papelera = 0 AND activa = :activa',null,Taquilla);
			taquillas_banca_act = new SQLStatementPool('SELECT * FROM us.taquillas WHERE bancaID = :banca AND papelera = 0 AND activa = :activa',null,Taquilla);
			
			taquillas_lista_banca = new SQLStatementPool('SELECT taquillaID, nombre FROM us.taquillas WHERE bancaID = :lbanca AND papelera = 0');
			taquillas_banca_usr = new SQLStatementPool('SELECT * FROM us.taquillas WHERE bancaID = :bancaID AND usuarioID = :usuarioID',null,Taquilla);
			taquilla_usuario = new SQLStatementPool('SELECT * FROM us.taquillas WHERE usuario = :usr AND papelera = 0',null,Taquilla);
			
			taquilla_id = new SQLStatementPool('SELECT taquillas.taquillaID, taquillas.nombre, taquillas.usuarioID, taquillas.usuario, taquillas.clave, taquillas.bancaID, taquillas.activa, taquillas.comision, bancas.nombre "banca", bancas.activa "banca_activa" FROM us.taquillas JOIN us.bancas ON taquillas.bancaID = bancas.bancaID WHERE taquillaID = :id');
			taquilla_id_banca = new SQLStatementPool('SELECT taquillas.taquillaID, taquillas.nombre, taquillas.usuarioID, taquillas.usuario, taquillas.clave, taquillas.bancaID, taquillas.activa, taquillas.comision, bancas.nombre "banca", bancas.activa "banca_activa" FROM us.taquillas JOIN us.bancas ON taquillas.bancaID = bancas.bancaID WHERE taquillaID = :id AND taquillas.bancaID = :bancaID');
			taquilla_id_usuario = new SQLStatementPool('SELECT taquillas.taquillaID, taquillas.nombre, taquillas.usuarioID, taquillas.usuario, taquillas.clave, taquillas.bancaID, taquillas.activa, taquillas.comision, bancas.nombre "banca", bancas.activa "banca_activa" FROM us.taquillas JOIN us.bancas ON taquillas.bancaID = bancas.bancaID WHERE taquillaID = :id AND taquillas.usuarioID = :usuarioID');
			
			taquilla_login = new SQLStatementPool('SELECT taquillaID, taquillas.usuario, taquillas.usuarioID, taquillas.bancaID, taquillas.nombre, taquillas.activa, taquillas.comision, fingerprint, fingerlock FROM us.taquillas JOIN us.bancas ON bancas.bancaID = taquillas.bancaID JOIN us.usuarios ON usuarios.usuarioID = taquillas.usuarioID WHERE taquillas.usuario = :usuario AND taquillas.clave = :clave AND (taquillas.activa = 1 AND bancas.activa >= 1 AND usuarios.activo >= 1 AND taquillas.papelera = 0)',null,Taquilla);
			taquilla_nueva = new SQLStatementPool('INSERT INTO us.taquillas (usuarioID,bancaID,nombre,usuario,clave,activa,comision,creacion) VALUES (:usuarioID,:bancaID,:nombre,:usuario,:clave,:activa,:comision,:creacion)',null);
			taquilla_rem_bid = new SQLStatementPool('DELETE FROM us.taquillas WHERE taquillaID = :taquillaID AND bancaID = :bancaID');
			taquilla_rem_uid = new SQLStatementPool('DELETE FROM us.taquillas WHERE taquillaID = :taquillaID AND usuarioID = :usuarioID');
			taquilla_rem_us = new SQLStatementPool('DELETE FROM us.taquillas WHERE usuarioID = :usuarioID');
			taquilla_edt_activa = new SQLStatementPool('UPDATE us.taquillas SET activa = :activa WHERE taquillaID = :taquillaID');
			taquilla_edt_clave = new SQLStatementPool('UPDATE us.taquillas SET clave = :clave WHERE taquillaID = :taquillaID');
			taquilla_edt_papelera = new SQLStatementPool('UPDATE us.taquillas SET papelera = :papelera WHERE taquillaID = :taquillaID AND (bancaID = :bancaID OR usuarioID = :usuarioID)');
			taquilla_editar = new SQLStatementPool('UPDATE us.taquillas SET nombre = :nombre, usuario = :usuario, comision = :comision WHERE taquillaID = :taquillaID');
			
			panic_banca = new SQLStatementPool('UPDATE us.taquillas SET activa = 0 WHERE activa = 1 AND bancaID = :bancaID');
			panic_usuario = new SQLStatementPool('UPDATE us.taquillas SET activa = 0 WHERE activa = 1 AND usuarioID = :usuarioID');
						
			/*panic_off_banca = new SQLStatementPool('UPDATE us.taquillas SET activa = 1 WHERE activa = -1 AND bancaID = :bancaID');
			panic_off_usuario = new SQLStatementPool('UPDATE us.taquillas SET activa = 1 WHERE activa = -1 AND usuarioID = :usuarioID');*/
			
			metas = new SQLStatementPool('SELECT * FROM (SELECT taquillaID, taquillas_meta.campo, taquillas_meta.valor FROM taquillas_meta WHERE taquillaID = 0 OR taquillaID = :taquillaID ORDER BY taquillaID ASC) GROUP BY campo');
			meta = new SQLStatementPool('UPDATE taquillas_meta SET valor = :valor WHERE taquillaID = :taquillaID AND campo = :campo');
			meta_nuevo = new SQLStatementPool('INSERT INTO taquillas_meta (valor,campo,taquillaiD) VALUES (:valor,:campo,:taquillaID)');
			meta_campo = new SQLStatementPool('SELECT bancaID, taquillaID, CAST(valor AS INTEGER) valor FROM us.meta WHERE campoID = :campoID ORDER BY taquillaID DESC, bancaID DESC',null);
			
			transferir = new SQLStatementPool("UPDATE us.taquillas SET bancaID = :hasta WHERE taquillaID = :taquillaID AND bancaID = :desde");
			transferir_topes = new SQLStatementPool('UPDATE us.topes SET bancaID = :hasta WHERE taquillaID = :taquillaID AND bancaID = :desde');
			transferir_sorteos = new SQLStatementPool('UPDATE us.taquillas_sorteo SET bancaID = :hasta WHERE taquillaID = :taquillaID AND bancaID = :desde');
			transferir_relacion = new SQLStatementPool('UPDATE us.relacion_pago SET bancaID = :hasta WHERE taquillaID = :taquillaID AND bancaID = :desde');
			transferir_ventas = new SQLStatementPool('UPDATE vt.ticket SET bancaID = :hasta WHERE taquillaID = :taquillaID AND bancaID = :desde');
			transferir_reportes = new SQLStatementPool('UPDATE vt.reportes SET bancaID = :hasta WHERE taquillaID = :taquillaID AND bancaID = :desde');
			
			fingerprint = new SQLStatementPool('UPDATE us.taquillas SET fingerprint = :fp WHERE taquillaID = :taquillaID');
			fingerlock_grp = new SQLStatementPool('UPDATE us.taquillas SET fingerlock = :activa WHERE taquillaID = :taquillaID AND bancaID = :bancaID');
			fingerlock_grp_all = new SQLStatementPool('UPDATE us.taquillas SET fingerlock = :activa WHERE bancaID = :bancaID');
			fingerlock_usr = new SQLStatementPool('UPDATE us.taquillas SET fingerlock = :activa WHERE taquillaID = :taquillaID AND usuarioID = :usuarioID');
			fingerlock_usr_all = new SQLStatementPool('UPDATE us.taquillas SET fingerlock = :activa WHERE usuarioID = :usuarioID');
			
			fingerclear_grp = new SQLStatementPool('UPDATE us.taquillas SET fingerprint = null WHERE taquillaID = :taquillaID AND bancaID = :bancaID');
			fingerclear_grp_all = new SQLStatementPool('UPDATE us.taquillas SET fingerprint = null WHERE bancaID = :bancaID');
			fingerclear_usr = new SQLStatementPool('UPDATE us.taquillas SET fingerprint = null WHERE taquillaID = :taquillaID AND usuarioID = :usuarioID');
			fingerclear_usr_all = new SQLStatementPool('UPDATE us.taquillas SET fingerprint = null WHERE usuarioID = :usuarioID');
			
		}
	}
}