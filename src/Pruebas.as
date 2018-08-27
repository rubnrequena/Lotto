package
{
	import flash.filesystem.File;
	
	import feathers.themes.MinimalDesktopTheme;
	
	import helpers.PremioWeb;
	import helpers.Premio_LaGranjita;
	import helpers.Premio_LotoSelva;
	import helpers.Premio_LottoActivo;
	import helpers.Premio_LottoLeon;
	import helpers.Premio_MiniLottico;
	import helpers.Premio_RuletAnimal;
	import helpers.Premio_RuletaOriente;
	
	import models.ModelHUB;
	
	import starling.display.Sprite;
	import starling.events.Event;
	
	public class Pruebas extends Sprite
	{
		private var model:ModelHUB;
		private var sorteos:Array;
		public function Pruebas() {
			super();
			
			addEventListener(Event.ADDED_TO_STAGE,onAdded);
			
		}
		
		private function onAdded():void
		{
			new MinimalDesktopTheme();
			
			//model = new ModelHUB();			
			
			Loteria.console = new Console();
			Loteria.console.width = stage.stageWidth;
			Loteria.console.height = stage.stageHeight;
			addChild(Loteria.console);
			
			/*model = new ModelHUB();
			model.addEventListener(Event.READY,onReady);*/
			
			test_sorteos();
		}
		
		
		private function test_sorteos():void {
			sorteos = ruleta_animal;
			pr = new helpers.Premio_RuletAnimal; 
			//pr.addEventListener(Event.COMPLETE,onComplete);
			pr.addEventListener(Event.READY,onReady);
			
			hoy.date -= 1;
			pr.buscar(sorteos[pri],hoy);
		}
		
		private function onComplete(e:Event,n:String):void
		{
			Loteria.console.log("GANADOR:",n);
		}
		
		private function onReady(e:Event,p:PremioWeb):void
		{
			Loteria.console.log("GANADOR:",p.srt);
			p.dispose();
			if (++pri<sorteos.length) {				
				pr = new helpers.Premio_RuletAnimal; 
				pr.addEventListener(Event.COMPLETE,onComplete);
				pr.addEventListener(Event.READY,onReady);
				pr.buscar(sorteos[pri],hoy);
			}
		}
		private var pr:PremioWeb;
		private var pri:int;
		private var hoy:Date = new Date;
		
		private var mini:Array = [
			/*"MINI LOTTICO 10:00 AM",
			"MINI LOTTICO 11:00 AM",
			"MINI LOTTICO 12:00 PM",
			"MINI LOTTICO 1:00 PM",
			"MINI LOTTICO 3:00 PM",
			"MINI LOTTICO 4:00 PM",
			"MINI LOTTICO 5:00 PM",*/
			"MINI LOTTICO 6:00 PM",
			"MINI LOTTICO 7:00 PM",
			"MINI LOTTICO 8:00 PM"
		];
		
		private var lotto:Array = [
			"LOTTO ACTIVO 9AM",
			"LOTTO ACTIVO 10AM",
			"LOTTO ACTIVO 11AM",
			"LOTTO ACTIVO 12PM",
			"LOTTO ACTIVO 1PM",
			"LOTTO ACTIVO 3PM",
			"LOTTO ACTIVO 4PM",
			"LOTTO ACTIVO 5PM",
			"LOTTO ACTIVO 6PM",
			"LOTTO ACTIVO 7PM"
		];
		
		private var oriente:Array = [
			"RULETA ACT ORIENTE 09:00 AM",
			"RULETA ACT ORIENTE 10:00 AM",
			"RULETA ACT ORIENTE 11:00 AM",
			"RULETA ACT ORIENTE 12:00 PM",
			"RULETA ACT ORIENTE 01:00 PM",
			"RULETA ACT ORIENTE 03:00 PM",
			"RULETA ACT ORIENTE 04:00 PM",
			"RULETA ACT ORIENTE 05:00 PM",
			"RULETA ACT ORIENTE 06:00 PM",
			"RULETA ACT ORIENTE 07:00 PM"
		];
		
		private var reyanz:Array = [
			"REY ANZOATEGUI 10:45 AM",
			"REY ANZOATEGUI 11:45 AM",
			"REY ANZOATEGUI 12:45 PM",
			"REY ANZOATEGUI 3:45 PM",
			"REY ANZOATEGUI 4:45 PM",
			"REY ANZOATEGUI 5:45 PM",
			"REY ANZOATEGUI 6:45 PM",
			"REY ANZOATEGUI 7:45 PM"
		];
		
		private var granjita:Array = [
			"LA GRANJITA 9:00 AM",
			"LA GRANJITA 10:00 AM",
			"LA GRANJITA 11:00 AM",
			"LA GRANJITA 12:00 PM",
			"LA GRANJITA 1:00 PM",
			"LA GRANJITA 2:00 PM",
			"LA GRANJITA 3:00 PM",
			"LA GRANJITA 4:00 PM",
			"LA GRANJITA 5:00 PM",
			"LA GRANJITA 6:00 PM",
			"LA GRANJITA 7:00 PM"
		];
		
		private var selva:Array = [
			"LOTO SELVA 09:00 AM",
			"LOTO SELVA 10:00 AM",
			"LOTO SELVA 11:00 AM",
			"LOTO SELVA 12:00 M",
			"LOTO SELVA 01:00 PM",
			"LOTO SELVA 04:00 PM",
			"LOTO SELVA 05:00 PM",
			"LOTO SELVA 06:00 PM",
			"LOTO SELVA 07:00 PM",
			"LOTO SELVA 08:00 PM"
		];
		
		private var gran:Array = [
			"GRAN RULETA 09:30 AM",
			"GRAN RULETA 10:30 AM",
			"GRAN RULETA 11:30 AM",
			"GRAN RULETA 12:30 PM",
			"GRAN RULETA 01:30 PM",
			"GRAN RULETA 03:30 PM",
			"GRAN RULETA 04:30 PM",
			"GRAN RULETA 05:30 PM",
			"GRAN RULETA 06:30 PM",
			"GRAN RULETA 07:30 PM"
		];
		
		private var fruta:Array = [
			"FRUTA ACTIVA 9AM",
			"FRUTA ACTIVA 10AM",
			"FRUTA ACTIVA 11AM",
			"FRUTA ACTIVA 12PM",
			"FRUTA ACTIVA 5PM"/*,
			"TU FRUTA ACTIVA 4PM",
			"TU FRUTA ACTIVA 5PM",
			"TU FRUTA ACTIVA 6PM",
			"TU FRUTA ACTIVA 7PM"*/
		];
		
		private var lotto_leon:Array = [
			"LOTTO LEON 10:15 AM",
			"LOTTO LEON 11:15 AM",
			"LOTTO LEON 12:15 AM",
			"LOTTO LEON 1:15 PM",
			"LOTTO LEON 2:15 PM",
			"LOTTO LEON 3:15 PM",
			"LOTTO LEON 4:15 PM",
			"LOTTO LEON 5:15 PM",
			"LOTTO LEON 6:15 PM",
			"LOTTO LEON 7:15 PM",
		]
		
		private var ruleta_animal:Array = [
			"RULETA ANIMAL 9AM",
			"RULETA ANIMAL 10AM",
			"RULETA ANIMAL 11AM",
			"RULETA ANIMAL 12M",
			"RULETA ANIMAL 1PM",
			"RULETA ANIMAL 3PM",
			"RULETA ANIMAL 4PM",
			"RULETA ANIMAL 5PM",
			"RULETA ANIMAL 6PM",
			"RULETA ANIMAL 7PM",
			"RULETA ANIMAL 8PM"
		];
		private var file:File;
	}
}