package db.sql
{
	import db.SQLStatementPool;

	public class ClientesSQL
	{
		public var login:SQLStatementPool;
		public function ClientesSQL()
		{
			login = new SQLStatementPool('SELECT * FROM us.clientes WHERE usuario = :usuario AND clave = :clave');
		}
	}
}