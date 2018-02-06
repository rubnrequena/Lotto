--login
SELECT bancaID,bancas.nombre,bancas.usuario,bancas.renta,bancas.usuarioID,comision,activa
FROM us.bancas 
JOIN us.usuarios ON usuarios.usuarioID = bancas.usuarioID
WHERE bancas.usuario = :us AND bancas.clave = :cl AND usuarios.activo >= 1
--meta
SELECT mt.metaID metaID, meta_info.campo campo, CAST(valor AS INTEGER) valor 
FROM (SELECT * FROM us.meta WHERE (usuarioID = 0 OR usuarioID = :usuarioID) AND (bancaID = 0 OR bancaID = :bancaID) ORDER BY metaID) AS mt JOIN us.meta_info ON meta_info.metaID = mt.campoID 
GROUP BY campoID
--editar
UPDATE us.bancas SET usuario = :usuario, nombre = :nombre, comision = :comision WHERE bancaID = :bancaID
--activa
UPDATE us.bancas SET activa = :activa WHERE bancaID = :bancaID
--comision
UPDATE us.bancas SET comision = :comision WHERE bancaID = :bancaID
--clave
UPDATE us.bancas SET clave = :clave WHERE bancaID = :bancaID
--renta
UPDATE us.bancas SET renta = :renta WHERE bancaID = :bancaID
--papelera
UPDATE us.bancas SET papelera = :papelera WHERE bancaID = :bancaID
--bancas
SELECT * FROM us.bancas
--bancas_id
SELECT * FROM us.bancas WHERE bancaID = :id
--bancas_usuario
SELECT * FROM us.bancas WHERE usuarioID = :usuario
--banca_nueva
INSERT INTO us.bancas (usuarioID,nombre,activa,usuario,clave,renta,comision,creacion) VALUES (:usuarioID,:nombre,:activa,:usuario,:clave,:renta,:comision,:creacion)
--nombres
SELECT bancaID, nombre FROM us.bancas
--nombres_usuario
SELECT bancaID, nombre FROM us.bancas WHERE usuarioID = :usuarioID
--sql_sorteos_dia
SELECT sorteos.sorteoID, descripcion, cierra, ganador, SUM(monto) monto, SUM(premio) premio 
FROM us.sorteos LEFT JOIN (SELECT * FROM us.elementos WHERE anulado = 0) as elementos ON sorteos.sorteoID = elementos.sorteoID 
WHERE sorteos.fecha = :fecha 
GROUP BY sorteos.sorteoID