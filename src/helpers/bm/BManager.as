package helpers.bm
{
	import models.ModelHUB;
	
	import starling.events.EventDispatcher;
	
	public class BManager extends EventDispatcher
	{
		private var i:int, len:int;
		private var _grupo:Vector.<EGrupo>;
		private var _model:ModelHUB;
		public function BManager(model:ModelHUB) {
			super();
			
			_model = model;
			_grupo = new Vector.<EGrupo>;
		}
				
		public function validar (banca:int,ventas:Array):void {
			var b:EGrupo = findGrupo(banca);
			
		}
		
		public function registrar (banca:int,ventas:Array):EGrupo {
			var bnc:EGrupo = new EGrupo;
			bnc.id = banca;
			for each (var v:Object in ventas) {
				bnc.registrar(v);
			}
			_grupo.push(bnc);
			return bnc;
		}		
		
		public function findSorteo (sorteo:int,sorteos:Vector.<ESorteo>):ESorteo {
			len = sorteos.length;
			for (i = 0; i < len; i++) {
				if (sorteos[i].sorteo==sorteo) return sorteos[i];
			}
			return null;
		}
		
		public function findGrupo (id:int):EGrupo {
			len = _grupo.length;
			for (i = 0; i < len; i++) {
				if (_grupo[i].id==id) return _grupo[i];
			}
			return null;
		}
		
		public function clear (id:int):void {
			len = _grupo.length;
			for (i = 0; i < len; i++) {
				if (_grupo[i].id==id) {
					_grupo.removeAt(i);
					return;
				}
			}
		}
	}
}