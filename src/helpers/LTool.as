package helpers
{
	import flash.data.SQLResult;
	import starling.utils.execute;

	public class LTool
	{
		private static var i:int, l:int;
		
		public static function findBy (campo:String,valor:*,contexto:*):* {
			l = contexto.length;
			for (i=0;i<l;i++) {
				if (contexto[i][campo]==valor) return contexto[i];
			}
			return null;
		}
		public static function findIndex (campo:String,valor:*,contexto:*):* {
			l = contexto.length;
			for (i=0;i<l;i++) {
				if (contexto[i][campo]==valor) return i;
			}
			return -1;
		}
		public static function exploreBy (campo:String,valor:*,contexto:*):Array {
			l = contexto.length;
			var data:Array= [];
			for (i=0;i<l;i++) {
				if (contexto[i][campo]==valor) data.push(contexto[i]);
			}
			return data;
		}
		public static function exist (campo:String,valor:*,contexto:*):Boolean {
			l = contexto.length;
			for (i=0;i<l;i++) {
				if (contexto[i][campo]==valor) return true;
			}
			return false;
		}
		public static function sqlResult (res:SQLResult,cb:Function):void {
			execute(cb,res.data?res.data:[])
		}
	}
}