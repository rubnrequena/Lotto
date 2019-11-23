package models
{
  import starling.events.EventDispatcher;
  import starling.events.Event;
  import helpers.WS;
  import flash.data.SQLResult;
  import vos.Usuario;
  import starling.utils.StringUtil;
  import starling.utils.execute;
  import vos.UsuarioMin;

  public class Notificaciones
  {
    static public const BALANCE_NUEVO:String = "balance_nuevo";
    static public const CONFIRMAR_PAGO:String = "confirmar_pago";
    static public const MENSAJE_NUEVO:String = "mensaje_nuevo";

    private const MENSAJES:Object = {
      pagoRecibido:'*PAGO RECIBIDO*\n{0}\nMonto: *{1}*',
      cobroEnviado:'Se le informa que hemos generado un saldo deudor de *{0}* por concepto de *{1}* con la referencia *#{2}*',
      pagoConfirmado:'*PAGO CONFIRMADO*\n*{0}*\nMonto: *{1}*\nRecibo: *{2}*',
      mensajeNuevo:'*Mensaje SRQ*\n_De:_ *{0}*\n_Mensaje:_ {1}'
    }
    static public var listeners:EventDispatcher
    
    static public function dispatch (event:String,data:Object):void {
      listeners.dispatchEventWith(event,false,data)
    }
    private const rID:RegExp = /\d+/
    protected var model:ModelHUB
    protected var cacheUsuarios:Object = {}

    public function Notificaciones(modelHub:ModelHUB) {
      model = modelHub
      listeners = new EventDispatcher

      listeners.addEventListener(BALANCE_NUEVO,balanceNuevo)
      listeners.addEventListener(CONFIRMAR_PAGO,confirmarPago)
      listeners.addEventListener(MENSAJE_NUEVO,mensajeNuevo)
    }

    private function buscarUsuario(usID:String,cb:Function):void {
      if (cacheUsuarios.hasOwnProperty(usID)) {
        trace('Notificacion: desde cache..')
        execute(cb,cacheUsuarios[usID])
      } else {
        var uID:int = rID.exec(usID)[0]
        model.usuarios.usuario(usID,function (usuario:UsuarioMin):void {
          cacheUsuarios[usID] = usuario
          execute(cb,usuario)
          trace('Notificacion: al cache..')
        })
      }
    }

    private function confirmarPago(e:Event,balance:Object):void {      
      var usID:int = rID.exec(balance.usID)[0]
      model.usuarios.usuarios({uid:usID},function (usuario:Usuario):void {
        usID = rID.exec(balance.resID)[0]
        var nombre:String = usuario.nombre
        model.usuarios.usuarios({uid:usID},function (responsable:Usuario):void {
          var monto:Number = Math.abs(balance.monto)
          var descripcion:String = balance.desc
          var recibo:String = balance.balID
          var msg:String = StringUtil.format(MENSAJES.pagoConfirmado,descripcion,monto,recibo)
          model.sms.nuevo({
            origen:responsable.usID,
            origenNombre:responsable.nombre,
            destino:usuario.usID,
            mensaje:msg
            });
        })
      })
    }
    private function balanceNuevo (e:Event,balance:Object):void {
      model.usuarios.usuario(balance.usID,function (usuario:UsuarioMin):void {
        model.usuarios.usuario(balance.resID,function (responsable:UsuarioMin):void {
          var monto:Number = Math.abs(balance.monto)
          var descripcion:String = balance.desc
          var msg:Object
          if (balance.monto<0) {
            msg = {
            origen:usuario.usID,
            origenNombre:usuario.nombre,
            destino:responsable.usID,
            mensaje:StringUtil.format(MENSAJES.pagoRecibido,descripcion,monto)
            }
          } else {
            msg = msg = {
            origen:responsable.usID,
            origenNombre:responsable.nombre,
            destino:usuario.usID,
            mensaje:StringUtil.format(MENSAJES.cobroEnviado,monto,descripcion,balance.balID)
            }
          }
          
          model.sms.nuevo(msg);
        },usuario_error)
      },usuario_error)

      function usuario_error(msg:String,usID:String):void {
        Loteria.console.log(StringUtil.format('Notificaciones.as: Error, {0}, {1}',msg,usID))
      }
    }
    private function mensajeNuevo(e:Event,mensaje:Object):void {
      buscarUsuario(mensaje.origen,function (origen:UsuarioMin):void {
        if (!origen) return
        buscarUsuario(mensaje.destino,function (destino:UsuarioMin):void {
          if (!destino || destino.contacto==null || destino.contacto=='') return;
          WS.enviar(destino.contacto,StringUtil.format(MENSAJES.mensajeNuevo,mensaje.origenNombre,mensaje.mensaje))
        })
      }) 
    }
  }
}