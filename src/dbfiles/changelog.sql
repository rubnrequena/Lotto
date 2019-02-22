--19.01.24
CREATE TABLE "suspender" ( `sID` TEXT, `limite` INTEGER, `minMonto` INTEGER, `resID` TEXT, PRIMARY KEY(`sID`) )
CREATE TABLE taquillas_comision (
	comID INTEGER PRIMARY KEY AUTOINCREMENT, 
	sorteo INTEGER,comision NUMERIC,
	taquillaID INTEGER
)
--19.02.20
* fix: módulo preferencias~
+ up: premiar ruletactiva desde circuitodelasuerte
--19.02.22
+ [OP,CM] AutoSuspender
+ [OP] Balance: ocultar suspendidos, boton suspender, enlazar los pagos con los cobros
+ [OP] Crear registro $config para configuraciones locales persistentes
+ [CM] Eliminar reportes de pago duplicados o invalidos.
--19.02.XX
- Balance: hacer los botones un menu flotante con modals.
- Modulo verificar resultados de sorteos
- Enviar los tickets por SMS
- BUG: corregir lista de taquillas en TOPES, no mostrar las inactivas
- [CM] Eliminar reportes de pago duplicados o invalidos.
- BUG: reporte de taquillas en SU