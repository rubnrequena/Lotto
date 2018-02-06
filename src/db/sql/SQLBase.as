package db.sql
{
	import flash.data.SQLConnection;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.describeType;
	
	import db.SQLStatementPool;
	
	import starling.utils.StringUtil;

	public class SQLBase
	{
		private var sql:String;
		public function SQLBase(file:String,scan:Boolean=false,con:SQLConnection=null)
		{
			var f:File = File.applicationDirectory.resolvePath("dbfiles").resolvePath(file);
			var fs:FileStream = new FileStream;
			fs.open(f,FileMode.READ);
			sql = fs.readMultiByte(fs.bytesAvailable,File.systemCharset);
			fs.close();
			if (scan) this.scan(con);
		}
		
		protected function sentencia (name:String):String {
			name = "--"+name+File.lineEnding;
			var s:int = sql.indexOf(name)+name.length;
			var ns:int = sql.indexOf("--",s) || sql.length;
			ns = ns==-1?sql.length:ns; 
			var ss:String = StringUtil.trim(sql.substring(s,ns)).split(File.lineEnding).join(" ");
			return ss;
		}
		
		protected function load (name:String,con:SQLConnection=null):void {
			this[name] = new SQLStatementPool(sentencia(name),con);
		}
		
		protected function scan(con:SQLConnection=null):void {
			var n:String;
			for each (var variable:XML in describeType(this).variable) {
				n = variable.@name;
				if (this[n]==null) {
					if (variable.@type=="db::SQLStatementPool") this[n] = new SQLStatementPool(sentencia(n),con||SQLStatementPool.DEFAULT_CONNECTION);
				}
			}
		}
	}
}