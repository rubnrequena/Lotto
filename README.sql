--20.07.01
ALTER TABLE us.bancas ADD COLUMN participacion REAL;
ALTER TABLE us.relacion_pago ADD COLUMN usuarioID INTEGER DEFAULT 0;
CREATE TABLE "autoPremiar" (
	"botID"		INTEGER PRIMARY KEY AUTOINCREMENT,
	"sorteo"	INTEGER,
	"sorteoID"	INTEGER NOT NULL,
	"adminID"	INTEGER NOT NULL,
	"relacion"	REAL NOT NULL,
	"creado"	TEXT,
	"fecha"		TEXT
);
--20.07.10
INSERT INTO "us"."meta" ("usuarioID", "bancaID", "campoID", "valor") VALUES ( '0', '-1', '7', '1');
INSERT INTO "us"."meta_info" ("metaID", "campo") VALUES ('7', 'mod_tope_banca');