package vos
{
  public class PremioAproximacion
  {
    public var numAbajo:String
    public var numArriba:String
    public var premio:int
    private var _esValido:Boolean = false;

    public function get esValido():Boolean
    {
    	return _esValido;
    }

    public function PremioAproximacion(data:Object)
    {
      if (data) {
        numAbajo = data.numAbajo
        numArriba = data.numArriba
        premio = data.premio  
        _esValido=true
      } 
    }
  }
}