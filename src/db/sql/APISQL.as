package db.sql
{
  import db.SQLStatementPool;
  public class APISQL extends SQLBase
  {
    public var ticket:SQLStatementPool
    public var ticket_ventas:SQLStatementPool
    public var ventas_sorteo:SQLStatementPool
    
    public function APISQL() {
      super("API.sql",true)
    }
  }
}