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