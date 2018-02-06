package db
{
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.net.Responder;
	import flash.utils.getTimer;
	
	import starling.utils.execute;
	
	
	public class SQLStatementPoolQueue extends SQLStatementPool
	{
		public function SQLStatementPoolQueue(sentencia:String, conexion:Function=null, itemClass:Class=null)
		{
			super(sentencia,conexion,itemClass);
		}
		
		override public function run(params:Object=null, onComplete:Function=null, onError:Function=null, prefetch:int=-1):void {
			time = getTimer();
			var s:SQLStatement = getStat(params);
			s.sqlConnection = _conexion();
			//trace("[SQL]",s.text,JSON.stringify(params));
			var rs:Responder = new Responder(function (r:SQLResult):void {
				Loteria.console.trac(s.text,getTimer()-time,params);
				CONFIG::debug { 
					trace("[SQL]",getTimer()-time+"ms",s.text,JSON.stringify(params)); 
				}
				if (r.data && r.data.length==prefetch) {
					s.next(prefetch,rs);
				}
				execute(onComplete,r);
				toPool(s);	
			},onError || DB.ERROR_HANDLER);
			
			s.execute(prefetch,rs);
		}
	}
}