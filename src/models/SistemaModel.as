package models
{
	import flash.data.SQLResult;
	import flash.utils.getTimer;
	
	import by.blooddy.crypto.MD5;
	
	import db.DB;
	import db.SQLStatementPool;
	import db.sql.SistemaSQL;
	
	import helpers.Code;
	import helpers.DateFormat;
	import helpers.IPremio;
	import helpers.Premio_GranRuleta;
	import helpers.Premio_LaGranjita;
	import helpers.Premio_LotoSelva;
	import helpers.Premio_LottoActivo;
	import helpers.Premio_MiniLottico;
	import helpers.Premio_ReyAnzoategui;
	import helpers.Premio_RuletAnimal;
	import helpers.Premio_RuletaOriente;
	import helpers.Premio_RuletonColombia;
	import helpers.Premio_RuletonPeru;
	import helpers.Premio_SRQWeb;
	
	import starling.events.EventDispatcher;
	import starling.utils.execute;
	
	import vos.Elemento;
	import vos.sistema.Sorteo;
	
	public class SistemaModel extends EventDispatcher
	{
		private var s:SistemaSQL;
		
		private var sorteosClaz:Object = {
			lotto:Premio_LottoActivo,
			granruleta:Premio_GranRuleta,
			ruletaoriente:Premio_RuletaOriente,
			reyanz:Premio_ReyAnzoategui,
			granjita:Premio_LaGranjita,
			ruletanimal:Premio_RuletAnimal,
			lotoselva:Premio_LotoSelva,
			mini:Premio_MiniLottico,
			ruletonperu:Premio_RuletonPeru,
			ruletoncol:Premio_RuletonColombia
		}
		
		private var _eleHash:String;
		public function get eleHash():String { return _eleHash; }

		private var _elementos_min:Array;
		private static var _elementos:Vector.<Elemento>;
		public function get elementos():Vector.<Elemento> { return _elementos };
		
		
		public function elementos_sorteo (sorteo:int):Vector.<Elemento> {
			return _elementos.filter(function (a:Elemento,b:Boolean,c:*):Boolean {
				return a.sorteo==sorteo;
			});
		}
		public function elementos_sorteos (sorteos:Array):Vector.<Elemento> {
			return _elementos.filter(function (a:Elemento,b:Boolean,c:*):Boolean {
				return sorteos.indexOf(a.sorteo)>-1;
			});
		}
		public function elementos_sorteo_min (sorteo:int):Array {
			return _elementos_min.filter(function (a:*,b:Boolean,c:*):Boolean {
				return a.s==sorteo;
			});
		}		
		
		public function elemento (id:int):Elemento {
			for each (var el:Elemento in _elementos) {
				if (el.elementoID==id) return el;
			}
			return null;
		}
		
		public static function elemento (id:int):Elemento {
			for each (var el:Elemento in _elementos) {
				if (el.elementoID==id) return el;
			}
			return null;
		}
		
		private var _numeros:Array;
		public function get numeros():Array { return _numeros; }
		
		private var _sorteos:Vector.<Sorteo>;
		public function get sorteos():Vector.<Sorteo> { return _sorteos; }
		
		public function getPremiosClass (clase:String):IPremio {
			if (sorteosClaz.hasOwnProperty(clase)) {
				return new sorteosClaz[clase];
			} else {
				return new Premio_SRQWeb(clase); 
			}
		}
		public function getPremiosClassByID (id:int):IPremio {
			for each (var s:Sorteo in _sorteos) {
				if (s.sorteoID==id) return getPremiosClass(s.clase);	
			}
			return null;
		}
		
		public function SistemaModel() {
			super();
			s = new SistemaSQL;
			update_elementos();
			update_sorteos();
		}
		
		public function update_sorteos():void {
			s.sorteos.run(null,sorteos_act);
		}
		
		private function sorteos_act(r:SQLResult):void {
			_sorteos = r.data?Vector.<Sorteo>(r.data):null;
		}
		
		public function update_elementos():void {
			s.elementos_hash.run(null,function (r:SQLResult):void {
				var hs:String="";
				for each (var e:Object in r.data) { hs += e.hash; }
				_eleHash = MD5.hash(hs);
				
				s.elementos.run(null,elementos_act);
				s.elementos_min.run(null,min);
				s.gelementos.run(null,agrupados);
				
				function agrupados (r:SQLResult):void { _numeros = r.data; };
				function min (r:SQLResult):void { 
					_elementos_min = r.data; 
				};
			});
		}		
		public function elementos_act (r:SQLResult):void {			
			_elementos = r.data?Vector.<Elemento>(r.data):null;
			
		}		
		public function elementos_limpiar (data:Object,cb:Function):void {
			s.elementos_limpiar.run(data,cb);
		}
		public function elemento_nuevo (elemento:*,cb:Function):void {
			if (elemento is Array) {
				s.elementos_nuevo.batch(elemento,cb);
			} else {
				s.elementos_nuevo.run(elemento,function (r:SQLResult):void {
					update_elementos();
					execute(cb,r);
				});
			}
		}
		public function elemento_remover (elemento:Object,cb:Function):void {
			s.elementos_remover.run(elemento,function (r:SQLResult):void {
				update_elementos();
				execute(cb,r);
			});
		}
		
		public function elementos_taq (taq:Object,cb:Function):void {
			s.elementos_taq.run(taq,cb);
		}
		public function elementos_us (us:Object,cb:Function):void {
			s.elementos_us.run(us,cb);
		}
		public function elementos_gtag (taq:Object,cb:Function):void {
			s.elementos_gtaq.run(taq,cb);
		}
		
		public function elemento_num (num:String,sorteo:int):Elemento {
			for (var i:int = 0; i < _elementos.length; i++) {
				if (_elementos[i].sorteo==sorteo && _elementos[i].numero==num) return _elementos[i];
			}
			return null;
		}
		
		public function mant_baseDatos (fecha:String,cb:Function,error:Function):void {
			//ir a matenimiento (desconectar y rechazar todas las conexiones)
			dispatchEventWith("init-mant-db");
			//buscar ult ticketID
			var mfecha:Number = DateFormat.toDate(fecha).time;
			s.mant_buscarTicket.run({tiempo:mfecha},buscarTicket);
			var timer:int = getTimer();
			function buscarTicket (r:SQLResult):void {
				if (!r.data) {
					execute(cb,[Code.VACIO]);
					return;
				}
				var ticket:Object = {ticketID:r.data[0].ticketID};
				
				//eliminar datos
				SQLStatementPool.DEFAULT_CONNECTION.begin();
				DB.batch(Vector.<SQLStatementPool>([
					s.mant_eliminarTickets,
					s.mant_eliminarVentas,
					s.mant_eliminarAnulados,
					s.mant_eliminarPagos
				]),onComplete,onError,ticket);
				
			}
			//vacum
			
			
			function onComplete (r:Vector.<SQLResult>):void {
				SQLStatementPool.DEFAULT_CONNECTION.commit();
				execute(cb,[
					Code.OK,
					getTimer()-timer,
					r[0].rowsAffected,
					r[1].rowsAffected,
					r[2].rowsAffected,
					r[3].rowsAffected
				]);
			}
			function onError (r:*):void {
				SQLStatementPool.DEFAULT_CONNECTION.rollback();
				execute(cb,[Code.NO]);
			}
		}
	}
}