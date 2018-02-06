package vos
{
	public class VOImport
	{
		public function VOImport()
		{
			
		}
		
		public function importar (v:Object):void {
			for (var p:String in v) this[p] = v[p];
		}
	}
}