package helpers.pools
{
	import flash.net.URLLoader;

	public class LoaderPool
	{
		private static var MAX_VALUE:uint; 
		private static var GROWTH_VALUE:uint; 
		private static var counter:uint; 
		private static var pool:Vector.<URLLoader>; 
		private static var currentloader:URLLoader; 
		
		public function LoaderPool()
		{
		}
		
		public static function initialize( maxPoolSize:uint, growthValue:uint ):void 
		{ 
			MAX_VALUE = maxPoolSize; 
			GROWTH_VALUE = growthValue; 
			counter = maxPoolSize; 
			
			var i:uint = maxPoolSize; 
			
			pool = new Vector.<URLLoader>(MAX_VALUE); 
			while( --i > -1 ) 
				pool[i] = new URLLoader(); 
		} 
		
		public static function getItem():URLLoader 
		{ 
			if ( counter > 0 ) 
				return currentloader = pool[--counter]; 
			
			var i:uint = GROWTH_VALUE; 
			while( --i > -1 ) 
				pool.unshift ( new URLLoader() ); 
			counter = GROWTH_VALUE; 
			return getItem();
			
		} 
		
		public static function dispose(disposedSprite:URLLoader):void 
		{ 
			pool[counter++] = disposedSprite; 
		} 
	}
}