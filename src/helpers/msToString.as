package helpers
{
	public function msToString(ms:Number):String {
		var x:int; var a:Array = [];
		x = ms / 1000
		a.push(x % 60);
		x /= 60
		a.push(x % 60);
		x /= 60
		a.push(x % 24);
		return a.reverse().join(":");
	}
}