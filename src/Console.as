package
{
	import flash.desktop.NativeApplication;
	import flash.events.OutputProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.renderers.DefaultListItemRenderer;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import helpers.DateFormat;
	
	public class Console extends LayoutGroup
	{
		private var list:List;
		private var data:ListCollection;
		private var buffer:String;
		private var time:Date;
		
		private var write:Boolean;
		private var file:File;
		private var stream:FileStream;
		
		private var exit:Boolean;
		private var sql_stream:FileStream;
		private var sql_buffer:String;
		private var sql_cfolder:File;
		
		private var str:String;
		private	var sqlfn:String;
		
		public function Console() {
			super();
			
			stream = new FileStream;
			stream.openAsync(File.applicationStorageDirectory.resolvePath("log").resolvePath(DateFormat.format(null,'yymmdd')+".txt"),FileMode.APPEND);
			
			sql_stream = new FileStream();
			sql_cfolder = new File(Loteria.setting.db.log);
						
			sqlfn = Loteria.setting.servidor+DateFormat.format(null,"_yyyymmdd_HH")+".sql";
			
			layout = new AnchorLayout;
			
			data = new ListCollection;
			buffer = "";
			sql_buffer = "";
			
			list = new List();
			list.layoutData = new AnchorLayoutData(0,0,0,0);
			list.dataProvider = data;
			list.itemRendererFactory = function ():IListItemRenderer {
				var item:DefaultListItemRenderer = new DefaultListItemRenderer;
				item.labelField = "text";
				item.iconLabelField = "tiempo";
				return item;
			};
			addChild(list);
			
			log('BIENVENIDO AL SISTEMA DE LOTERIA');
			
			setTimeout(function ():void {
				
				NativeApplication.nativeApplication.addEventListener("exiting",function (e:*):void {
					if (exit==false) {
						e.preventDefault();
						exit=true;
						stream.addEventListener(OutputProgressEvent.OUTPUT_PROGRESS,function (e:OutputProgressEvent):void {
							trace("CONSOLA GUARDADA, SALIENDO");
							NativeApplication.nativeApplication.exit();	
						});
						stream.writeUTFBytes(buffer);
						
						sql_stream.open(sql_cfolder.resolvePath(sqlfn),FileMode.APPEND);
						sql_stream.writeUTFBytes(sql_buffer);
						sql_stream.close();
					}
				});
			},1000);
						
			setInterval(function ():void {
				if (sql_buffer.length>0) {
					sqlfn = Loteria.setting.servidor+DateFormat.format(null,"_yyyymmdd_HH")+".sql";
					sql_stream.open(sql_cfolder.resolvePath(sqlfn),FileMode.APPEND);
					sql_stream.writeUTFBytes(sql_buffer);
					sql_stream.close();
					sql_buffer = "";
				}
			},60000);
		}
		
		private var rg:RegExp = /(INSERT INTO|DELETE|UPDATE|CREATE)/gm;
		
		public function trac (sql:String,ms,data:Object):void {			
			if (sql.search(rg)==0) {
				time = new Date;
				sql_buffer += DateFormat.format(time,DateFormat.masks.isoTime)+"|"+ms+"ms"+"|"+convertir(sql,data)+File.lineEnding;
			}
		}
		
		private function convertir (s:String,data:Object):String {
			var p:String;
			
			for (p in data) {
				s = s.replace(":"+p,'"'+data[p]+'"');
			}			
			return s;
		}
		
		public function log (...s):void {
			str = s.join(" ");
			if (data.length>200) {
				data.removeAll();

				stream.writeUTFBytes(buffer);
				buffer="";
			}
			
			time = new Date;
			data.addItemAt({tiempo:DateFormat.format(time,DateFormat.masks.mediumTime),text:str},0);			
						
			buffer += DateFormat.format(time,DateFormat.masks.isoTime)+"\t"+str+File.lineEnding;
		}
		
		public static function saveTo (text:String,to:File,fs:FileStream=null,close:Boolean=true):void {
			if (fs==null) { 
				fs = new FileStream;
				fs.open(to,FileMode.WRITE);
			}
			fs.writeMultiByte(text,File.systemCharset);
			if (close) fs.close();
		}
	}
}