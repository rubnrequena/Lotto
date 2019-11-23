package models
{
	import flash.data.SQLResult;
	
	import db.sql.SmsSQL;
	
	import helpers.ObjectUtil;
	
	import starling.events.EventDispatcher;
	import helpers.DateFormat;
	import starling.utils.execute;
	import flash.net.dns.AAAARecord;

	public class SMSModel extends EventDispatcher
	{
		private var sql:SmsSQL;
		
		public function SMSModel()
		{
			sql = new SmsSQL;
		}
		
		public function nuevo (data:Object,cb:Function=null):void {
			if (!data) return;
			data.enviado = DateFormat.format(null,DateFormat.masks["default"]);
			data.leido = false;
			sql.nuevo.run(data,cb);
			Notificaciones.dispatch(Notificaciones.MENSAJE_NUEVO,data)
		}
		public function recibidos (origen:String,cb:Function=null):void {
			sql.recibidos.run({destino:origen},function recibidosResult(res:SQLResult):void {
				execute(cb,res.data)
			})
		}
		public function enviados (origen:String,cb:Function=null):void {
			sql.enviados.run({origen:origen},cb)
		}
		public function leer(origen:String,destino:String,limite:int=10,cb:Function=null):void {
			sql.leer.run({
				origen:origen,
				destino:destino,
				limite:limite
			},function (leidos:SQLResult):void {
				sinLeer(origen,destino,function (sinLeer:SQLResult):void {
					var m:Array = leidos.data?leidos.data:[]
					execute(cb,m.concat(sinLeer.data))
					leido(origen,destino)
				})
			})
		}
		public function sinLeer(origen:String,destino:String,cb:Function=null):void {
			sql.sinLeer.run({
				origen:origen,
				destino:destino
			},cb)
		}
		public function bandejaEntrada (destino:String,cb:Function):void {
			sql.bandejaEntrada.run({
				destino:destino
			},cb)
		}
		public function leido(origen:String,destino:String,cb:Function=null):void {
			sql.leido.run({
				origen:origen,
				destino:destino
			},cb)
		}
	}
}