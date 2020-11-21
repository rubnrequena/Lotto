package http
{
  import models.ModelHUB;
  import flash.net.URLVariables;
  import vos.Taquilla;
  import vos.Sesion;
  import flash.utils.getTimer;
  import vos.Sorteo;
  import helpers.LTool;
  import helpers.bm.EGrupo;
  import vos.Tope;
  import helpers.DateFormat;
  import flash.data.SQLResult;
  import helpers.ObjectUtil;
  import starling.core.Starling;
  import starling.events.Event;

  public class TaqControl extends ActionController
    {
      private var _model:ModelHUB;
      
      public function TaqControl(model:ModelHUB)
      {
        super('/taq');
        _model = model;
      }
      
      public function login(params:URLVariables,res:Function):void
      {
        var usuario:String = params.u;
        var clave:String = params.c;
        _model.taquillas.httpLogin(usuario,clave,function (msg:Object):void {
          res(responseSuccess(msg));
        })
      }
      public function ping(params:URLVariables):String  {
        var sesion:String = params.sesion;
        if (!_model.taquillas.httpSesion(sesion)) return responseSuccess({error:"sesion_invalida",msg:"Su sesion ha expirado"});
        else  return responseSuccess({"msg":"Sesion valida"})
      }
      public var _topes:Vector.<Tope>;
      public var _cache:Array;
      public var invalidos:Array;
      public function venta (params:URLVariables,res:Function):void {
        //var now:Number = new Date().getTime();
        if (Starling.current.hasEventListener(params.sesion)) {
          Starling.current.addEventListener(params.sesion+"_callback",callback)
          try {
            var payload:Object = JSON.parse(params.data)
            Starling.current.dispatchEventWith(params.sesion,false,payload)
            Loteria.console.log('Recibiendo venta http')
          } catch (error:Error) {
            res(responseSuccess({error:'error al interpretar venta'}))
          }
        } else res(responseSuccess({error:'sesion no encontrada'}))

        function callback(e:Event,data:Object):void {
            Loteria.console.log('Respondiendo venta http')
          //Loteria.console.log("full time",new Date().getTime()-now,"ms")
          Starling.current.removeEventListener(params.sesion+"_callback",callback)
          res(responseSuccess(data))
        }
      }
    }
}