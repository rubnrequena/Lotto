package models
{
	import starling.events.EventDispatcher;
	
	public class Model extends EventDispatcher
	{
		protected var owner:ModelHUB;
		public function Model(owner:ModelHUB)
		{
			super();
			this.owner = owner; 
		}
	}
}