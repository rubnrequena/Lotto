package models
{
	import flash.data.SQLResult;

	import db.SQLStatementPool;
	import db.sql.SorteosSQL;

	import starling.events.EventDispatcher;
	import starling.utils.execute;

	import vos.PreSorteo;
	import vos.Sorteo;
	import vos.Usuario;
	import vos.sistema.Admin;
	import flash.errors.SQLError;
	import helpers.DateFormat;
	import flash.utils.setTimeout;
	import helpers.WS;
	import starling.utils.StringUtil;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLVariables;
	import flash.net.URLLoader;
	import flash.events.Event;
	import flash.events.ErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.errors.IOError;
	import mx.events.Request;
	import flash.net.URLRequestMethod;
	import vos.sistema.Operadora;

	public class SorteosModel extends EventDispatcher
	{
		private var sql:SorteosSQL;
		static public var sorteosPendientes:Array = []

		private var _presorteos:Array; //examinar funcion
		public function get presorteos():Array { return _presorteos; }

		public function SorteosModel() {
			super();
			sql = new SorteosSQL;

			pre_sorteos(null,pre_sorteosFunction);
		}

		public function publicos (sorteo:Object,cb:Function):void {
			sql.publicos.run(sorteo,cb);
		}
		public function publicos_remover (sorteo:Object,cb:Function):void {
			sql.remover_publico.run(sorteo,cb);
		}
		public function publicos_editar (sorteo:Object,cb:Function):void {
			sql.editar_publico.run(sorteo,cb);
		}
		public function publicar (sorteos:Array,cb:Function):void {
			sql.publicar.batch(sorteos,cb);
		}


		//SORTEOS
		public function sorteo (sorteo:Object,cb:Function):void {
			sql.sorteo.run(sorteo,function (r:SQLResult):void {
				execute(cb,r.data?r.data[0]:null);
			});
		}
		public function sorteos (busq:Object,cb:Function):void {
			if (busq) {
				if (busq.hasOwnProperty("taquilla") && busq.hasOwnProperty("banca")) {
					if (busq.hasOwnProperty("fecha")) sql.sorteos_fecha_taq.run(busq,cb);
				} else if (busq.hasOwnProperty("usuarioID")) {
					if (busq.hasOwnProperty("fecha")) sql.fecha_usuario.run(busq,cb);
					else if (busq.hasOwnProperty("lista")) sql.lista_usuario.run(busq,cb);
					else sql.usuario_publico.run(busq,cb);
				} else {
					if (busq.hasOwnProperty("fecha")) sql.sorteos_fecha.run(busq,cb);
					else if (busq.hasOwnProperty("gfecha")) sql.sorteos_fecha_agrupado.run(busq,cb);
					else if (busq.hasOwnProperty("nombres")) sql.sorteos_fecha_nombres.run(busq,cb);
					else if (busq.hasOwnProperty("lista")) {
						if (busq.hasOwnProperty("adminID")) sql.sorteos_fecha_lista_admin.run(busq,cb);
						else sql.sorteos_fecha_lista.run(busq,cb);
					}
					else if (busq.hasOwnProperty("dia")) sql.sorteos_dia.run(busq,cb);
				}
			} else sql.sorteos.run(null,cb);
		}

    public function operadora (sorteoID:int,cb:Function):void {
      sql.operadora.run({sorteoID:sorteoID},function (r:SQLResult):void {
        if (r.data) execute(cb,null,r.data[0])
        else execute(cb,'sorteo no existe')
      })
    }

		public function editar_abierta (sorteo:Object,cb:Function):void {
			sql.editar.run(sorteo,function (r:SQLResult):void {
				execute(cb,r);
				dispatchEventWith(ModelEvent.ESTATUS_CHANGE,false,sorteo);
			});
		}
		public function premio (sorteo:Object,cb:Function):void {
			if (sorteo.hasOwnProperty("sorteoID")) sql.premio.run(sorteo,cb);
		}

		public function registrar (sorteos:Vector.<int>,fecha:String,cb:Function):void {
			var hora:int, minutos:int, _mer:String;
			var anio:int, mes:int, dia:int;
			var inicio:Date, final:Date;
			var presorteo:PreSorteo;
			var a:Array, _sorteos:Array = [];

			for each (var sorteoID:int in sorteos) {
				//sorteo
				for each (var ps:PreSorteo in _presorteos) {
					if (ps.sorteoID==sorteoID) { presorteo = ps; break; }
				}
				//fecha
				a = fecha.split("-");
				dia = a[2];
				mes = int(a[1])-1;
				anio = a[0];
				//hora inicio
				a = presorteo.inicio.split(" ");
				_mer = a[1];
				a = a[0].split(":");
				hora = int(a[0]);
				if (_mer=="PM" && hora > 12) hora += 12 else if (_mer=="AM" && hora==12) hora = 0;
				minutos = a[1];
				inicio = new Date(anio,mes,dia,hora,minutos);
				//hora inicio
				a = presorteo.final.split(" ");
				_mer = a[1];
				a = a[0].split(":");
				hora = int(a[0]);
				if (_mer=="PM" && hora < 12) hora += 12 else if (_mer=="AM" && hora==12) hora = 0;
				minutos = a[1];
				final = new Date(anio,mes,dia,hora,minutos);
				//trace(inicio.toString(),final.toString());
				_sorteos.push({
					sorteo:presorteo.sorteo,
					descripcion:presorteo.descripcion,
					abre:inicio.time,
					cierra:final.time,
					fecha:fecha,
					abierta:true
				});
			}
			sql.nuevo.batch(_sorteos,function (r:Vector.<SQLResult>):void {
				execute(cb,r);
				dispatchEventWith(ModelEvent.SORTEOS_REGISTRADOS,false,fecha);
			});
		}
		public function convertir_zodiaco (s:Object,cb:Function):void {
			sql.convertir_zodiaco.run(s,cb);
		}


		//PRE SORTEOS
		public function nuevo (sorteo:Object,cb:Function):void {
			sql.presorteo_nuevo.run(sorteo,function (r:SQLResult):void {
				execute(cb,r);
				pre_sorteos(null,pre_sorteosFunction);
			});
		}
		public function remover_sorteo (s:Object,cb:Function):void {
			sql.remover_sorteo.multi(s,null,function (res:*):void {
				pre_sorteos(null,pre_sorteosFunction);
				execute(cb,res);
			});
		}
		public function remover (sorteo:Object,cb:Function):void {
			sql.presorteo_remover.run(sorteo,function (r:SQLResult):void {
				execute(cb,r);
				pre_sorteos(null,pre_sorteosFunction);
			});
		}
		public function pre_sorteos (filtro:Object,cb:Function):void {
			sql.presorteos.run(filtro,cb);
		}

		protected function pre_sorteosFunction(r:SQLResult):void {
			_presorteos = r.data;
		}

		public function pendientes(data:Object, cb:Function):void {
			sql.pendientes.run(data,cb);
		}
    static public var botPendiente:Object = {}
    
		public function autoPremiar (sorteo:Sorteo,cb:Function):void {
      var fecha:String = DateFormat.format(new Date);
			sql.auto_premiar.run({sorteoID:sorteo.sorteoID,sorteo:sorteo.sorteo,fecha:fecha},function (sorteos:SQLResult):void {
			  if (sorteos.data) {
          var bot:Object = sorteos.data[0]
          execute(cb,true)
          obtenerRelacion_sorteo(sorteo.sorteoID,bot.relacion,function (error:String,ganador:Object):void {
            if (error) { return Loteria.console.error(error) }
            var msg2:String = StringUtil.format("PREMIOBOT: El sorteo {0} se ha programado para ser premiado\nNUMERO: {1}",sorteo.descripcion,ganador.numeroTexto)
            Loteria.console.log(msg2)
            operadora(sorteo.sorteo,function (error:String,operadora:Operadora):void {
              if (error) { return Loteria.console.error(error) }
              ganador.sorteoID = sorteo.sorteoID
              WS.telegram("premio_bot",{
                fase:"confirmar",
                operadora: operadora.clase,
                sorteo: sorteo.descripcion,
                sorteo_id:sorteo.sorteoID,
                msg: msg2+"\n"+JSON.stringify(ganador,null,2)
              })
            })
            setTimeout(function ():void {
              var ganador:Object = botPendiente[sorteo.sorteoID]
              if (!ganador) {
                WS.enviar(WS.admin,StringUtil.format("PREMIOBOT: Premiacion de sorteo {0} CANCELADO",sorteo.descripcion))
                return execute(cb,false)
              } else {
                dispatchEventWith(ModelEvent.AUTO_PREMIAR_COMPLETE,false,{
                  sorteo:sorteo,
                  ganador: ganador
                })
                notificarPremiacion(sorteo,ganador)
              }
            },Loteria.setting.premios.bot.retraso /*5 minutos*/)
          })
        } else execute(cb,false)
			})
      function obtenerRelacion_sorteo(sorteoID:int,relacion:int,cb:Function):void {
        sql.auto_premiar_venta.run({sorteoID:sorteo.sorteoID,relacion:relacion},function (ventas:SQLResult):void {
            if (ventas.data) {
              botPendiente[sorteoID] = ventas.data[0]
              execute(cb,null,ventas.data[0])
            } else execute(cb,'No hay ventas suficientes para calcular premio')
          })
      }
		}
    public function notificarPremiacion (s:Sorteo, ganador:Object):void {
      var configBot: Object = Loteria.setting.premios.bot[ganador.operadora]
      if (!configBot) {
        Loteria.console.error('PREMIOBOT:',s.sorteo, 'Configuracion de endpoint para bot no encontrado')
        return;
      }
	  var reg:RegExp = /(\d{1,2})(:\d{2} )*(\w{1,2})/gi
	  var hora:* = reg.exec(s.descripcion)
	  hora = hora[3]=="PM"?int(hora[1])+12:hora[1]
      var numGanador:String =  ganador.numeroTexto
      //notificar a animalitos
      var req:URLRequest= new URLRequest('http://149.56.3.225:3000/cambiar')
      req.method = URLRequestMethod.POST
      var headerToken:URLRequestHeader = new URLRequestHeader("token",configBot.token)
      var headerType:URLRequestHeader = new URLRequestHeader("Content-Type","application/json")
      var data:Object= new Object
      data.fecha = s.fecha,
      data.animalito = numGanador
      data.sorteo = (hora).toString()
      data.juego = configBot.juego
      req.requestHeaders = [headerType ,headerToken]
      req.data = JSON.stringify(data)
      var loader:URLLoader = new URLLoader()
      loader.addEventListener(Event.COMPLETE,function (event:Event):void {
        var msg:String = StringUtil.format("PREMIO PROGRAMADO CONFIRMADO\nSORTEO: {0}\nGANADOR: {1}\nRESPUESTA API: {2}",
          s.descripcion, numGanador, event.currentTarget.data)
        WS.telegram("premio_bot",{
          fase: "confirmado",
          operadora: ganador.operadora,
          sorteo: s.descripcion,
          sorteo_id: s.sorteoID,
          ganador: numGanador,
          msg: msg
        })
        Loteria.console.log("PREMIOBOT",s.descripcion,event.currentTarget.data)
      })
      loader.addEventListener(IOErrorEvent.IO_ERROR,function (event:IOErrorEvent):void {
        var msg:String = StringUtil.format("ERROR AL PROGRAMAR PREMIO\nSORTEO: {0}\nRESPUESTA API: {1}",
          s.descripcion, event.currentTarget.data)
        WS.telegram("premio_bot",{
          fase: "error",
          operadora: ganador.operadora,
          sorteo: s.descripcion,
          sorteo_id: s.sorteoID,
          msg: msg
        })
        Loteria.console.error("PREMIOBOT",s.descripcion,event.currentTarget.data)
      })
      loader.load(req)
    }
    public function bot_lista(operadora:int,cb:Function):void {
      sql.bot_lista.run({operadora:operadora},cb)
    }
    public function bot_nuevo(operadora:int,sorteo:int, relacion:int, fecha:String, usuario:Admin,cb:Function):void {
      //TODO validar que el usuario tiene privilegios sobre el sorteo
	  var registro:Object = {
      sorteo: operadora,
      sorteoID: sorteo,
      relacion: relacion,
      adminID: usuario.adminID,
      creado: new Date().toLocaleString(),
      fecha:fecha
     }
      sql.bot_nuevo.run(registro,function (r:SQLResult):void {
          registro.botID = r.lastInsertRowID
          execute(cb,null,registro)
        },function (e:SQLError):void {
          execute(cb,e)
        })
    }
    public function bot_remover(botID:int,adminID:int,cb:Function):void {
      sql.bot_remover.run({botID:botID,adminID:adminID},cb)
    }
	}
}