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
		public var sorteo_dia:SQLStatementPool;
		public var sorteos_num_ultimos:SQLStatementPool;
		public var sorteos_num_historia:SQLStatementPool;
		public var numeros_admin:SQLStatementPool;
		public var usuario_reg_sorteo:SQLStatementPool;
		public var usuario_del_sorteo:SQLStatementPool;
		public var usuario_sorteos:SQLStatementPool;
		public var usuario_sorteo_id:SQLStatementPool;
		public var monitor_vnt_ticket_num:SQLStatementPool;
		public var numeros_admin_sorteo:SQLStatementPool;
		
		public function ServidorSQL()
		{
			super("servidor.sql");
			login = new SQLStatementPool(sentencia("login"),SQLStatementPool.ADMIN_CONN,Admin);			
			scan(SQLStatementPool.ADMIN_CONN);			
		}		
		
	}
}