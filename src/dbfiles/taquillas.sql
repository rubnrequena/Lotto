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
SELECT comID, sorteo, taquillas_comision.comision comision, taquillas_comision.taquillaID, taquillas_comision.grupoID, taquillas_comision.bancaID,
		bancas.nombre grupo, taquillas.nombre taquilla
 FROM taquillas_comision 
	LEFT JOIN us.bancas ON bancas.bancaID = taquillas_comision.grupoID
	LEFT JOIN us.taquillas ON taquillas.taquillaID = taquillas_comision.taquillaID
WHERE taquillas_comision.bancaID = :bancaID
--comision_nueva
INSERT INTO taquillas_comision (sorteo,comision,taquillaID,grupoID,bancaID) VALUES (:sorteo,:comision,:taquillaID,:grupoID,:bancaID)
--comision_remover
DELETE FROM taquillas_comision WHERE bancaID = :bancaID AND comID = :comID