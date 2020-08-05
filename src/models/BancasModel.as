package models
{
	import flash.data.SQLResult;
	import flash.errors.SQLError;
	
	import db.sql.BancasSQL;
	
	import helpers.DateFormat;
	import helpers.ObjectUtil;
	
	import starling.events.EventDispatcher;
	import starling.utils.execute;
	
	import vos.Banca;
	
	public class BancasModel extends EventDispatcher
	{
		private var sql:BancasSQL;
		private var _bancas:Vector.<Banca>;
		public function get bancas():Vector.<Banca> { return _bancas; }
		
		public function BancasModel() {
			super();
			sql = new BancasSQL;
			force_update();
		}
		
		public function force_update ():void {
			sql.bancas.run(null,bancas_update);
		}
		
		private function bancas_update(r:SQLResult):void {
			_bancas = Vector.<Banca>(r.data || []);
		}
		
		public function login (data:Object,cb:Function):void {
			// realizar login sin consultar base de datos
			sql.login.run(data,cb);
			// alertar login de banca a usuarios
		}
		
		public function nueva (banca:Object,cb:Function,error:Function=null):void {
			if (ObjectUtil.find(banca.usuario,"usuario",bancas)) {
				execute(error,new SQLError("INSERT INTO us.bancas","campo usuario duplicado","campo usuario duplicado",0,2));
			} else {
				banca.usuario = (banca.usuario as String).toLowerCase();
				banca.clave = (banca.clave as String).toLowerCase();
				banca.creacion = DateFormat.format(null,DateFormat.masks["default"]);
				sql.banca_nueva.run(banca,function (r:SQLResult):void {
					sql.bancas.run(null,bancas_update); //optimizar, evitar consultar la base de datos
					execute(cb,r);
				},error);
			}
		}
		
		public function meta (filtro:Object,cb:Function):void {
			sql.meta.run(filtro,cb);
		}
		
		public function buscar (filtro:Object,cb:Function):void {
			if (filtro) {
				if (filtro.hasOwnProperty("id")) sql.bancas_id.run(filtro,cb);
				else if (filtro.hasOwnProperty("usuario")) sql.bancas_usuario.run(filtro,cb);
			} else sql.bancas.run(null,cb);
		}
		
		public function nombres (s:Object,cb:Function):void {
			if (s) {
				if (s.hasOwnProperty("usuarioID")) sql.nombres_usuario(s,cb);
			} else sql.nombres.run(null,cb);
		}
		
		public function editar(banca:Object, cb:Function=null):void {
			if (banca.hasOwnProperty("clave")) sql.clave.run(banca,result);
			else if (banca.hasOwnProperty("activa")) sql.activa.run(banca,result);
			else if (banca.hasOwnProperty("renta")) sql.renta.run(banca,result);
			else if (banca.hasOwnProperty("papelera")) sql.papelera.run(banca,result);
			else {
				var b:Banca = ObjectUtil.find(banca.usuario,"usuario",bancas); 
				if (b && b.bancaID!=banca.bancaID) execute(cb,new SQLResult) ;
				else sql.editar.run(banca,result);
			}
			
			function result (r:SQLResult):void {
				sql.bancas.run(null,bancas_update);
				execute(cb,r);
			}
		}
		
		public function relacion_pago (data:Object,cb:Function):void {
			sql.relacion_pago_consulta.run({bancaID:data.bancaID,sorteo:data.sorteo},function (r:SQLResult):void {
				if (r.data) sql.relacion_pago_editar.run({relacion:r.data[0].relacionID,valor:data.valor},cb);
				else sql.relacion_pago_nuevo.run(data,cb);
			});
		}
		
		public function transferir(data:Object, cb:Function):void {
			sql.transferir.run(data,cb);
		}
		
		public function estaActiva (id:int,cb:Function):void {
			sql.banca_activa.run({gID:id},function (res:SQLResult):void {
				if (res.data) execute(cb,true);
				else execute(cb,false);
			});
		}
	}
}