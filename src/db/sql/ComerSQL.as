package db.sql
{
	import db.SQLStatementPool;
	
	import vos.Usuario;

	public class ComerSQL extends SQLBase
	{
		public var login:SQLStatementPool;
		public var comercializadoras:SQLStatementPool;
		public var usuarios:SQLStatementPool;
		public var link:SQLStatementPool;
		
		public function ComerSQL()
		{
			super("comercializadora.sql");
			
			login = new SQLStatementPool(sentencia("login"),null,Usuario);
			
			usuarios = new SQLStatementPool(sentencia("usuarios"),null,Usuario);
			
			scan();
		}
	}
}