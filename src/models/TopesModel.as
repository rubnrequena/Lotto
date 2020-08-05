package models
{
	import flash.data.SQLResult;
	
	import db.sql.TopesSQL;
	
	import helpers.DateFormat;
	
	import starling.events.Event;
	import starling.events.EventDispatcher;
	import starling.utils.execute;
	
	import vos.Tope;
	
	public class TopesModel extends EventDispatcher
	{
		private var sql:TopesSQL;
		public function TopesModel() {
			super();
			
			sql = new TopesSQL;
		}
		
		public function topes (s:Object,cb:Function):void {
			if (s) {
				if (s.hasOwnProperty("taquillaID") && s.hasOwnProperty("bancaID")) sql.topes.run(s,cb);
				else if (s.hasOwnProperty("bancaID")) sql.topes_banca.run(s,cb);
				else if (s.hasOwnProperty("usuarioID")) sql.topes_usuario.run(s,cb);
				else if (s.hasOwnProperty("taquillaID")) sql.topes_taquilla.run(s,cb);
			} else sql.topes_all.run(s,cb);
		}
		public function nuevo (tope:Object,cb:Function):void {
			tope.creado = DateFormat.format(null,DateFormat.masks["default"]);
			sql.nuevo.run(tope,function (r:SQLResult):void {
				var tp:Tope = new Tope;
				tope.topeID = r.lastInsertRowID;
				tp.importar(tope);
				execute(cb,r.lastInsertRowID);
				dispatchEventWith(Event.CHANGE,false,tp);
			});
		}
		public function remover (tope:Object,cb:Function):void {
			sql.remover.run({topeID:tope.topeID},function (r:SQLResult):void {
				execute(cb,r);
				var tp:Tope = new Tope;
				tp.importar(tope);
				dispatchEventWith(Event.CHANGE,false,tp);
			})
		}
	}
}