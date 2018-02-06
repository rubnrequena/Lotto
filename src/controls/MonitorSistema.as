package controls
{
	import starling.events.EventDispatcher;
	
	import vos.sistema.VOMonitor;
	
	public class MonitorSistema extends EventDispatcher
	{
		public static var monitor:VOMonitor;
		
		public function MonitorSistema()
		{
			super();
		}
		
		public static function iniciar():void
		{
			monitor = new VOMonitor;
		}
		
		public static function reiniciar():void {
			
		}
		
		public static function get rendimiento ():Object {
			return {
				max:monitor.ms_max,
				last:monitor.ms_last,
				desc:monitor.ms_last_desc
			}
		}
		
		public static function get acciones_contar ():Object {
			return monitor.accion_contador;
		}
	}
}