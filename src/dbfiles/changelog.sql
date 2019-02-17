--19.01.24
CREATE TABLE "suspender" ( `sID` TEXT, `limite` INTEGER, `minMonto` INTEGER, `resID` TEXT, PRIMARY KEY(`sID`) )
CREATE TABLE taquillas_comision (
	comID INTEGER PRIMARY KEY AUTOINCREMENT, 
	sorteo INTEGER,comision NUMERIC,
	taquillaID INTEGER
	)