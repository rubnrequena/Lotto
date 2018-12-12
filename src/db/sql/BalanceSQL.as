package db.sql
{
	import db.SQLStatementPool;

	public class BalanceSQL extends SQLBase
	{
		public var nuevo:SQLStatementPool;
		public var nuevo_bal:SQLStatementPool;
		public var remover_balance:SQLStatementPool;
		public var remover_pendiente:SQLStatementPool;
		public var balance_operador:SQLStatementPool;
		public var balance_operador_us:SQLStatementPool;
		public var balance_mio:SQLStatementPool;
		public var balance_usID:SQLStatementPool;
		public var balance_clientes_cm:SQLStatementPool;
		public var balance_pagos_operador:SQLStatementPool;
		public var balance_pagos_comer:SQLStatementPool;
		public var confirmar_pago:SQLStatementPool;
		public var nuevo_pago:SQLStatementPool;
		
		public function BalanceSQL()
		{
			super("balance.sql",true);
		}
	}
}