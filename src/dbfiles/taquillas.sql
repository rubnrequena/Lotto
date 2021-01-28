--taquilla_login
SELECT taquillaID, taquillas.usuario, taquillas.usuarioID, taquillas.bancaID, taquillas.nombre, taquillas.comision, taquillas.activa, fingerprint, fingerlock,
	usuarios.activo+bancas.activa+taquillas.activa estaActiva
FROM us.taquillas 
JOIN us.bancas ON bancas.bancaID = taquillas.bancaID 
JOIN us.usuarios ON usuarios.usuarioID = taquillas.usuarioID 
JOIN comer_usuario ON usuarios.usuarioID = comer_usuario.uid
WHERE taquillas.usuario = :usuario 
	AND taquillas.clave = :clave 
	AND taquillas.papelera = 0
--taquilla_activa
SELECT * FROM taquillas 
JOIN us.bancas ON bancas.bancaID = taquillas.bancaID 
JOIN us.usuarios ON usuarios.usuarioID = taquillas.usuarioID 
JOIN us.comer_usuario ON usuarios.usuarioID = comer_usuario.uid
WHERE taquillaID = :tID 
	AND taquillas.activa = 1 AND bancas.activa >= 1 AND usuarios.activo >= 1 
	AND (SELECT activo FROM us.usuarios WHERE usuarioID = cID) = 3
--taquillaID
SELECT * FROM us.taquillas WHERE taquillaID = :
--comision_premiar
SELECT * FROM taquillas_comision WHERE taquillaID = :taquillaID
--comisiones_taquilla
SELECT * FROM taquillas_comision WHERE taquillaID = :taquillaID
--comisiones_grupo
SELECT * FROM taquillas_comision 
WHERE bancaID = :bancaID AND (grupoID = :grupoID OR grupoID = 0) AND taquillaID = 0 
ORDER BY taquillas_comision.taquillaID
--comisiones_banca
SELECT comID, sorteo, taquillas_comision.comision comision, taquillas_comision.grupoID, bancas.nombre grupo, sorteos.nombre operadora
 FROM taquillas_comision 
	LEFT JOIN us.bancas ON bancas.bancaID = taquillas_comision.grupoID
 JOIN main.sorteos ON sorteos.sorteoID = sorteo 
 WHERE taquillas_comision.bancaID = :bancaID and taquillas_comision.taquillaID = 0
 ORDER BY sorteo ASC, grupoid
--comision_nueva
INSERT INTO taquillas_comision (sorteo,comision,taquillaID,grupoID,bancaID) VALUES (:sorteo,:comision,:taquillaID,:grupoID,:bancaID)
--comision_remover
DELETE FROM taquillas_comision WHERE comID = :comID
--metas
SELECT taquillaID, campo,valor FROM (SELECT * FROM taquillas_meta 
	WHERE bancaID = :bancaID AND (taquillaID = :taquillaID OR taquillaID = 0)
	ORDER BY taquillaID ASC)
	GROUP BY campo
--meta_remover_banca
DELETE FROM taquillas_meta WHERE metaID = :metaID
--meta_registrar_banca
INSERT INTO taquillas_meta (taquillaID, bancaID, campo, valor) VALUES (:taquillaID, :bancaID, :campo, :valor)
--meta_actualizar_banca
UPDATE taquillas_meta SET valor = :valor WHERE metaID = :metaID
--meta_validar_existe
SELECT * FROM taquillas_meta WHERE bancaID = :bancaID AND taquillaID = 0 AND campo = :campo
--sesiones
SELECT ip, sesiones.usuario id, taquillas.usuario, taquillas.nombre, tiempo hora FROM sesiones 
INNER JOIN taquillas ON taquillas.taquillaID = sesiones.usuario
WHERE fecha = :fecha AND tipo = 1 AND taquillas.usuarioID = :bancaID
GROUP BY fecha, sesiones.usuario ORDER BY sesionID DESC