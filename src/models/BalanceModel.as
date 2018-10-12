package models
{
	import db.sql.BalanceSQL;
	
	import starling.events.EventDispatcher;
	
	public class BalanceModel extends EventDispatcher
	{
		private var sql:BalanceSQL;
		public function BalanceModel() {
			sql = new BalanceSQL;
			super();
		}
		
		public function nuevo (data:Object,cb:Function):void {
			sql.nuevo.run(data,cb);
		}
		
		public function operador (data:Object,cb:Function):void {
			if (data.hasOwnProperty("usID")) sql.balance_operador_us.run(data,cb);
			else sql.balance_operador.run(data,cb);
		};
		public function usID (data:Object,cb:Function):void {
			if (data.hasOwnProperty("rID")) sql.balance_usID.run(data,cb);
			else sql.balance_mio.run(data,cb);
		}
		
		public function cm_clientes (data:Object,cb:Function):void {
			sql.balance_clientes_cm.run(data,cb);
		}
	}
}