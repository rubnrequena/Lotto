package vos
{
	import by.blooddy.crypto.MD5;
	import flash.utils.getTimer;

	public class Sesion {
    static private const LIMITE_SESSION:int = 1000*60

		protected var _taquilla: Taquilla;
    protected var _hash:String;
    protected var _expira:int;
    public var meta:Object;

    public function Sesion(taq:Taquilla) {
      var now:int = getTimer();
      _taquilla = taq;
      _hash = MD5.hash(taq.usuario+now);
      _expira = now;
    }

    public function get taquilla ():Taquilla {
      return _taquilla;
    }
    public function get hash():String {
      return _hash;
    }
    public function get esValida():Boolean {
      var now:int = getTimer();
      if (now-_expira>LIMITE_SESSION) return false;
      else {
        _expira = now;
        return true;
      }
    }
	}
}