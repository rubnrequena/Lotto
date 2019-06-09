package db
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	import flash.events.EventDispatcher;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	import flash.net.Responder;
	
	import starling.utils.execute;

	public class DB extends EventDispatcher
	{
		public static var DEBUG:Boolean = true;
		
		protected var _conexion:SQLConnection;

		public function get conexion():SQLConnection { return _conexion; }

		protected var archivoDB:File;
		
		public function get conected():Boolean { return conexion.connected; }
		
		public function DB(archivo:File) {
			_conexion = new SQLConnection;	
			conexion.addEventListener(SQLEvent.OPEN,openHandler);	
			
			archivoDB = archivo;
		}
		
		protected function openHandler(event:SQLEvent):void {
			debug("[SQL] Conexion establecida con:",archivoDB.nativePath);
		}
		public function crearPool (texto:String,itemClass:Class=null):SQLStatementPool {
			var s:SQLStatementPool = new SQLStatementPool(texto,conexion,itemClass);
			return s;
		}
		public function conectar(async:Boolean=true,responder:Responder=null):void {
			if (archivoDB.exists) {
				if (async) conexion.openAsync(archivoDB,"create",responder);
				else conexion.open(archivoDB);
			} else {
				copiarEstructura();
				conectar(async,responder);
				//dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,"Archivo no existe: '"+archivoDB.nativePath+"'",1));
			}
		}
		
		public function sql (sql:String,itemClass:Class=null):SQLResult {
			var s:SQLStatement = new SQLStatement;
			s.text = sql;
			s.itemClass = itemClass;
			s.sqlConnection = conexion;
			s.execute();
			return s.getResult(); 
		}
		public function sqlAsync (sql:String,callback:Responder=null,itemClass:Class=null):void {
			var s:SQLStatement = new SQLStatement;
			s.text = sql;
			s.itemClass = itemClass;
			s.sqlConnection = conexion;
			s.execute(-1,callback);
		}
		
		public static function batch (sqls:Vector.<SQLStatementPool>,onComplete:Function,onError:Function=null,data:*=null):void {
			var len:int = sqls.length;
			var resultLen:int;
			var results:Vector.<SQLResult> = new Vector.<SQLResult>();
			for (var i:int = 0; i < len; i++) {
				sqls[i].run(data is Array?data[i]:data,function (result:SQLResult):void {
					results.push(result);
					if (++resultLen==len) execute(onComplete,results);
				},onError||DB.ERROR_HANDLER);
			}			
		}
		
		protected function copiarEstructura():void {
			var estructura:File = File.applicationDirectory.resolvePath("archivos").resolvePath("db").resolvePath(archivoDB.name);
			if (estructura.exists)
				estructura.copyTo(archivoDB);
			else
				throw new Error("Estructura para base de datos '"+estructura.name+"' no existe");
		}
		
		protected function debug (...args):void {
			if (DEBUG) trace(args.join(" "));
		}
		
		public static var ERROR_HANDLER:Function = function (e:SQLError):void {			
			Loteria.console.log(e.details,e.getStackTrace());
		}
	}
}