--usuarios
SELECT * FROM us.usuarios WHERE tipo = 1
--usuario_id
SELECT * FROM us.usuarios WHERE usuarioID = :id
--usuario_user
SELECT * FROM us.usuarios WHERE usuario = :usuario
--usuario_login
SELECT usuarioID,usuario,nombre,tipo,activo,renta,comision,participacion FROM us.usuarios WHERE tipo = 1 AND usuario = :us AND clave = :cl
--usuario_nuevo
INSERT INTO us.usuarios (usuario,clave,nombre,tipo,registrado,activo,renta,comision,participacion) VALUES (:usuario,:clave,:nombre,:tipo,:registrado,:activo,:renta,:comision,:participacion)
--usuario_editar
UPDATE us.usuarios SET usuario = :usuario, nombre = :nombre, clave = :clave, renta = :renta WHERE usuarioID = :usuarioID
--usuario_activar
UPDATE us.usuarios SET activo = :activo WHERE usuarioID = :usuarioID
--permisos
SELECT meta.usuarioID, bancas.nombre, metaID, campoID, CAST(meta.valor AS INTEGER) valor FROM us.meta LEFT JOIN us.bancas ON bancas.bancaID = meta.bancaID WHERE (meta.usuarioID = 0 OR meta.usuarioID = :usuarioID) GROUP BY meta.bancaID, meta.campoID ORDER BY meta.bancaID
--meta_nuevo
INSERT INTO us.meta (usuarioID,bancaID,campoID,valor) VALUES (:usuarioID, :bancaID, :campoID, :valor)
--permiso_nuevo
UPDATE us.meta SET valor = :valor WHERE metaID = :meta AND usuarioID = :usuarioID
--permiso_remove
DELETE FROM us.meta WHERE metaID = :meta AND usuarioID = :usuarioID