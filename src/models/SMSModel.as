package models
{
	import flash.data.SQLResult;
	
	import db.sql.SmsSQL;
	
	import helpers.ObjectUtil;
	
	import starling.events.EventDispatcher;

	public class SMSModel extends EventDispatcher
	{
		private var sql:SmsSQL;
		private var cache:Object;
		
		public function SMSModel()
		{
			sql = new SmsSQL;
			cache = {};
		}
		
		public function envBancaGrupo (data:Object,cb:Function=null):void {
			ObjectUtil.clear(cache);
			cache.titulo = data.titulo;
			cache.contenido = data.contenido;
			cache.tiempo = data.tiempo;
			sql.nuevo.run(cache,function (r:SQLResult):void {
				var len:int = data.destino.length;
				var rutas:Array = [len];
				for (var i:int = 0; i < len; i++) {
					rutas[i] = {
						smsID:r.lastInsertRowID,
						origen:data.origen,
						destino:data.destino[i],
						hilo:data.hilo
					}
				}
				sql.eBancaGrupo.batch_nocommit(rutas,cb);
			});
		}
		public function envGrupoBanca (data:Object,cb:Function=null):void {
			ObjectUtil.clear(cache);
			cache.titulo = data.titulo;
			cache.contenido = data.contenido;
			cache.tiempo = data.tiempo;
			sql.nuevo.run(cache,function (r:SQLResult):void {
				var len:int = data.destino.length;
				var rutas:Array = [len];
				for (var i:int = 0; i < len; i++) {
					rutas[i] = {
						smsID:r.lastInsertRowID,
						origen:data.origen,
						destino:data.destino[i],
						hilo:data.hilo
					}
				}
				sql.eGrupoBanca.batch_nocommit(rutas,cb);
			});
		}
		
		
		public function bandejaBanca (data:Object,cb:Function):void {			
			sql.bandejaBanca.run(data,cb);
		}
		public function bandejaGrupo (data:Object,cb:Function):void {			
			sql.bandejaGrupo.run(data,cb);
		}
		
		public function leerBanca (data:Object,cb:Function):void {
			sql.smsBanca.run(data,cb);
		}		
		public function leerGrupo (data:Object,cb:Function):void {
			sql.smsGrupo.run(data,cb);
		}
		
		public function respuestasBanca (data:Object,cb:Function):void {
			sql.rwBancaGrupo.run(data,cb);
		}
		
		public function leido (data:Object,cb:Function=null):void {
			if (data.hasOwnProperty("rutaGrupo")) sql.leidoGrupo.run(data,cb);
			else if (data.hasOwnProperty("rutaBanca")) sql.leidoBanca.run(data,cb);
		}
	}
}