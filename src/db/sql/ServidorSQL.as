package db.sql
{
	import db.SQLStatementPool;
	
	import vos.sistema.Admin;

	public class ServidorSQL extends SQLBase
	{
		public var login:SQLStatementPool;
		public var sorteos_admin:SQLStatementPool;
		public var sorteos:SQLStatementPool;
		public var sorteos_dia:SQLStatementPool;		
		public var numeros_admin:SQLStatementPool;
		public var usuario_reg_sorteo:SQLStatementPool;
		public var usuario_del_sorteo:SQLStatementPool;
		public var usuario_sorteos:SQLStatementPool;
		public var usuario_sorteo_id:SQLStatementPool;
		
		public function ServidorSQL()
		{
			super("servidor.sql");
			login = new SQLStatementPool(sentencia("login"),SQLStatementPool.ADMIN_CONN,Admin);
			
			scan(SQLStatementPool.ADMIN_CONN);
			
			/*sorteos_admin = new SQLStatementPool(sentencia('sorteos_admin'),SQLStatementPool.ADMIN_CONN);
			sorteos = new SQLStatementPool(sentencia('sorteos'),SQLStatementPool.ADMIN_CONN);
			sorteos_dia = new SQLStatementPool(sentencia('sorteos_dia'),SQLStatementPool.ADMIN_CONN);
			
			numeros_admin = new SQLStatementPool(sentencia('numeros_admin'),SQLStatementPool.ADMIN_CONN);*/
			
		}		
		
	}
}