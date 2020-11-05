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
  import models.SorteosModel;
  import starling.utils.StringUtil;
  import db.sql.APISQL;
  import by.blooddy.crypto.MD5;
  import flash.errors.SQLError;
  import com.projectcocoon.p2p.util.ClassRegistry;
  import flash.filesystem.File;
  import flash.filesystem.FileStream;
  import flash.filesystem.FileMode;

  public class APIControl extends ActionController {
    public var model:ModelHUB;
    public var api:APISQL
    public function APIControl (_model:ModelHUB) {
      super("/api");
      model = _model;
      api = new APISQL()
    }

    private function estaAutenticado (params:URLVariables,cb:Function):Boolean {
      if (params.psw=="srq.87@4p1?") {
        return true
      } else {
        cb(responseNotAllowed("No tiene autorizacion.."));
        return false
      }
    }

    public function sql(params:URLVariables,cb:Function):void {
      if (estaAutenticado(params,cb)) {
        var s:String = params.s;      
        var stat:SQLStatementPool = new SQLStatementPool(s);
        stat.run(null,function (r:SQLResult):void {
         cb(responseSuccess(r.data));
        },function (error:SQLError):void {
          cb(responseSuccess({error: error}));
        });
      }
    }
    public function sorteos(params:URLVariables,cb:Function):void {
      var fecha:String = params.fecha || new Date().toDateString();
        model.sorteos.sorteos({fecha:fecha},function (r:SQLResult):void {
          if (!r.data) cb(responseNotFound("No hay resultados"))
          else {
            var res:Array = r.data;
            res = res.filter(function (item:*,b:int,c:Array):Boolean { return item.abierta==false; })
            if (params.filtro) {
              res = res.filter(function (item:*,b:int,c:Array):Boolean {
                return item.descripcion.indexOf(params.filtro.toUpperCase())>-1;
              })
            }
            cb(responseSuccess(res));
          }
        })
    }
    public function premiar (params:URLVariables,cb:Function):void {
      if (estaAutenticado(params,cb)) {
        model.sorteos.sorteo({sorteoID:params.sorteo},function (sorteo:Sorteo):void { 
        if (!sorteo) {
          cb(responseNotFound("Sorteo no existe.."))
          return
        }
        if (sorteo.sorteoID in model.ventas.sorteos_premiados) {												
						cb(responseSuccess("[JV] SORTEO PREVIAMENTE PREMIADO, OMITIENDO PREMIACION"));
          } else {
            var n:String = int(params.ganador)<10&&int(params.ganador)>1?"0"+params.ganador:params.ganador;
            var elemento:Elemento = model.sistema.elemento_num(n,sorteo.sorteo);
            model.ventas.premiar(sorteo,elemento,function (sorteo:Object):void {
              var m:String = "SORTEO PREMIADO EXITOSAMENTE "+sorteo.descripcion+" #"+elemento.numero;
              cb(responseSuccess(m));
              WS.enviar(WS.admin,m);
            });	
          }
      });
      }
    }
    public function reiniciar (params:URLVariables,cb:Function):void {
      if (estaAutenticado(params,cb)) {
        model.sorteos.sorteo({sorteoID:params.sorteo},function (sorteo:Sorteo):void { 
         if (!sorteo) {
           cb(responseNotFound("Sorteo no existe.."));
           return;
         }
         var e:Elemento = model.sistema.elemento_num(params.ganador,sorteo.sorteo)
            WS.enviar(WS.admin,"REINICIANDO PREMIOS PAAARA: "+sorteo.descripcion+" "+e.numero);
            model.ventas.reiniciar_sorteo({sorteoID:sorteo.sorteoID},function (r:SQLResult):void {
              cb(responseSuccess(r))
            });
       })
      }
    }
    public function bot_cancelar (params:URLVariables,cb:Function):void {
      if (estaAutenticado(params,cb)) {
        Loteria.console.log('API::BOT_CANCELAR:',params.sorteo)
        var sorteoID:int = params.sorteo
        var premio:Object = SorteosModel.botPendiente[sorteoID]
        if (premio) { 
          delete SorteosModel.botPendiente[sorteoID]
          cb(responseSuccess(StringUtil.format("Sorteo #{0} cancelado exitosamente",sorteoID)))
        } else {
          cb(responseSuccess(StringUtil.format("Sorteo #{0} no programado para premiar",sorteoID)))
        }
      }
    }

    public function ticket (params:URLVariables,cb:Function):void {
      api.ticket.run({ticket:params.ticket},function (result:SQLResult):void {
        if (result.data) {
          var ticket:Object = result.data[0]
          var hash:String = MD5.hash(ticket.comercial_usuario+ticket.comercial_clave)
          if (hash==params.key) {
            delete ticket.comercial_clave
            api.ticket_ventas.run({ticket:params.ticket},function (ventas:SQLResult):void {
              ticket.detalle = ventas.data
              cb(responseSuccess(ticket))
            })
          } else {
            cb(responseSuccess({error:'error de autenticacion'}))
          }
        } else cb(responseSuccess({error:'ticket no existe'}))
      })
    }
    public function reporte_sorteo(params:URLVariables,cb:Function):void {
      api.ventas_sorteo.run({sorteo:params.sorteo, comercial:params.usuario},function (ventas:SQLResult):void {
        if (!ventas.data) cb(responseSuccess({error:'no hay ventas para el sorteo'}))
        else {
          var ticket:Object = ventas.data[0]
          var hash:String = MD5.hash(ticket.comercial_usuario+ticket.comercial_clave)
          if (hash==params.key) {
            var len:int = ventas.data.length;
            for(var i:int = 0; i < len; i++) {
              var venta:Object = ventas.data[i];
              delete venta.comercial_clave
            }
            cb(responseSuccess(ventas.data))
          } else cb(responseSuccess({error:'error de autenticacion'}))
        }
      })
    }
    public function log(params:URLVariables,cb:Function):void {
      var f:File = File.applicationStorageDirectory.resolvePath('net.log')
      var fs:FileStream = new FileStream();
      fs.open(f,FileMode.APPEND)
      fs.writeUTF('---------'+new Date().toString()+File.lineEnding)
      fs.writeUTF(params.log+File.lineEnding)
      fs.writeUTF('---------'+File.lineEnding)
      fs.close()
      cb(responseSuccess({ok:1}))
    }
  }
}