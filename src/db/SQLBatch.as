package db
{
	public class SQLBatch
	{		
		private var pool:SQLStatementPool;
		private var data:*;
		
		public function SQLBatch(pool:SQLStatementPool,data:*) {
			this.pool = pool;
			this.data = data;
		}
		
		public function run (complete:Function,error:Function=null,prefetch:int=-1):void {
			pool.run(data,complete,error,prefetch);
		}
	}
}