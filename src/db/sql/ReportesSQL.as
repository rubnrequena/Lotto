package db.sql
{
	import db.SQLStatementPool;

	public class ReportesSQL extends SQLBase
	{
		public var bancas:SQLStatementPool;
		public var banca:SQLStatementPool;
		public var banca_sorteo:SQLStatementPool;
		public var banca_sorteo_taquillas:SQLStatementPool;
		public var banca_sorteo_bancas:SQLStatementPool;
		public var banca_diario:SQLStatementPool;
		public var usuario_diario:SQLStatementPool;
		public var comercial_diario:SQLStatementPool;
		
		public var taquillas:SQLStatementPool;
		public var taquilla:SQLStatementPool;
		public var taq_sorteo_elem:SQLStatementPool;
		public var taq_dia_ventas:SQLStatementPool;
		public var taq_diario:SQLStatementPool;
		public var taq_general:SQLStatementPool;
		
		public var sorteos:SQLStatementPool;
		public var sorteo:SQLStatementPool;
		
		public var fecha:SQLStatementPool;
		public var fecha_banca:SQLStatementPool;
		public var nuevo:SQLStatementPool;
		
		public var rp_taqs_gen:SQLStatementPool;
		public var rp_taqs_gen_fecha:SQLStatementPool;
		public var rp_taq_gen:SQLStatementPool;
		public var rp_bancas_gen:SQLStatementPool;
		//public var rp_taqs_gen_sorteo:SQLStatementPool;
		public var rp_usuario_gen:SQLStatementPool;
		public var rp_usuario_gen_fecha:SQLStatementPool;
		public var taq_sorteo_ventas:SQLStatementPool;
		
		//public var banca_taquilla:SQLStatementPool;
		public var taq_ventas:SQLStatementPool;
		public var taq_ventas_banca:SQLStatementPool;
		public var rp_taq_gen_sorteosDia:SQLStatementPool;
		public var rp_taqs_gen_sorteo2:SQLStatementPool;
		public var rp_usuario_gen_sorteo:SQLStatementPool;
		public var rp_usuarios_gen:SQLStatementPool;
		public var rp_comer_gen:SQLStatementPool;
		public var rp_fecha_gen:SQLStatementPool;
		
		public var rp_cobro_comergen:SQLStatementPool;
		public var rp_cobro_usergen:SQLStatementPool;
		public var rp_cobro_grupogen:SQLStatementPool;
		
		public var banca_diario_taq:SQLStatementPool;
		
		public var midas_reporte_dia:SQLStatementPool;
		
		public var taq_sorteo_ventas_hoy:SQLStatementPool;
		public var taq_diario_hoy:SQLStatementPool;
		public var banca_diario_taq_hoy:SQLStatementPool;
		public var taq_ventas_hoy:SQLStatementPool;
		public var banca_diario_hoy:SQLStatementPool;
		public var midas_reporte_sorteo:SQLStatementPool;
		public var sorteo_glb:SQLStatementPool;
		public var sorteo_glb_fecha:SQLStatementPool;
		public var sorteo_glb_grupo:SQLStatementPool;
		public var comercial_general:SQLStatementPool;
		public var comercial_banca:SQLStatementPool;
		public var comercial_recogedor:SQLStatementPool;
		public var comercial_general_operadora:SQLStatementPool;
		public var comercial_fecha:SQLStatementPool

		public var backup_sorteo:SQLStatementPool;

		public var banca_general:SQLStatementPool

		
		public var gcomercial:SQLStatementPool
		public var gbanca:SQLStatementPool
		public var ggrupo:SQLStatementPool
		public var gtaquilla:SQLStatementPool
		
		public function ReportesSQL()
		{
			super("reportes.sql");
			//temp
			banca_diario_hoy = new SQLStatementPool('SELECT sorteos.descripcion desc, SUM(ch_elementos.monto) jugada, SUM(ch_elementos.monto*taquillas.comision*0.01) comision, SUM(premio) premio, SUM((case when pagos.tiempo > 0 then premio else 0 end)) pago FROM ch_ticket JOIN ch_elementos ON ch_ticket.ticketID = ch_elementos.ticketID JOIN us.taquillas ON taquillas.taquillaID = ch_ticket.taquillaID JOIN vt.sorteos ON sorteos.sorteoID = ch_elementos.sorteoID LEFT JOIN vt.pagos ON pagos.ventaID = ch_elementos.ventaID WHERE ch_ticket.anulado = 0 AND sorteos.fecha = :fecha AND ch_ticket.bancaID = :bancaID GROUP BY ch_elementos.sorteoID ORDER BY ch_elementos.sorteoID');
			banca_diario_taq_hoy = new SQLStatementPool('SELECT taquillas.nombre desc, SUM(ch_elementos.monto) jugada, SUM(ch_elementos.monto*taquillas.comision*0.01) comision, SUM(premio) premio, SUM((case when pagos.tiempo > 0 then premio else 0 end)) pago FROM ch_ticket JOIN ch_elementos ON ch_ticket.ticketID = ch_elementos.ticketID JOIN us.taquillas ON taquillas.taquillaID = ch_ticket.taquillaID LEFT JOIN vt.pagos ON pagos.ventaID = ch_elementos.ventaID WHERE ch_ticket.anulado = 0 AND ch_ticket.tiempo BETWEEN  :inicio AND :final AND ch_ticket.bancaID = :bancaID GROUP BY ch_ticket.taquillaID ORDER BY ch_ticket.taquillaID');
			taq_ventas_hoy = new SQLStatementPool('SELECT ch_ticket.ticketID id, ch_ticket.anulado a, SUM(ch_elementos.monto) m, SUM(premio) pr, SUM((case when pagos.tiempo > 0 then premio else 0 end)) pg FROM "temp"."ch_ticket" JOIN "temp"."ch_elementos" ON ch_ticket.ticketID = ch_elementos.ticketID LEFT JOIN vt.pagos ON ch_elementos.ventaID = pagos.ventaID WHERE ch_ticket.taquillaID = :taquillaID AND ch_ticket.tiempo BETWEEN :inicio AND :final GROUP BY ch_ticket.ticketID');
			taq_sorteo_ventas_hoy = new SQLStatementPool('SELECT ch_ticket.ticketID, ch_ticket.anulado, ch_ticket.tiempo, SUM(ch_elementos.monto) monto, SUM(premio) premio, SUM((case when pagos.tiempo > 0 then premio else 0 end)) pago FROM "temp"."ch_ticket" JOIN "temp"."ch_elementos" ON ch_ticket.ticketID = ch_elementos.ticketID LEFT JOIN vt.pagos ON ch_elementos.ventaID = pagos.ventaID WHERE ch_ticket.taquillaID = :taquillaID AND ch_elementos.sorteoID = :sorteoID GROUP BY ch_ticket.ticketID');
			taq_diario_hoy = new SQLStatementPool('SELECT sorteos.descripcion sorteo, SUM(ch_elementos.monto) jugado, SUM(ch_elementos.premio) premio, SUM((case when pagos.tiempo > 0 then premio else 0 end)) pago  FROM "temp".ch_ticket JOIN "temp"."ch_elementos" ON ch_ticket.ticketID = ch_elementos.ticketID JOIN vt.sorteos ON sorteos.sorteoID = ch_elementos.sorteoID LEFT JOIN vt.pagos ON pagos.ventaID = ch_elementos.ventaID WHERE ch_ticket.tiempo BETWEEN  :inicio AND :final AND ch_ticket.taquillaID = :taquillaID and ch_ticket.anulado = 0 GROUP BY ch_elementos.sorteoID ORDER BY ch_elementos.sorteoID');
			
			load('taq_diario',SQLStatementPool.REPORTE2_CONN);
			load('taq_ventas',SQLStatementPool.REPORTE2_CONN);
			
			//taq_general = new SQLStatementPool('SELECT sorteos.fecha, SUM(elementos.monto) jugado, SUM(premio) premio, SUM((case when pagos.tiempo > 0 then premio else 0 end)) pago FROM vt.ticket JOIN vt.elementos ON ticket.ticketID = elementos.ticketID JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID LEFT JOIN vt.pagos ON pagos.ventaID = elementos.ventaID WHERE ticket.anulado = 0 AND sorteos.fecha BETWEEN :inicio AND :fin AND ticket.taquillaID = :taquillaID  GROUP BY sorteos.fecha ORDER BY sorteos.fecha',SQLStatementPool.REPORTE_CONN);
			
			sorteos = new SQLStatementPool('SELECT ticket.bancaID,SUM( elementos.monto) jugado, SUM(premio) premio FROM vt.ticket JOIN vt.elementos ON ticket.ticketID = elementos.ticketID WHERE ticket.tiempo BETWEEN :inicio AND :fin GROUP BY sorteoID',SQLStatementPool.REPORTE_CONN);
			sorteo = new SQLStatementPool('SELECT ticket.bancaID,SUM( elementos.monto) jugado, SUM(premio) premio FROM vt.ticket JOIN vt.elementos ON ticket.ticketID = elementos.ticketID WHERE ticket.tiempo BETWEEN :inicio AND :fin AND sorteoID = :sorteoID GROUP BY sorteoID',SQLStatementPool.REPORTE_CONN);
			
			fecha = new SQLStatementPool('SELECT sorteos.fecha, SUM( elementos.monto) jugado, SUM(premio) premio, SUM((case when pagos.tiempo > 0 then premio else 0 end)) pago FROM vt.ticket JOIN vt.elementos ON ticket.ticketID = elementos.ticketID JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID LEFT JOIN vt.pagos ON pagos.ventaID = elementos.ventaID WHERE ticket.anulado = 0 AND sorteos.fecha BETWEEN :inicio AND :fin GROUP BY fecha ORDER BY fecha',SQLStatementPool.REPORTE_CONN);
			fecha_banca = new SQLStatementPool('SELECT sorteos.fecha, SUM( elementos.monto) jugado, SUM(premio) premio, SUM((case when pagos.tiempo > 0 then premio else 0 end)) pago FROM vt.ticket JOIN vt.elementos ON ticket.ticketID = elementos.ticketID JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID LEFT JOIN vt.pagos ON pagos.ventaID = elementos.ventaID WHERE ticket.anulado = 0 AND sorteos.fecha BETWEEN :inicio AND :fin AND ticket.bancaID = :bancaID GROUP BY fecha ORDER BY fecha',SQLStatementPool.REPORTE_CONN);
			
			load('comercial_general',SQLStatementPool.REPORTE_CONN);
			load('comercial_banca',SQLStatementPool.REPORTE_CONN);
			load('comercial_recogedor',SQLStatementPool.REPORTE_CONN);
			//rp_fecha_gen = new SQLStatementPool('SELECT bancas.usuarioID, reportes.fecha desc, SUM(jugada) jugada, SUM(premio) premio, SUM(jugada*reportes.comision*0.01) comision, ROUND(SUM(jugada*reportes.renta),2) renta FROM vt.reportes JOIN us.bancas ON bancas.bancaID = reportes.bancaID JOIN us.usuarios ON bancas.usuarioID = usuarios.usuarioID WHERE fecha BETWEEN :inicio AND :fin GROUP BY reportes.fecha ORDER BY reportes.fecha',SQLStatementPool.REPORTE_CONN);
			
			//midas
			midas_reporte_dia = new SQLStatementPool(sentencia('midas'),SQLStatementPool.ADMIN_CONN);
			midas_reporte_sorteo = new SQLStatementPool(sentencia('midas_sorteo'),SQLStatementPool.ADMIN_CONN);
			
			backup_sorteo = new SQLStatementPool(sentencia('backup_sorteo'),SQLStatementPool.DEFAULT_CONNECTION);

			scan(SQLStatementPool.REPORTE_CONN);
		}
	}
}