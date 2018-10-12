package db.sql
{
	import db.SQLStatementPool;

	public class BalanceSQL extends SQLBase
	{
		public var nuevo:SQLStatementPool;
		public var nuevo_bal:SQLStatementPool;
		public var balance_operador:SQLStatementPool;
		public var balance_operador_us:SQLStatementPool;
		public var balance_mio:SQLStatementPool;
		public var balance_usID:SQLStatementPool;
		public var balance_clientes_cm:SQLStatementPool;
		
		public function BalanceSQL()
		{
			super("balance.sql",true);
		}
	}
}