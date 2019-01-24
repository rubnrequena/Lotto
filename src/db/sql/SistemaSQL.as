package db.sql
{
	import db.SQLStatementPool;
	
	import vos.Elemento;
	import vos.sistema.Sorteo;

	public class SistemaSQL
	{
		public var elementos:SQLStatementPool;
		public var elementos_hash:SQLStatementPool;
		public var elementos_nuevo:SQLStatementPool;
		public var elementos_remover:SQLStatementPool;
		public var sorteos:SQLStatementPool;
		
		public var gelementos:SQLStatementPool;
		public var elementos_taq:SQLStatementPool;
		public var elementos_us:SQLStatementPool;
		public var mant_buscarTicket:SQLStatementPool;
		public var mant_eliminarTickets:SQLStatementPool;
		public var mant_eliminarVentas:SQLStatementPool;
		public var mant_eliminarPagos:SQLStatementPool;
		public var mant_eliminarAnulados:SQLStatementPool;
		public var elementos_limpiar:SQLStatementPool;
		public var elementos_sorteo:SQLStatementPool;
		public var elementos_gtaq:SQLStatementPool;
		public var elementos_min:SQLStatementPool;
		
		public function SistemaSQL()
		{
			elementos_hash = new SQLStatementPool('SELECT descripcion||sorteo||numero||adicional hash FROM numeros');
			elementos = new SQLStatementPool('SELECT * FROM numeros ORDER BY CAST(numero AS INTEGER)',null,Elemento);
			elementos_min = new SQLStatementPool('SELECT descripcion d, sorteo s, numero n, elementoID id FROM numeros ORDER BY CAST(numero AS INTEGER)');
			elementos_nuevo = new SQLStatementPool('INSERT INTO numeros (numero,descripcion,sorteo,adicional) VALUES (:numero,:descripcion,:sorteo,:adicional)');
			elementos_remover = new SQLStatementPool('DELETE FROM numeros WHERE elementoID = :elemento');
			elementos_limpiar = new SQLStatementPool('DELETE FROM numeros WHERE sorteo = :sorteo');
			elementos_sorteo = new SQLStatementPool('SELECT * FROM numeros WHERE sorteo = :sorteo');
			
			sorteos = new SQLStatementPool('SELECT * FROM sorteos',null,Sorteo);			
			
			gelementos = new SQLStatementPool('SELECT numero n FROM numeros GROUP BY n');
			
			elementos_taq = new SQLStatementPool('SELECT elementoID id, descripcion d, numeros.numero n, numeros.sorteo s FROM numeros JOIN (SELECT sorteos.sorteo FROM vt.sorteos JOIN (SELECT * FROM (SELECT * FROM us.taquillas_sorteo WHERE (taquillas_sorteo.banca = :banca OR taquillas_sorteo.banca = 0) AND (taquillas_sorteo.taquilla = :taquilla OR taquillas_sorteo.taquilla = 0) ORDER BY taquilla ASC, banca ASC, ID ASC) GROUP BY sorteo ) as taquillas ON taquillas.sorteo = sorteos.sorteo WHERE sorteos.fecha = :fecha AND taquillas.publico = 1 GROUP BY sorteos.sorteo) as elm ON elm.sorteo = numeros.sorteo ORDER BY s,n');
			elementos_us = new SQLStatementPool('SELECT elementoID id, descripcion d, numeros.numero n, numeros.sorteo s FROM numeros JOIN us.usuario_sorteos ON usuario_sorteos.sorteo = numeros.sorteo WHERE (usuarioID = :usuarioID or usuarioID = 0) ORDER BY s,n');
			elementos_gtaq = new SQLStatementPool('SELECT numeros.sorteo s FROM numeros JOIN (SELECT sorteos.sorteo FROM vt.sorteos JOIN (SELECT * FROM (SELECT * FROM us.taquillas_sorteo WHERE (taquillas_sorteo.banca = :banca OR taquillas_sorteo.banca = 0) AND (taquillas_sorteo.taquilla = :taquilla OR taquillas_sorteo.taquilla = 0) ORDER BY taquilla ASC, banca ASC, ID ASC) GROUP BY sorteo ) as taquillas ON taquillas.sorteo = sorteos.sorteo WHERE sorteos.fecha = :fecha AND taquillas.publico = 1 GROUP BY sorteos.sorteo) as elm ON elm.sorteo = numeros.sorteo GROUP BY numeros.sorteo ORDER BY s');
			
			mant_buscarTicket = new SQLStatementPool('SELECT ticketID FROM vt.ticket WHERE tiempo < :tiempo ORDER BY ticketID DESC LIMIT 1');
			mant_eliminarTickets = new SQLStatementPool('DELETE FROM ticket WHERE ticketID <= :ticketID');
			mant_eliminarVentas = new SQLStatementPool('DELETE FROM elementos WHERE ticketID <= :ticketID');
			mant_eliminarAnulados = new SQLStatementPool('DELETE FROM anulados WHERE ticketID <= :ticketID');
			mant_eliminarPagos = new SQLStatementPool('DELETE FROM pagos WHERE ticketID <= :ticketID');
		}
	}
}