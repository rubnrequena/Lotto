package db.sql
{
	import db.SQLStatementPool;
	
	import vos.PreSorteo;
	import vos.Sorteo;

	public class SorteosSQL extends SQLBase
	{
		public var nuevo:SQLStatementPool;
		public var remover:SQLStatementPool;
		public var editar:SQLStatementPool;
		public var premio:SQLStatementPool;
		
		public var sorteos_dia:SQLStatementPool;
		public var sorteos_fecha:SQLStatementPool;
		public var sorteos_fecha_taq:SQLStatementPool;
		public var sorteo:SQLStatementPool;
		
		public var sorteos:SQLStatementPool;
		
		public var presorteos:SQLStatementPool;
		public var presorteo_nuevo:SQLStatementPool;
		public var presorteo_remover:SQLStatementPool;
		public var sorteos_fecha_lista:SQLStatementPool;
		public var sorteos_fecha_nombres:SQLStatementPool;
		
		public var publicar:SQLStatementPool;
		public var publicos:SQLStatementPool;
		public var remover_publico:SQLStatementPool;
		public var editar_publico:SQLStatementPool;
		public var sorteos_fecha_agrupado:SQLStatementPool;
		public var sorteos_fecha_lista_admin:SQLStatementPool;
		public var usuario_publico:SQLStatementPool;
		public var fecha_usuario:SQLStatementPool;
		public var lista_usuario:SQLStatementPool;
		public var remover_sorteo:SQLStatementPool;
		public var convertir_zodiaco:SQLStatementPool;
		public var pendientes:SQLStatementPool;
		
		public function SorteosSQL()
		{			
			super('sorteos.sql');
			
			sorteo = new SQLStatementPool('SELECT * FROM vt.sorteos WHERE sorteoID = :sorteoID',null,Sorteo);
			sorteos_dia = new SQLStatementPool("SELECT * FROM vt.sorteos WHERE fecha = :dia AND abierta = true ORDER BY cierra",null,Sorteo);
			sorteos_fecha = new SQLStatementPool('SELECT * FROM vt.sorteos WHERE fecha = :fecha ORDER BY cierra',null,Sorteo);
			presorteos = new SQLStatementPool("SELECT * FROM pre_sorteos ORDER BY sorteo, sorteoID",null,PreSorteo);
			
			sorteos = new SQLStatementPool('SELECT * FROM sorteos');
			fecha_usuario = new SQLStatementPool(sentencia('fecha_usuario'));
			lista_usuario = new SQLStatementPool(sentencia('lista_usuario'));
			
			sorteos_fecha_taq = new SQLStatementPool(sentencia('sorteos_fecha_taq'));
			
			sorteos_fecha_lista = new SQLStatementPool("SELECT sorteoID,sorteos.descripcion,sorteos.sorteo,numeros.numero g,numeros.descripcion gn FROM vt.sorteos LEFT JOIN numeros ON numeros.elementoID = sorteos.ganador WHERE fecha = :lista ORDER BY sorteos.sorteo, cierra");
			sorteos_fecha_lista_admin = new SQLStatementPool('SELECT sorteoID,sorteos.descripcion,sorteos.sorteo,abierta,numeros.numero g,numeros.descripcion gn, numeros.elementoID gid FROM vt.sorteos LEFT JOIN numeros ON numeros.elementoID = sorteos.ganador JOIN admins_meta ON admins_meta.valor = sorteos.sorteo WHERE fecha = :lista AND adminID = :adminID ORDER BY sorteos.sorteo, cierra');
			sorteos_fecha_nombres = new SQLStatementPool("SELECT sorteoID,descripcion,sorteo FROM vt.sorteos WHERE fecha = :nombres ORDER BY sorteos.sorteo, sorteoID");
			sorteos_fecha_agrupado = new SQLStatementPool('SELECT descripcion, sorteo FROM vt.sorteos WHERE fecha = :gfecha GROUP BY sorteo');
			
			nuevo = new SQLStatementPool("INSERT INTO vt.sorteos (descripcion,fecha,abre,cierra,abierta,sorteo) VALUES (:descripcion,:fecha,:abre,:cierra,:abierta,:sorteo)");
			remover = new SQLStatementPool("DELETE FROM vt.sorteos WHERE sorteoID = :sorteoID");
			editar = new SQLStatementPool("UPDATE vt.sorteos SET abierta = :abierta WHERE sorteoID = :sorteo");
			
			premio = new SQLStatementPool("SELECT sorteoID,descripcion,ganador,abierta,sorteo FROM vt.sorteos WHERE sorteoID = :sorteoID");
			
			presorteo_nuevo = new SQLStatementPool("INSERT INTO pre_sorteos (descripcion,inicio,final,sorteo) VALUES (:descripcion,:inicio,:final,:sorteo)");
			presorteo_remover = new SQLStatementPool('DELETE FROM pre_sorteos WHERE sorteoID = :sorteoID');
			
			publicar = new SQLStatementPool('INSERT INTO us.taquillas_sorteo (taquilla,banca,sorteo,publico) VALUES (:taquillaID,:bancaID,:sorteo,:publico)');
			publicos = new SQLStatementPool('SELECT ID,taquilla,sorteo,publico FROM us.taquillas_sorteo WHERE banca = :bancaID');
			remover_publico = new SQLStatementPool('DELETE FROM us.taquillas_sorteo WHERE ID = :id AND banca = :bancaID');
			editar_publico = new SQLStatementPool('UPDATE us.taquillas_sorteo SET publico = :publico WHERE ID = :id AND banca = :bancaID');
			
			usuario_publico = new SQLStatementPool('SELECT sorteoID, nombre FROM us.usuario_sorteos JOIN main.sorteos ON usuario_sorteos.sorteo = sorteos.sorteoID WHERE (usuarioID = :usuarioID OR usuarioID = 0)');
			
			scan(SQLStatementPool.DEFAULT_CONNECTION);
		}
	}
}