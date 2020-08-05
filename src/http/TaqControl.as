package http
{
  import models.ModelHUB;
  import flash.net.URLVariables;
  import vos.Taquilla;
  import vos.Sesion;
  import flash.utils.getTimer;
  import vos.Sorteo;
  import helpers.LTool;
  import helpers.bm.EGrupo;
  import vos.Tope;
  import helpers.DateFormat;
  import flash.data.SQLResult;
  import helpers.ObjectUtil;

  public class TaqControl extends ActionController
    {
      private var _model:ModelHUB;
      
      public function TaqControl(model:ModelHUB)
      {
        super('/taq');
        _model = model;
      }
      
      public function login(params:URLVariables,res:Function):void
      {
        var usuario:String = params.u;
        var clave:String = params.c;
        _model.taquillas.httpLogin(usuario,clave,function (msg:Object):void {
          res(responseSuccess(msg));
        })
      }
      public function ping(params:URLVariables):String  {
        var sesion:String = params.sesion;
        if (!_model.taquillas.httpSesion(sesion)) return responseSuccess({error:"sesion_invalida",msg:"Su sesion ha expirado"});
        else  return responseSuccess({"msg":"Sesion valida"})
      }
      public var _topes:Vector.<Tope>;
      public var _cache:Array;
      public var invalidos:Array;
      public function venta (params:URLVariables,res:Function):void {
        var sesion:Sesion = _model.taquillas.httpSesion(params.sesion);
        var _taquilla:Taquilla = sesion.taquilla;
        if (!sesion) res(responseSuccess({error:"sesion_invalida",msg:"Su sesion ha expirado"}));
        else {
          var _sorteo:Sorteo; _topes:Vector.<Tope>;
          var ventasUsuario:EGrupo; var ventasBanca:EGrupo;
          _cache = sesion.meta.cache;

          var _ventas:Array = JSON.parse(params.venta) as Array;
          if (_ventas.length==0) { // validar ventas
            res(responseSuccess({error:"ventas_vacias",msg:"Debe proporcionar al menos una venta"})); return;
          }
          var t:int = getTimer();
          //validar duplicados
          _ventas.sortOn(["sorteoID","numero"],Array.NUMERIC);
          var i:int, j:int;
          for (i = _ventas.length-1; i > 0; i--) {
            if (_ventas[i].sorteoID==_ventas[i-1].sorteoID && _ventas[i].numero==_ventas[i-1].numero) {
              _ventas[i-1].monto += _ventas[i].monto;
              _ventas.removeAt(i);
            }
          }
          
          //validar disponibilidad de sorteos
          var invalidos:Array = [];
          for (i = 0; i < _ventas.length; i++) {
            _sorteo = _model.mSorteos.getSorteo(_ventas[i].sorteoID);
            if (_sorteo && _sorteo.abierta && _sorteo.cierra>_model.ahora) continue;
            else invalidos.push(_ventas[i].sorteoID);
          }
          
          if (invalidos.length>0) {
            res(responseSuccess({error:"sorteos_invalidos"}));
          } else {
            //Loteria.console.log("SORTEOS VALIDADOS",getTimer()-t,"ms");
            //validar topes
            t=getTimer();				
            //seleccionar validacion de topes				
            var debeValidar:Boolean;
            debeValidar = LTool.exist("compartido",2,_topes);
            if (debeValidar) validarTopeUsuario();
            else {
              debeValidar = LTool.exist("compartido",1,_topes);
              if (debeValidar) validarTopeBanca();
              else validarTopeTaquilla();
            }
            //Loteria.console.log("VENTA VALIDADA EN",getTimer()-t+"ms");
            
            function validarTopeUsuario():void {
              ventasUsuario = _model.uMan.findGrupo(_taquilla.usuarioID);
              if (ventasUsuario) {
                validarTopes(_ventas,ventasUsuario.sorteos,2);						
                validarTopeBanca();
              } else {
                _model.ventas.ventas_elementos({
                  fecha:DateFormat.format(_model.ahora),
                  usuarioID:_taquilla.usuarioID
                },function (ventas_banca:SQLResult):void {
                  ventasUsuario = _model.uMan.registrar(_taquilla.usuarioID,ventas_banca.data);
                  validarTopeUsuario();
                });
              }	
            }
            function validarTopeBanca():void {
              ventasBanca = _model.bMan.findGrupo(_taquilla.bancaID);
              if (ventasBanca) {
                validarTopes(_ventas,ventasBanca.sorteos,1);
                validarTopeTaquilla();
              } else {
                _model.ventas.ventas_elementos({
                  fecha:DateFormat.format(_model.ahora),
                  bancaID:_taquilla.bancaID
                },function (ventas_banca:SQLResult):void {
                  ventasBanca = _model.bMan.registrar(_taquilla.bancaID,ventas_banca.data);
                  validarTopeBanca();
                });
              }
            }
            function validarTopeTaquilla():void {
              if (_cache) validarTaquilla();
              else {
                _model.ventas.ventas_elementos({
                  fecha:DateFormat.format(_model.ahora),
                  taquillaID:_taquilla.taquillaID
                },function (ventas_taquilla:SQLResult):void {
                  _cache = ventas_taquilla.data || [];
                  validarTaquilla();
                });
              }
            }
            
            function validarTaquilla ():void {
              validarTopes(_ventas,_cache,0);
              if (invalidos.length>0) { // VENTA INVALIDA
              res(responseSuccess({error:"taquilla_excedio_tope"}));
              } else { // VENTA VALIDA
                //Loteria.console.log('Recibiendo venta, ',JSON.stringify(m.data));
                realizarVenta();
              }
              invalidos.length = 0;
            }
            function realizarVenta ():void {
              _model.ventas.venta(_ventas,_taquilla,function (ticket:Object,ventasID:Array,ids:Array):void {
                ticket.hora = DateFormat.format(ticket.tiempo,DateFormat.i18n["default"]);
                var data:Object = {
                  tk:ticket,
                  vt:ventasID
                }
                t=getTimer();
                merge(_cache);
                if (ventasBanca) merge(ventasBanca.sorteos);
                if (ventasUsuario) merge(ventasUsuario.sorteos);
                //measure(m.command+" #"+ticket.ticketID+" | "+ids.join(","));
                //m.data.format = "print";
                
                
                res(responseSuccess(data));
              });
            }
            function merge (cache:Array):void {
              var a:Object,b:Object; var f:Boolean;
              var vl:int = _ventas.length, cl:int = cache?cache.length:0;
              for (j = 0; j < vl; j++) {
                f=false;
                a = _ventas[j];
                for (i = 0; i < cl; i++) {
                  b = cache[i];
                  if (a.sorteoID==b.sorteoID && a.numero==b.numero) {
                    f=true;
                    b.monto += a.monto;
                    break;
                  }
                }
                if (f==false) {
                  if (cache) cache.push(ObjectUtil.copy(a));
                  else cache = [ObjectUtil.copy(a)];
                }
              }
            }
          }
        }
        
      }
      private function validarTopes (porJugar:Array,jugadas:Array,compartido:int=0):void {
			var tope:Tope; var sorteo:Sorteo;
			var i:int, j:int, index:int, tpl:int = _topes.length; 
			var mj:Object; var validar:Boolean=false;
			for each (var venta:Object in porJugar) {
				tope=null;
				sorteo = _model.mSorteos.getSorteo(venta.sorteoID);
				for (i = 0; i < tpl; i++) {
					if ((_topes[i].sorteo==sorteo.sorteo || _topes[i].sorteo==0) && (_topes[i].sorteoID==venta.sorteoID || _topes[i].sorteoID==0) && compartido==_topes[i].compartido) {
						if ((_topes[i].elemento==venta.numero || _topes[i].elemento==0) && compartido==_topes[i].compartido) {
							tope = _topes[i]; break;
						}
					}
				}
				if (tope) {
					tope = _topes[i];
					if (jugadas && jugadas.length>0) {						
						for (i = 0; i < jugadas.length; i++) {
							mj = jugadas[i];
							if (mj.sorteoID==venta.sorteoID && mj.numero==venta.numero) {
								var sum:Number = mj.monto+venta.monto;
								if (sum>tope.monto) { // sumatoria de jugada exede tope
									sum = tope.monto-mj.monto>0?tope.monto-mj.monto:0;
									addInvalido({s:venta.sorteoID,n:venta.numero,td:sum});
									break;
								}
							} else if (venta.monto > tope.monto) { // jugada exede tope
								venta.monto = tope.monto; //170521
								addInvalido({s:venta.sorteoID,n:venta.numero,td:tope.monto});
								break;
							}
						}
					} else if (venta.monto > tope.monto) { // jugada exede tope
						venta.monto = tope.monto; //170521
						addInvalido({s:venta.sorteoID,n:venta.numero,td:tope.monto});
					}
				}
			}
		}
		
		private function addInvalido (item:Object):void {
			var l:int = invalidos.length;
			for (var i:int = l-1; i > -1; i--) {
				if (invalidos[i].n==item.n) {
					if (invalidos[i].td>item.td) {
						invalidos.removeAt(i); break;
					} else return;
				}
			}			
			invalidos.push(item);
		}
    }
}