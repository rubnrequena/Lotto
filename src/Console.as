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
	import feathers.controls.Button;
	import starling.events.Event;
	import feathers.layout.HorizontalLayout;
	
	public class Console extends LayoutGroup
	{
    public static const SINCRONIZAR:String = 'sincronizar'
    public static const PERMITIR_VENTAS:String = 'permitirVentas'
    public static const COMMIT:String = 'commit'


		private var list:List;
		private var errorList:List;
		private var logData:ListCollection;
		private var errorData:ListCollection;		

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
			
			logData = new ListCollection;
			errorData = new ListCollection;
			buffer = "";
			sql_buffer = "";
			
			list = new List();
			list.layoutData = new AnchorLayoutData(20,0,0,0);
			list.dataProvider = logData;
			list.itemRendererFactory = function ():IListItemRenderer {
				var item:DefaultListItemRenderer = new DefaultListItemRenderer;
				item.labelField = "text";
				item.iconLabelField = "tiempo";
				return item;
			};
			addChild(list);

      var btnBar:LayoutGroup = new LayoutGroup
      btnBar.layout = new HorizontalLayout

			var estaVendiendo:Boolean = true
			var ventasButton:Button = new Button
			ventasButton.label = "Ventas: SI"
			ventasButton.addEventListener(Event.TRIGGERED,function ():void {
        ventasButton.label = estaVendiendo?"Ventas: NO":"Ventas: SI";
				estaVendiendo = !estaVendiendo;
        log('Ventas activadas:',estaVendiendo?"SI":"NO")
        dispatchEventWith(PERMITIR_VENTAS,false,ventasButton);
			})
      btnBar.addChild(ventasButton)
			

      var estaSync:Boolean = true;
      var syncButton:Button = new Button;
      syncButton.label = 'Sync: SI';
      syncButton.addEventListener(Event.TRIGGERED,function ():void { 
        syncButton.label = estaSync?'Sync: NO':'Sync: SI';
        estaSync = !estaSync;
        log('Sincronizador activado:',estaSync?"SI":"NO")
        dispatchEventWith(SINCRONIZAR,false,estaSync)
      })
      btnBar.addChild(syncButton)

      var commitForzado:Button = new Button
      commitForzado.label = "Forzar Commit"
      commitForzado.addEventListener(Event.TRIGGERED,function ():void {
        dispatchEventWith(COMMIT,false)
      })
      btnBar.addChild(commitForzado)

      var btnLog:Button = new Button
      btnLog.label = "Mostrar Errores"
      btnLog.addEventListener(Event.TRIGGERED,function ():void {
        if (btnLog.label=="Mostrar Errores") {
          list.dataProvider = errorData
          btnLog.label="Mostrar Informe"
        } else {
          list.dataProvider = logData
          btnLog.label="Mostrar Errores"
        }
        
      })
      btnBar.addChild(btnLog)
      
      addChild(btnBar)
			
			log('BIENVENIDO AL SISTEMA DE LOTERIA');
			log('ERROR LOG: Consola de errores inicializada')
			
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
			},5000);
		}
		
		private var rg:RegExp = /(INSERT INTO|DELETE|UPDATE|CREATE)/gm;
		
		public function trac (sql:String):void {
			if (sql.search(rg)==0) {
				time = new Date;
				sql_buffer += sql+File.lineEnding;
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
			var data:ListCollection = str.indexOf("ERROR")>-1?errorData:logData
			if (data.length>200) {
				data.removeAll();
				stream.writeUTFBytes(buffer);
				buffer="";
			}			
			time = new Date;
			data.addItemAt({tiempo:DateFormat.format(time,DateFormat.masks.mediumTime),text:str},0);									
			buffer += DateFormat.format(time,DateFormat.masks.isoTime)+"\t"+str+File.lineEnding;
		}
		public function error (...s):void {			
			str = s.join(" ");
			var data:ListCollection = errorData
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