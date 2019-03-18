package helpers.print
{
	import flash.filesystem.File;
	import flash.geom.Orientation3D;
	
	import models.ModelHUB;
	import models.SistemaModel;
	
	import vos.Elemento;
	import vos.Taquilla;

	public class ModoExtremo
	{
		public function ModoExtremo()
		{
			
		}
		
		
		
		public static function imprimirVentas_extremo (cesto:Array,ticket:Object,taquilla:Taquilla,hub:ModelHUB):String {
			var _lineas:Array = [taquilla.nombre,ticket.hora,"S:"+padding(ticket.ticketID,6)+" C:"+padding(ticket.codigo)+" N:"+cesto.length];
			/*if (copia) _lineas.push({type:"linea",text:"COPIA TICKET",align:"center"});
			else _lineas.push({type:"linea",text:"TICKET",align:"center"});*/
			
			cesto.sort(sorteos_order);
			
			var linea:Object = cesto[0], el:Object;
			var csorteo:Array = [];
			for (var i:int=0;i<cesto.length;i++) {
				if (linea.sorteoID != cesto[i].sorteoID) {
					_lineas.push(hub.mSorteos.getSorteo(linea.sorteoID).descripcion);
					csorteo.sort(cesto_ordenMonto);
					cesto_print(csorteo,_lineas);
					csorteo = [];
				}
				csorteo.push(cesto[i]);
				linea = cesto[i];
			}
			_lineas.push(hub.mSorteos.getSorteo(linea.sorteoID).descripcion);
			csorteo.sort(cesto_ordenMonto);
			cesto_print(csorteo,_lineas);
			
			//_lineas.push({type:"linea",text:"TOTAL: "+ticket.monto,align:"center"});
			if(taquilla.fingerprint)
				_lineas.push("*T:"+Number(ticket.monto).toFixed(2)+"* AG"+taquilla.fingerprint);
			else 
				_lineas.push("*T:"+Number(ticket.monto).toFixed(2)+"*");
			
			return _lineas.join("\n");
		}
		
		private static function sorteos_order (a:Object,b:Object):int {
			var s1:int = a.sorteoID, s2:int = b.sorteoID;
			var n1:int = a.numero, n2:int = b.numero;
			return s1 == s2?n1-n2:s1-s2;
		} //ordenarlas por sorteo
		
		protected static function cesto_print (c:Array,cursor:Array):void {
			var tx:String;
			var e:Object = c[0]; var n:Array = []; var el:Elemento;
			for (var i:int=0;i< c.length;i++) {
				if (c[i].monto!= e.monto) {
					parseItems(n,e);
					n=[];
				}
				el = SistemaModel.elemento(c[i].numero); // FALTA BUSCAR NUMERO DEL ANIMAL
				n.push(el.numero);
				e = c[i];
			}
			//ultimo grupo jugadas
			parseItems(n,e);
			
			function parseItems (n,e):void {
				var a:int, b:int,c:int;
				tx = zip_series(n).join(",")+"x"+e.monto;
				var atx:Array = tx.split(",");
				while (atx.length>0) {
					tx = atx.splice(0,8).join(",");
					a = cursor[cursor.length-1].length;
					b = tx.length; c = a+b;
					if (c>25) {
						if (b<=25) cursor.push(tx);
						else {
							var ci:int = tx.indexOf(",",22);
							if (ci==-1) ci = tx.indexOf("x",22);
							cursor.push(tx.substr(0,ci)+"-");
							cursor.push(tx.substr(ci));
						}
					} else {
						cursor[cursor.length-1] += ";"+tx;
					}
				}
			}			
		}
		protected static function cesto_ordenMonto (a,b):int {
			var s1:int = a.monto, s2:int = b.monto;
			var n1:int = a.numero, n2:int = b.numero;
			return s1 == s2?n1-n2:s1-s2;
		}
		protected static function zip_series (a:Array):Array {
			var b:Array = [a[0]];
			var a1:int,a2:int;
			for (var i:int =1; i< a.length; i++) {
				a1 = parseInt(a[i]); a2 = parseInt(a[i-1])+1;
				if (a1!=a2) {
					if (b[b.length-1]!=a[i-1]) b[b.length-1] += "/"+a[i-1];
					b.push(a[i]);
				}
			}
			if (a1==a2) {
				if (b[b.length-1]!=a[i-1]) b[b.length-1] += "/"+a[i-1];
			}
			return b;
		}
		
		protected static function padding (val:String, len:int=1):String {
			val = String(val);
			while (val.length < len) val = "0" + val;
			return val;
		};
	}
}