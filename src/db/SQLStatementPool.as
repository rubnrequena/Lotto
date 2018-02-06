package db
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.net.Responder;
	import flash.utils.getTimer;
	
	import starling.events.EventDispatcher;
	import starling.utils.execute;

	public class SQLStatementPool extends EventDispatcher
	{		
		public static var DEFAULT_CONNECTION:SQLConnection;
		public static var REPORTE_CONN:SQLConnection;
		public static var REPORTE2_CONN:SQLConnection;
		public static var JUGADAS_CONN:SQLConnection;
		public static var ADMIN_CONN:SQLConnection;
		
		public static var LOG:Function;
		
		protected var pool:Vector.<SQLStatement>;
		protected var _sentencia:String;

		public function get sentencia():String { return _sentencia; }

		protected var _conexion:SQLConnection;
		protected var _itemClass:Class;		
		
		public function get length():uint {
			return pool.length;
		}
		
		public function clear():void {
			pool.length = 0;
		}
		
		public function SQLStatementPool(sentencia:String,conexion:*=null,itemClass:Class=null) {
			pool = new Vector.<SQLStatement>;
			_sentencia = sentencia;
			_conexion = conexion || DEFAULT_CONNECTION;
			_itemClass = itemClass;
		}
		protected function create (params:Object=null):SQLStatement {
			var s:SQLStatement = new SQLStatement;
			s.text = _sentencia;
			s.itemClass = _itemClass;
			s.sqlConnection = _conexion;
			if (params) setParams(s,params);
			return s;
		}
		protected function getStat(params:Object=null):SQLStatement {
			var sql:SQLStatement;
			var l:int = pool.length;
			if (l==0) sql = create();
			else sql = pool.pop();
			
			setParams(sql,params);
			
			if (LOG) execute(LOG,_sentencia,params);
			CONFIG::debug {
				trace("[SQL]",_sentencia,JSON.stringify(params));
			}
			return sql;
		}
		protected var time:int;
		public function run (params:Object=null, onComplete:Function=null, onError:Function=null, prefetch:int=-1):void {
			time = getTimer();
			var s:SQLStatement = getStat(params);
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
		internal function setParams (sql:SQLStatement,params:Object):SQLStatement {
			sql.clearParameters();
			for (var p:String in params) sql.parameters[":"+p] = params[p]; // para prototipo, crea allocation
			return sql;
		}
		public function toPool (sql:SQLStatement):void {
			pool.push(sql);
		}
		
		public function batch (data:Array,onComplete:Function,onError:Function=null):void {						
			var len:int = data.length;
			var resultLen:int;
			var results:Vector.<SQLResult> = new Vector.<SQLResult>();
			_conexion.begin();
			for (var i:int = 0; i < len; i++) {
				run(data[i], function (result:SQLResult):void {
					results.push(result);
					if (++resultLen==len) {
						_conexion.commit();
						execute(onComplete,results);
					}
				},onError || DB.ERROR_HANDLER);
			}	
		}
		public function batch_nocommit (data:Array,onComplete:Function,onError:Function=null):void {						
			var len:int = data.length;
			var resultLen:int;
			var results:Vector.<SQLResult> = new Vector.<SQLResult>();
			//_conexion.begin();
			for (var i:int = 0; i < len; i++) {
				run(data[i], function (result:SQLResult):void {
					results.push(result);
					if (++resultLen==len) {
						//_conexion.commit();
						execute(onComplete,results);
					}
				},onError);
			}	
		}
	}
}