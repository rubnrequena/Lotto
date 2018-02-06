package models
{
	import flash.data.SQLResult;
	
	import db.sql.SorteosSQL;
	
	import starling.events.EventDispatcher;
	import starling.utils.execute;
	
	import vos.PreSorteo;
	
	public class SorteosModel extends EventDispatcher
	{
		private var sql:SorteosSQL;
		
		private var _presorteos:Array; //examinar funcion
		public function get presorteos():Array { return _presorteos; }
				
		public function SorteosModel() {
			super();
			sql = new SorteosSQL;
			
			pre_sorteos(null,pre_sorteosFunction);
		}
		
		public function publicos (sorteo:Object,cb:Function):void {
			sql.publicos.run(sorteo,cb);
		}
		public function publicos_remover (sorteo:Object,cb:Function):void {
			sql.remover_publico.run(sorteo,cb);
		}		
		public function publicos_editar (sorteo:Object,cb:Function):void {
			sql.editar_publico.run(sorteo,cb);
		}
		public function publicar (sorteos:Array,cb:Function):void {
			sql.publicar.batch(sorteos,cb);
		}
		
		
		//SORTEOS
		public function sorteo (sorteo:Object,cb:Function):void {
			sql.sorteo.run(sorteo,function (r:SQLResult):void {
				execute(cb,r.data?r.data[0]:null);
			});
		}
		public function sorteos (busq:Object,cb:Function):void {
			if (busq) {
				if (busq.hasOwnProperty("taquilla") && busq.hasOwnProperty("banca")) {
					if (busq.hasOwnProperty("fecha")) sql.sorteos_fecha_taq.run(busq,cb);
				} else if (busq.hasOwnProperty("usuarioID")) {
					if (busq.hasOwnProperty("fecha")) sql.fecha_usuario.run(busq,cb);
					else if (busq.hasOwnProperty("lista")) sql.lista_usuario.run(busq,cb);
					else sql.usuario_publico.run(busq,cb);
				} else {
					if (busq.hasOwnProperty("fecha")) sql.sorteos_fecha.run(busq,cb);
					else if (busq.hasOwnProperty("gfecha")) sql.sorteos_fecha_agrupado.run(busq,cb);
					else if (busq.hasOwnProperty("nombres")) sql.sorteos_fecha_nombres.run(busq,cb);
					else if (busq.hasOwnProperty("lista")) {
						if (busq.hasOwnProperty("adminID")) sql.sorteos_fecha_lista_admin.run(busq,cb);
						else sql.sorteos_fecha_lista.run(busq,cb);
					}
					else if (busq.hasOwnProperty("dia")) sql.sorteos_dia.run(busq,cb);
				}
			} else sql.sorteos.run(null,cb);
		}
		
		public function editar_abierta (sorteo:Object,cb:Function):void {
			sql.editar.run(sorteo,function (r:SQLResult):void {
				execute(cb,r);
				dispatchEventWith(ModelEvent.ESTATUS_CHANGE,false,sorteo);
			});
		}
		public function premio (sorteo:Object,cb:Function):void {
			if (sorteo.hasOwnProperty("sorteoID")) sql.premio.run(sorteo,cb);
		}
		
		public function registrar (sorteos:Vector.<int>,fecha:String,cb:Function):void {
			var hora:int, minutos:int, _mer:String;
			var anio:int, mes:int, dia:int;
			var inicio:Date, final:Date;
			var presorteo:PreSorteo;
			var a:Array, _sorteos:Array = [];
			
			for each (var sorteoID:int in sorteos) {
				//sorteo
				for each (var ps:PreSorteo in _presorteos) {
					if (ps.sorteoID==sorteoID) { presorteo = ps; break; }
				}
				//fecha
				a = fecha.split("-");
				dia = a[2];
				mes = int(a[1])-1;
				anio = a[0];
				//hora inicio
				a = presorteo.inicio.split(" ");
				_mer = a[1];
				a = a[0].split(":");
				hora = int(a[0]);
				if (_mer=="PM" && hora > 12) hora += 12 else if (_mer=="AM" && hora==12) hora = 0;
				minutos = a[1];
				inicio = new Date(anio,mes,dia,hora,minutos);
				//hora inicio
				a = presorteo.final.split(" ");
				_mer = a[1];
				a = a[0].split(":");
				hora = int(a[0]);
				if (_mer=="PM" && hora < 12) hora += 12 else if (_mer=="AM" && hora==12) hora = 0;
				minutos = a[1];			
				final = new Date(anio,mes,dia,hora,minutos);
				//trace(inicio.toString(),final.toString());
				_sorteos.push({
					sorteo:presorteo.sorteo,
					descripcion:presorteo.descripcion,
					abre:inicio.time,
					cierra:final.time,
					fecha:fecha,
					abierta:true
				});	
			}
			sql.nuevo.batch(_sorteos,function (r:Vector.<SQLResult>):void {
				execute(cb,r);
				dispatchEventWith(ModelEvent.SORTEOS_REGISTRADOS,false,fecha);
			});
		}

		
		//PRE SORTEOS
		public function nuevo (sorteo:Object,cb:Function):void {
			sql.presorteo_nuevo.run(sorteo,function (r:SQLResult):void {
				execute(cb,r);
				pre_sorteos(null,pre_sorteosFunction);
			});
		}
		public function remover (sorteo:Object,cb:Function):void {
			sql.presorteo_remover.run(sorteo,function (r:SQLResult):void {
				execute(cb,r);
				pre_sorteos(null,pre_sorteosFunction);
			});
		}
		public function pre_sorteos (filtro:Object,cb:Function):void {
			sql.presorteos.run(filtro,cb);
		}
		
		protected function pre_sorteosFunction(r:SQLResult):void {
			_presorteos = r.data;
		}
	}
}