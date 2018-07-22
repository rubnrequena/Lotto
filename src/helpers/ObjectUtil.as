package helpers
{
	public class ObjectUtil
	{
		private static var p:String;
		static public function copy (o:Object):Object {
			var o2:Object = {};
			for (p in o) o2[p] = o[p];
			return o2;
		}
		
		static public function clear (o:Object):Object {
			o = o || {};
			for (p in o) delete o[p];
			return o;
		}
		
		private static var len:int;
		static public function find (val:*,field:String,source:*):* {
			len = source.length;
			for (var i:int = 0; i < len; i++) {
				if (source[i][field]==val) return source[i];
			}
			return null;
		}
		
		private static var numbers:String = "0123456789";
		static public function extractInt (n:String):String {
			var nn:Array = n.split("").filter(function _extractInt (v:String,i:int,a:Array):Boolean {
				return numbers.indexOf(v)>-1;
			});
			return nn.join("");
		}
		
		static public function trailZero (n:String):String {
			if (int(n)==0) return n.toString();
			return int(n)<10?"0"+int(n):n.toString();
		}
		static public function extractAndTrail (n:String):String {
			return trailZero(extractInt(n));
		}
		static public function arrayObject (data:Array):Object {
			var m:Object = {};
			for each (var row:Object in data) m[row.campo] = row.valor;
			return m;
		}
	}
}