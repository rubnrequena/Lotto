package db.sql
{
	import db.SQLStatementPool;
	
	public class VentasSQL extends SQLBase
	{
		public var venta:SQLStatementPool;
		public var venta_elemento:SQLStatementPool;
		
		public var ventas_elemento_sorteos:SQLStatementPool;
		public var ventas_elemento_sorteos_taquilla:SQLStatementPool;
		public var ventas_elemento_sorteos_banca:SQLStatementPool;
		public var ventas_elemento_sorteos_usuario:SQLStatementPool;
		
		public var anular:SQLStatementPool; //HELPER_CONNECTION
		public var anulado:SQLStatementPool;
		public var anular_elementos:SQLStatementPool;
		public var anular_elemento_cache:SQLStatementPool;
		public var anular_ticket_cache:SQLStatementPool;
		
		public var ticket:SQLStatementPool;
		public var ticket_codigo:SQLStatementPool;
		public var ticket_animales:SQLStatementPool;
		public var ticket_premios:SQLStatementPool;
		
		public var tickets:SQLStatementPool;
		
		public var premiar:SQLStatementPool;
		public var premiar_ventas:SQLStatementPool;
		public var premiar_reinicio:SQLStatementPool;		
		
		public var pagar:SQLStatementPool; //HELPER_CONNECTION
		public var tickets_ultimo:SQLStatementPool;
		public var ventas_elementos_ticket:SQLStatementPool;
		public var tickets_premiados:SQLStatementPool;
		public var reporte_nuevo:SQLStatementPool; //HELPER_CONNECTION
		
		public var jugadas_banca_taq:SQLStatementPool;
		public var jugadas_banca_num:SQLStatementPool;
		
		public var jugadas_usuario_bnc:SQLStatementPool;
		public var jugadas_usuario_num:SQLStatementPool;

		public var jugadas_comercial_bnc:SQLStatementPool;
		public var jugadas_comercial_num:SQLStatementPool;
		
		public var jugadas_srv_num:SQLStatementPool;
		
		public var jugadas_global_num:SQLStatementPool;
		public var jugadas_banca_sorteo:SQLStatementPool;
		
		public var ventas_elementos_repetir:SQLStatementPool;
	
		public var relacion_pago:SQLStatementPool;
		public var jugadas_banca:SQLStatementPool;
		public var remover_taq:SQLStatementPool;
		public var jugadas_srv_banca:SQLStatementPool;
		
		public var ventas_elementos_ticketID:SQLStatementPool;
		public var ventas_elementos_ventaID:SQLStatementPool;
		
		public var premiar_reinicio_temp:SQLStatementPool;
		public var premiar_ventas_temp:SQLStatementPool;
		public var tickets_premiados_ram:SQLStatementPool;
		public var reporte_gen_upd_pago:SQLStatementPool;
		
		public var premiar_ventas_v2:SQLStatementPool; //HELPER_CONNECTION
		public var premiar_bancas:SQLStatementPool;
		public var premiar_bancas_temp:SQLStatementPool;
		public var premiar_ventas_v2_temp:SQLStatementPool;
		public var premiar_ventas_v2_all:SQLStatementPool; //HELPER_CONNECTION
		public var premiar_ventas_v2_alltemp:SQLStatementPool;
						
		public function VentasSQL()
		{
			super("ventas.sql",false);
			/*anular2 = new SQLStatementPool(sentencia('anular'),SQLStatementPool.HELPER_CONNECTION);
			pagar2 = new SQLStatementPool(sentencia('pagar'),SQLStatementPool.HELPER_CONNECTION);
			
			premiar_ventas_v2 = new SQLStatementPool(sentencia('premiar_ventas_v2'),SQLStatementPool.HELPER_CONNECTION);
			premiar_ventas_v2_all = new SQLStatementPool(sentencia('premiar_ventas_v2_all'),SQLStatementPool.HELPER_CONNECTION);
			reporte_nuevo = new SQLStatementPool(sentencia('reporte_nuevo'),SQLStatementPool.HELPER_CONNECTION);*/
			
			load("jugadas_banca_taq",SQLStatementPool.JUGADAS_CONN);
			load("jugadas_banca_num",SQLStatementPool.JUGADAS_CONN);
			
			load("jugadas_usuario_bnc",SQLStatementPool.JUGADAS_CONN);
			load("jugadas_usuario_num",SQLStatementPool.JUGADAS_CONN);
			
			load("ventas_elementos_repetir",SQLStatementPool.JUGADAS_CONN);
			
			load("jugadas_banca",SQLStatementPool.JUGADAS_CONN);
			load("jugadas_srv_banca",SQLStatementPool.JUGADAS_CONN);
			
			load("ventas_elementos_ventaID",SQLStatementPool.JUGADAS_CONN);
			
			load("ventas_elementos_ticket",SQLStatementPool.JUGADAS_CONN);
			load("tickets_premiados",SQLStatementPool.JUGADAS_CONN);
			
			scan();
		}
	}
}