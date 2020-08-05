package db.sql
{
	import db.SQLStatementPool;
	
	import vos.Tope;

	public class TopesSQL extends SQLBase
	{
		public var topes:SQLStatementPool;
		public var topes_banca:SQLStatementPool;
		public var topes_usuario:SQLStatementPool;
		public var topes_comercial:SQLStatementPool; //TODO falta sql
		public var topes_taquilla:SQLStatementPool;
		public var topes_all:SQLStatementPool;
		public var nuevo:SQLStatementPool;
		public var remover:SQLStatementPool;
		
		public function TopesSQL()
		{
			super('topes.sql');
			topes_all = new SQLStatementPool('SELECT * FROM us.topes',null,Tope);
			topes = new SQLStatementPool('SELECT * FROM us.topes WHERE (bancaID = :bancaID OR bancaID = 0) AND (taquillaID = :taquillaID OR taquillaID = 0) AND (usuarioID = :usuarioID OR usuarioID = 0) ORDER BY elemento DESC, sorteoID DESC, sorteo DESC, taquillaID DESC, bancaID DESC, topeID DESC, compartido ASC',null,Tope);
			
			topes_taquilla = new SQLStatementPool('SELECT * FROM us.topes WHERE taquillaID = :taquillaID',null,Tope);
			
			nuevo = new SQLStatementPool('INSERT INTO us.topes (bancaID,sorteoID,taquillaID,elemento,monto,compartido,sorteo,usuarioID,creado) VALUES (:bancaID,:sorteoID,:taquillaID,:elemento,:monto,:compartido,:sorteo,:usuarioID,:creado)');
			remover = new SQLStatementPool("DELETE FROM us.topes WHERE topeID = :topeID",null);

			scan();
		}
	}
}