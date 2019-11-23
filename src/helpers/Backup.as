package helpers
{
  import models.ModelHUB;
  import flash.net.URLLoader;
  import flash.net.URLRequest;
  import flash.data.SQLResult;
  import flash.net.URLVariables;
  import flash.net.URLRequestMethod;
  import flash.errors.IOError;
  import flash.events.IOErrorEvent;

  public class Backup
  {
    private static var _model:ModelHUB;
    private static var url:String;
    private static var psw:String;

    public static function iniciar (sorteoID:int):void {
      //_model.reportes.general_sorteo()
    }
    
    public static function init(model:ModelHUB):void {
      _model = model;
      url = Loteria.setting.backup.url
      psw = Loteria.setting.backup.psw
    }

    public static function reporte (sorteoID:int):void {
      _model.reportes.respaldoBackup(sorteoID,function reporteBackup_result(res:SQLResult):void {
        if (!res.data) return;
        var loader:URLLoader = new URLLoader;
        loader.addEventListener(IOErrorEvent.IO_ERROR,ioError)
        var uvar:URLVariables = new URLVariables;
        uvar.data = JSON.stringify(res.data)
        uvar.servidor = Loteria.setting.servidor;
        uvar.psw = psw;
        var req:URLRequest = new URLRequest(url);
        req.method  = URLRequestMethod.POST;        
        req.data = uvar;
        loader.load(req);
      })

      function ioError(error:IOErrorEvent):void {
        Loteria.console.log("IMPOSIBLE REALIZAR RESPALDO, no fue posible conectar a ",url)
      }
    }
    
  }
}