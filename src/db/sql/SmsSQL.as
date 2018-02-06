package db.sql
{
	import db.SQLStatementPool;

	public class SmsSQL
	{
		
		public var nuevo:SQLStatementPool;
		public var eBancaGrupo:SQLStatementPool;
		public var bandejaBanca:SQLStatementPool;
		
		public var smsBanca:SQLStatementPool;
		public var smsGrupo:SQLStatementPool;
		
		public var rwBancaGrupo:SQLStatementPool;
		public var eGrupoBanca:SQLStatementPool;
		
		public var bandejaGrupo:SQLStatementPool;
		
		public var leidoGrupo:SQLStatementPool;
		public var leidoBanca:SQLStatementPool;
		
		public function SmsSQL()
		{
			nuevo = new SQLStatementPool('INSERT INTO sms.mensajes (titulo,contenido,tiempo) VALUES (:titulo,:contenido,:tiempo)');
			smsBanca = new SQLStatementPool('SELECT origen, destino, bancas.bancaID, bancas.nombre oNombre, titulo, contenido, rutaID, mensajes.smsID smsID, tiempo, leido FROM sms.grupoBanca JOIN sms.mensajes ON mensajes.smsID = grupoBanca.smsID  JOIN us.bancas ON bancas.bancaID = grupoBanca.origen WHERE rutaID = :rutaID');	
			smsGrupo = new SQLStatementPool('SELECT origen, destino, bancas.bancaID, bancas.nombre oNombre, titulo, contenido, rutaID, mensajes.smsID smsID, tiempo, leido FROM sms.bancaGrupo JOIN sms.mensajes ON mensajes.smsID = bancaGrupo.smsID  JOIN us.bancas ON bancas.bancaID = bancaGrupo.origen WHERE rutaID = :rutaID');
			
			rwBancaGrupo = new SQLStatementPool('SELECT * FROM (SELECT usuarios.nombre oNombre, titulo, contenido, tiempo FROM sms.bancaGrupo JOIN sms.mensajes ON mensajes.smsID = bancaGrupo.smsID  JOIN us.usuarios ON usuarios.usuarioID = bancaGrupo.origen WHERE hilo = :hilo UNION SELECT bancas.nombre oNombre, titulo, contenido, tiempo FROM sms.grupoBanca JOIN sms.mensajes ON mensajes.smsID = grupoBanca.smsID  JOIN us.bancas ON bancas.bancaID = grupoBanca.origen WHERE hilo = :hilo) ORDER BY tiempo');
			
			eBancaGrupo = new SQLStatementPool('INSERT INTO sms.bancaGrupo (origen,destino,smsID,hilo) VALUES (:origen,:destino,:smsID,:hilo)');
			bandejaBanca = new SQLStatementPool('SELECT rutaID, origen, bancas.nombre oNombre, mensajes.smsID, titulo, leido, tiempo FROM sms.grupoBanca JOIN sms.mensajes ON mensajes.smsID = grupoBanca.smsID JOIN us.bancas ON bancas.bancaID = grupoBanca.origen WHERE destino = :bancaID AND hilo = 0');
			
			eGrupoBanca = new SQLStatementPool('INSERT INTO sms.grupoBanca (origen,destino,smsID,hilo) VALUES (:origen,:destino,:smsID,:hilo)');
			bandejaGrupo = new SQLStatementPool('SELECT rutaID, origen, bancas.nombre oNombre, mensajes.smsID, titulo, leido, tiempo FROM sms.bancaGrupo JOIN sms.mensajes ON mensajes.smsID = bancaGrupo.smsID JOIN us.bancas ON bancas.bancaID = bancaGrupo.origen WHERE destino = :grupoID AND hilo = 0 ORDER BY bancaGrupo.leido ASC, mensajes.tiempo DESC');
			
			leidoGrupo = new SQLStatementPool('UPDATE sms.bancaGrupo SET leido = 1 WHERE smsID = :smsID AND rutaID = :rutaGrupo');
			leidoBanca = new SQLStatementPool('UPDATE sms.grupoBanca SET leido = 1 WHERE smsID = :smsID AND rutaID = :rutaBanca');
		
		}
	}
}