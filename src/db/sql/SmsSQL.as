package db.sql
{
	import db.SQLStatementPool;
	import flash.data.SQLConnection;

	public class SmsSQL
	{
		
		public var nuevo:SQLStatementPool;
		public var leer:SQLStatementPool;
		public var bandejaEntrada:SQLStatementPool;
		public var leerMsg:SQLStatementPool;
		public var sinLeer:SQLStatementPool;

		public var leido:SQLStatementPool;
		public var recibidos:SQLStatementPool;
		public var enviados:SQLStatementPool;

		private var conexion:SQLConnection;
		
		public function SmsSQL()
		{
			nuevo = new SQLStatementPool('INSERT INTO mensajes (origen,origenNombre,destino,mensaje,enviado,leido) VALUES (:origen,:origenNombre,:destino,:mensaje,:enviado,:leido)');
			//TODO LIMITAR CANTIDAD DE MENSAJES LEIDOS A DEVOLVER
			leer = new SQLStatementPool('SELECT * FROM mensajes WHERE (origen = :origen and destino = :destino AND leido = 1) || (origen = :destino and destino = :origen) ORDER BY mID DESC LIMIT :limite');
			recibidos = new SQLStatementPool('SELECT * FROM mensajes WHERE destino = :destino GROUP BY origen')
			enviados = new SQLStatementPool('SELECT origen,destino, mensaje, enviado, leido, usuarios.nombre origenNombre FROM mensajes JOIN usuarios ON usuarios.usuarioID = substr(destino,2) WHERE origen = :origen GROUP BY destino')
			//leerMsg = new SQLStatementPool('SELECT * FROM mensajes WHERE (origen = :origen and destino = :destino) || (origen = :destino and destino = :origen) AND leido = 1 LIMIT :limite');
			sinLeer = new SQLStatementPool('SELECT * FROM mensajes WHERE origen = :origen AND destino = :destino and leido = false')

			bandejaEntrada = new SQLStatementPool('SELECT *, COUNT(origen) mensajes FROM (SELECT * FROM mensajes WHERE destino = :destino AND leido = 0  ORDER BY mID DESC) GROUP BY origen');
			leido = new SQLStatementPool('UPDATE mensajes SET leido = true WHERE origen = :origen AND destino = :destino');
		}
	}
}