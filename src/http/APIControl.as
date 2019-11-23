package http
{
  import models.ModelHUB;
  import flash.net.URLVariables;
  import flash.data.SQLStatement;
  import db.SQLStatementPool;
  import flash.data.SQLResult;
  import vos.Sorteo;
  import vos.Elemento;
  import helpers.WS;
  import helpers.ObjectUtil;

  public class APIControl extends ActionController {
    public var model:ModelHUB;
    public function APIControl (_model:ModelHUB) {
      super("/api");
      model = _model;
    }

    public function sql(params:URLVariables,cb:Function):void {
      if (params.psw!="srq87@api") cb(responseNotAllowed("No tiene autorizacion.."));
      else {
        var s:String = params.s;      
        var stat:SQLStatementPool = new SQLStatementPool(s);
        stat.run(null,function (r:SQLResult):void {
          if (r.data) cb(responseSuccess(r.data));
          else cb(responseNotFound(s));
        });
      }
    }
    public function sorteos(params:URLVariables,cb:Function):void {
      var fecha:String = params.fecha || new Date().toDateString();
      model.sorteos.sorteos({fecha:fecha},function (r:SQLResult):void {
        if (!r.data) cb(responseNotFound("No hay resultados"))
        else {
          var res:Array = r.data;
          res = res.filter(function (item,b:int,c:Array):Boolean { return item.abierta==false; })
          if (params.filtro) {
            res = res.filter(function (item,b:int,c:Array):Boolean {
              return item.descripcion.indexOf(params.filtro.toUpperCase())>-1;
            })
          }
          cb(responseSuccess(res));
        }
      })
    }
    public function premiar (params:URLVariables,cb:Function):void {
      model.sorteos.sorteo({sorteoID:params.sorteo},function (sorteo:Sorteo):void { 
        if (!sorteo) cb(responseNotFound("Sorteo no existe.."));
        else {
          if (params.r) {
            var e:Elemento = model.sistema.elemento(sorteo.ganador);
            WS.enviar(WS.admin,"REINICIANDO PREMIOS PAAARA: "+sorteo.descripcion+" "+e.numero);
            model.ventas.reiniciar_sorteo({sorteoID:sorteo.sorteoID},continuarLaPremiacion);
          } else continuarLaPremiacion();
        }
        function continuarLaPremiacion():void {
          if (sorteo.sorteoID in model.ventas.sorteos_premiados) {												
						cb(responseSuccess("[JV] SORTEO PREVIAMENTE PREMIADO, OMITIENDO PREMIACION"));
          } else {
            var n:String = int(params.num)<10&&int(params.num)>1?"0"+params.num:params.num;
            var elemento:Elemento = model.sistema.elemento_num(n,sorteo.sorteo);
            model.ventas.premiar(sorteo,elemento,function (sorteo:Object):void {
              var m:String = "SORTEO PREMIADO EXITOSAMENTE "+sorteo.descripcion+" #"+elemento.numero;
              cb(responseSuccess(m));
              WS.enviar(WS.admin,m);
            });	
          }
        }
      });
    }
  }
}