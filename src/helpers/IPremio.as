package helpers
{
	import starling.events.IDispatcher;

	public interface IPremio extends IDispatcher
	{
		function buscar (sorteo:String,fecha:Date=null):void;
		function dispose():void;
	}
}