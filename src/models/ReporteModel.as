package models
{
	import flash.data.SQLResult;
	
	import db.sql.ReportesSQL;
	
	import helpers.DateFormat;
	
	import starling.events.EventDispatcher;
	import starling.utils.execute;
	
	public class ReporteModel extends EventDispatcher
	{
		private var sql:ReportesSQL;
		private var hoy:String;
		private var cache:Object;
		
		
		public function ReporteModel() {
			super();
			sql = new ReportesSQL;
			hoy = DateFormat.format(null);
		}
		
		public function nuevo (sorteo:Object,cb:Function):void {
			sql.nuevo.run(sorteo,cb);
		}
		
		public function general (s:Object,cb:Function):void {
			if (s.hasOwnProperty("bancaID")) sql.rp_taqs_gen.run(s,cb);
			else if (s.hasOwnProperty("taquillaID")) sql.rp_taq_gen.run(s,cb);
			else if (s.hasOwnProperty("usuarioID")) sql.rp_usuario_gen.run(s,cb);
			else sql.rp_bancas_gen.run(s,cb);
		}
		
		public function comercial (s:Object,cb:Function):void {
			if (s.hasOwnProperty("comercial")) sql.comercial_general.run(s,cb);
			else if (s.hasOwnProperty("usuarioID")) sql.comercial_banca.run(s,cb);
			else if (s.hasOwnProperty("bancaID")) sql.comercial_recogedor.run(s,cb);
		}
		public function operadora (s:Object,cb:Function):void {
			if (s.hasOwnProperty("comercial")) sql.comercial_general_operadora.run(s,cb);
		}
		public function usuarios (s:Object,cb:Function):void {
      if (s.hasOwnProperty("usuarioID")) sql.banca_general.run(s,cb)
			else sql.rp_usuarios_gen.run(s,cb);
		}
		public function comerciales (s:Object,cb:Function):void {
			sql.rp_comer_gen.run(s,cb);
		}
		
		public function cbr_comerciales (s:Object,cb:Function):void {
			sql.rp_cobro_comergen.run(s,cb);
		}
		public function cbr_usuarios (s:Object,cb:Function):void {
			sql.rp_cobro_usergen.run(s,cb);
		}
		public function cbr_grupos (s:Object,cb:Function):void {
			sql.rp_cobro_grupogen.run(s,cb);
		}
		
		public function general_fecha (s:Object,cb:Function):void {
			sql.rp_fecha_gen.run(s,cb);
		}
				
		public function fecha (s:Object,cb:Function):void {
			if (s.hasOwnProperty("bancaID")) sql.rp_taqs_gen_fecha.run(s,cb);
			else if (s.hasOwnProperty("usuarioID")) sql.rp_usuario_gen_fecha.run(s,cb);
			else if (s.hasOwnProperty("comercial")) sql.comercial_fecha.run(s,cb);
			else sql.fecha.run(s,cb);
		}
		
		public function banca (banca:Object,cb:Function):void {
			if (banca.hasOwnProperty("sorteo")) {
				if (banca.hasOwnProperty("bancaID")) { 
					sql.banca_sorteo_taquillas.run(banca,cb);
				}else if (banca.hasOwnProperty("usuarioID")) {
					sql.banca_sorteo_bancas.run(banca,cb)
				}
			}
			else sql.bancas.run(banca,cb);
		}
		
		public function taquilla (s:Object,cb:Function):void {
			if (s.hasOwnProperty("taquillaID")) {				
				if (s.hasOwnProperty("inicio") && s.hasOwnProperty("final")) sql.taq_dia_ventas.run(s,cb);
				if (s.hasOwnProperty("inicio") && s.hasOwnProperty("fin")) {
					if (s.inicio==s.fin) sql.rp_taq_gen_sorteosDia.run(s,cb);
					else sql.rp_taq_gen.run(s,cb);
				}
				else if (s.hasOwnProperty("sorteoID")) {
					sql.taq_sorteo_ventas.run(s,cb);
				}
				else if (s.hasOwnProperty("bancaID")) throw new Error("404");
			} else sql.taquillas.run(s,cb);
		}
		public function diario (s:Object,cb:Function,agrupar:int=0):void {
			if (s.hasOwnProperty("bancaID")) {
				if (agrupar==0) {
					s.inicio = DateFormat.toDate(s.fecha).time;
					s.final = DateFormat.toDate(s.fecha,86400000).time;
					delete s.fecha;
					sql.banca_diario.run(s,cb);	// optimizar 
				}
				else if (agrupar==1) {
					s.inicio = DateFormat.toDate(s.fecha).time;
					s.final = DateFormat.toDate(s.fecha,86400000).time;
					delete s.fecha;
					sql.banca_diario_taq.run(s,cb);
				}
			}
			else if (s.hasOwnProperty("usuarioID")) {
				s.inicio = DateFormat.toDate(s.fecha).time;
				s.final = DateFormat.toDate(s.fecha,86400000).time;
				delete s.fecha;
				sql.usuario_diario.run(s,cb);
			}
			else if (s.hasOwnProperty("comercialID")) {
				s.inicio = DateFormat.toDate(s.fecha).time;
				s.final = DateFormat.toDate(s.fecha,86400000).time;
				delete s.fecha;
				sql.comercial_diario.run(s,cb);
			}
			else if (s.hasOwnProperty("taquillaID")) {
				s.inicio = DateFormat.toDate(s.fecha).time;
				s.final = DateFormat.toDate(s.fecha,86400000).time;
				delete s.fecha;
				sql.taq_diario.run(s,cb);
			}
			//general
		}
		public function ventas (s:Object,cb:Function):void {
			if (s.hasOwnProperty("taquillaID")) {
				/*cache = DateFormat.toDate(hoy).time; 
				if (cache==s.inicio) {
					sql.taq_ventas_hoy.run(s,cb);
				}
				else*/ sql.taq_ventas.run(s,cb);
			}
		}
		public function ventas_banca (s:Object,cb:Function):void {
			if (s.hasOwnProperty("taquillaID")) {
				sql.taq_ventas_banca.run(s,cb);
			}
		}
		public function sorteo (s:Object,cb:Function):void {
			if (s && s.hasOwnProperty("sorteoID")) {
				if (s.hasOwnProperty("taquillaID")) sql.taq_sorteo_elem.run(s,cb);
				else if (s.hasOwnProperty("bancaID")) sql.banca_sorteo.run(s,cb);
				else sql.sorteo.run(s,cb);
			} else sql.sorteos.run(s,cb);
		} 
		
		public function sorteo_global (s:Object,cb:Function):void {
			sql.sorteo_glb.run(s,cb);
		}
		public function sorteo_global_grupo (s:Object,cb:Function):void {
			sql.sorteo_glb_grupo.run(s,cb);
		}
		public function sorteo_global_fecha (s:Object,cb:Function):void {
			sql.sorteo_glb_fecha.run(s,cb);
		} 
		
		public function general_sorteo(s:Object,cb:Function):void {
			if (s.hasOwnProperty("bancaID")) sql.rp_taqs_gen_sorteo2.run(s,cb);
			else if (s.hasOwnProperty("usuarioID")) sql.rp_usuario_gen_sorteo.run(s,cb);
		}
		
		public function midas (s:Object,cb:Function):void {
			if (s.hasOwnProperty("fecha")) sql.midas_reporte_dia.run(s,cb);
			if (s.hasOwnProperty("sorteoID")) sql.midas_reporte_sorteo.run(s,cb);
		}

		public function respaldoBackup (sorteoID:int,cb:Function):void {
			sql.backup_sorteo.run({sorteoID:sorteoID},cb)
		}

		public function usuario (s:Object,cb:Function):void {
			if (s.taquilla) sql.gtaquilla.run({
				inicio:s.inicio,
				fin:s.fin,
				comercial:s.comercial,
				taquilla:s.taquilla
			},cb)
			else if (s.grupo) sql.ggrupo.run({
				inicio:s.inicio,
				fin:s.fin,
				comercial:s.comercial,
				grupo:s.grupo
			},cb)
			else if (s.banca) sql.gbanca.run(s,cb)
			else if (s.comercial) sql.gcomercial.run(s,cb)
		}
	}
}