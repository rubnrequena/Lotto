package db.sql
{
	import db.SQLStatementPool;
	
	import vos.Usuario;

	public class ComerSQL extends SQLBase
	{
		public var login:SQLStatementPool;
		public var comercializadoras:SQLStatementPool;
		public var usuarios:SQLStatementPool;
		public var hijos:SQLStatementPool;
		public var link:SQLStatementPool;
		public var tope_nuevo:SQLStatementPool;
		public var tope_delete:SQLStatementPool;
		
		public function ComerSQL()
		{
			super("comercializadora.sql");
			
			login = new SQLStatementPool(sentencia("login"),null,Usuario);
			
			usuarios = new SQLStatementPool(sentencia("usuarios"),null,Usuario);
			
			scan();
		}
	}
}