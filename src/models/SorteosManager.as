package models
{
	import flash.data.SQLResult;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import helpers.DateFormat;
	import helpers.msToString;
	
	import starling.events.Event;
	import starling.events.EventDispatcher;
	
	import vos.Sorteo;
	import helpers.WS;
	
	public class SorteosManager extends EventDispatcher
	{		
		private var _models:ModelHUB;
		private var _fecha:String;
		
		private var _sorteos:Vector.<Sorteo>;
		public function get sorteos():Vector.<Sorteo> { return _sorteos; }
		private var _sorteoIndex:int=0;

		private var _sorteo:Sorteo;
		private var sq:Object = {};
		
		private var _timer:Timer;
		
		public var solicitudes:Object;
		
		public function getSorteo (id:int):Sorteo {
			for each (var s:Sorteo in _sorteos) if (s.sorteoID==id) return s;
			return null;
		}
		
		public function SorteosManager(models:ModelHUB) {
			super();
			solicitudes={};
			_models = models;
		}
				
		public function iniciar (fecha:String=null):void {
			Loteria.console.log("SM: Iniciando Administrador de Sorteos");
			if (_timer) _timer.stop();
			_sorteoIndex=0;
			_fecha = fecha || DateFormat.format(fecha);
			// TODO: listar solo sorteos pendientes por abrir despues de la hora actual
			_models.sorteos.sorteos({fecha:_fecha},function (r:SQLResult):void {
				if (r.data) {
					Loteria.console.log("SM:",r.data.length,"sorteos en el dia");
					var sorteosAbiertos:Array = r.data.filter(function (sorteo:Sorteo,index:int,data:*):Boolean {				
					  return (_models.ahora<sorteo.cierra && sorteo.abierta==true) || sorteo.abierta==true;
					})
					Loteria.console.log("SM:",sorteosAbiertos.length,"sorteos abiertos");
					_sorteos = Vector.<Sorteo>(sorteosAbiertos);		
					// TODO: verificar primero sorteos pendientes por abrir o cerrar
					if (_sorteos.length>0)validarSorteos(_sorteos[_sorteoIndex++]);
					else {
						var msg:String = "SM: No hay sorteos registrados"
						Loteria.console.error(msg);
						WS.enviar(WS.admin,msg)
					}
					dispatchEventWith(Event.UPDATE,false,{fecha:_fecha,sorteos:_sorteos});
				} else dispatchEventWith(Event.CANCEL);
				dispatchEventWith(Event.COMPLETE);
			});
		}
		
		private function validarSorteos(sorteo:Sorteo):void {
			Loteria.console.log("validando sorteo",sorteo.sorteoID,sorteo.descripcion,DateFormat.format(sorteo.cierra));
			if (sorteo.abierta==true && _models.ahora>sorteo.cierra) cerrarSorteo(sorteo); //sorteo abierto pero en tiempo expirado => cerrar sorteo
			else if (sorteo.abierta==true && _models.ahora<sorteo.cierra) {
				enEsperaDeCierre(sorteo);
			} //sorteo abierto pero aun en tiempo valido => esperar por cierre
			else {
				if (_sorteoIndex<_sorteos.length) validarSorteos(_sorteos[_sorteoIndex++]); // sorteo cerrado y tiempo expirado => revisar proximo sorteo
				
			}
		}
		
		private function enEsperaDeApertura(s:Sorteo):void {
			_sorteo = s;
			Loteria.console.log("proximo sorteo",s.descripcion," comienza a las ",s.abre-_models.ahora,"restan",msToString(s.abre-_models.ahora));
			_timer = new Timer(s.abre-_models.ahora,1);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE,timer_abreSorteo);
			_timer.start();
		}
		
		private function enEsperaDeCierre (s:Sorteo):void {
			_sorteo = s;
			Loteria.console.log("proximo sorteo",s.descripcion,"finaliza a las",s.cierra,"restan",msToString(s.cierra-_models.ahora));
			_timer = new Timer(s.cierra-_models.ahora,1);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE,timer_cierraSorteo);
			_timer.start();
		}		
		protected function timer_cierraSorteo(event:TimerEvent):void {
			cerrarSorteo(_sorteo);
		}		
		protected function timer_abreSorteo(event:TimerEvent):void {
			abrirSorteo(_sorteo);
		}
		
		private function cerrarSorteo(s:Sorteo):void {
			Loteria.console.log("SM cierra sorteo",s.sorteoID,s.descripcion);
			s.abierta = false;
			sq.sorteo = s.sorteoID;
			sq.abierta = 0;
			_models.sorteos.editar_abierta(sq,function():void {
				dispatchEventWith(Event.CLOSE,false,s);
				if (_sorteoIndex<_sorteos.length) validarSorteos(_sorteos[_sorteoIndex++]);
				else dispatchEventWith(Event.CANCEL);
			});
			//midas
			var delay:int = 1000*60*Loteria.setting.jarvis.tasks.midas_verificar_sorteo;
			setTimeout(function verificar_sorteo_delay ():void {
				_models.reportes.midas({sorteoID:s.sorteoID},_models.jv_midasHandler);
			},delay);
		}
		
		private function abrirSorteo(s:Sorteo):void {
			Loteria.console.log("SM abre sorteo",s.sorteoID,s.descripcion);
			s.abierta = true;
			sq.sorteo = s.sorteoID;
			sq.abierta = 1;
			_models.sorteos.editar_abierta(sq,function ():void {
				dispatchEventWith(Event.OPEN,false,s);
				enEsperaDeCierre(s);
			});
		}
		
		public function reiniciarPuntos (sorteo:Sorteo):void {
			for (var n:String in solicitudes) {
				if (n.indexOf(sorteo.sorteoID.toString())==0) solicitudes[n] = 0;
			}
		}
		public function solicitudPremio (sorteo:Sorteo,elemento:int,puntos:int):int {
			var sn:String = String(sorteo.sorteoID)+elemento;
			if (solicitudes.hasOwnProperty(sn)) solicitudes[sn] += puntos;
			else solicitudes[sn] = puntos;
			Loteria.console.log("[jv.prm]",solicitudes[sn],"puntos acumulados para el sorteo #"+sorteo.sorteoID,"elemento #"+elemento);
			return solicitudes[sn];
		}
		public function verificarSolicitud (solicitudes:Array,sorteoID:int):Boolean {
			if (solicitudes.indexOf(sorteoID)==-1) {
				solicitudes.push(sorteoID); return true;	
			} else return false;
		}
	}
}