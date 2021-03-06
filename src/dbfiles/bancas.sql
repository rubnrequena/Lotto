--login
SELECT bancaID,bancas.nombre,bancas.usuario,bancas.renta,bancas.usuarioID,comision,activa
FROM us.bancas 
JOIN us.usuarios ON usuarios.usuarioID = bancas.usuarioID
WHERE bancas.usuario = :us AND bancas.clave = :cl AND usuarios.activo >= 1
--banca_activa
SELECT activa, usuarios.activo uact FROM bancas 
JOIN us.usuarios ON usuarios.usuarioID = bancas.usuarioID 
JOIN us.comer_usuario ON usuarios.usuarioID = comer_usuario.uid
WHERE bancaID = :gID 
	AND activa = 1 AND usuarios.activo = 3 
	AND (SELECT activo FROM us.usuarios WHERE usuarioID = cID) = 3
--meta
SELECT mt.metaID metaID, meta_info.campo campo, mt.bancaID, CAST(valor AS INTEGER) valor 
	FROM (SELECT * FROM us.meta 
	WHERE (usuarioID = 0 OR usuarioID = :usuarioID) AND (bancaID = 0 OR bancaID = :bancaID) 
	ORDER BY metaID) AS mt JOIN us.meta_info ON meta_info.metaID = mt.campoID 
GROUP BY campoID
--editar
UPDATE us.bancas SET usuario = :usuario, nombre = :nombre, comision = :comision, participacion = :participacion WHERE bancaID = :bancaID
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
INSERT INTO us.bancas (usuarioID,nombre,activa,usuario,clave,renta,comision,creacion,participacion) VALUES (:usuarioID,:nombre,:activa,:usuario,:clave,:renta,:comision,:creacion,:participacion)
--nombres
SELECT bancaID, nombre FROM us.bancas
--nombres_usuario
SELECT bancaID, nombre FROM us.bancas WHERE usuarioID = :usuarioID
--sql_sorteos_dia
SELECT sorteos.sorteoID, descripcion, cierra, ganador, SUM(monto) monto, SUM(premio) premio 
FROM us.sorteos LEFT JOIN (SELECT * FROM us.elementos WHERE anulado = 0) as elementos ON sorteos.sorteoID = elementos.sorteoID 
WHERE sorteos.fecha = :fecha 
GROUP BY sorteos.sorteoID
--relacion_pago_consulta
SELECT * FROM relacion_pago WHERE bancaID = :bancaID AND sorteo = :sorteo
--relacion_pago_nuevo
INSERT INTO relacion_pago (bancaID,taquillaID,sorteo,valor) VALUES (:bancaID,0,:sorteo,:valor)
--relacion_pago_editar
UPDATE relacion_pago SET valor = :valor WHERE relacionID = :relacion
--transferir
UPDATE bancas SET usuarioID = :uID WHERE bancaID = :bID