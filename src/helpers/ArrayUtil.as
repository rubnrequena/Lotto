package helpers
{
  public class ArrayUtil
  {
    static public function split (source:Array,max:int):Array {
      if (source.length<max) return [source]
      var len:int = source.length;
      var n:int = Math.ceil(len / max);
      var result:Array=[]
      for(var i:int = 0; i < n; i++) {
          result.push(source.slice(i*max,max*(i+1)))
      }
      return result
    }
  }
}