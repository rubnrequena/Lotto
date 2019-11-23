--usuarios
SELECT * FROM us.usuarios
--usuario_id
SELECT * FROM us.usuarios WHERE usuarioID = :id
--usuario_user
SELECT * FROM us.usuarios WHERE usuario = :usuario
--usuario_login
SELECT usuarioID,usuario,nombre,tipo,activo,renta,comision,participacion FROM us.usuarios 
JOIN comer_usuario ON usuarios.usuarioID = comer_usuario.uid
WHERE tipo = 1 AND usuario = :us AND clave = :cl 
AND (SELECT activo FROM us.usuarios WHERE usuarioID = cID) = 3
--usuario_nuevo
INSERT INTO us.usuarios (usuario,clave,nombre,tipo,registrado,activo,renta,comision,participacion) VALUES (:usuario,:clave,:nombre,:tipo,:registrado,:activo,:renta,:comision,:participacion)
--usuario_editar
UPDATE us.usuarios SET usuario = :usuario, nombre = :nombre, clave = :clave, renta = :renta, comision = :comision, participacion = :participacion, contacto = :contacto WHERE usuarioID = :usuarioID
--usuario_clave
UPDATE us.usuarios SET clave = :clave WHERE usuarioID = :usuarioID
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
--usuarios_comer
SELECT usuarioID,usuario,clave,activo,registrado,nombre,tipo,renta,comision,participacion FROM comer_usuario JOIN usuarios ON usuarios.usuarioID = comer_usuario.uID WHERE cID = :comercial
--listaSuspender
select sID, substr(sid,1,1) c, trim(sid,"cug") id, minMonto, limite, nombre from suspender
JOIN usuarios ON usuarios.usuarioID = id where (c = "c" OR c = "u") AND resID = :resID
UNION
select sID, substr(sid,1,1) c, trim(sid,"cug") id, minMonto, limite,nombre from suspender
JOIN bancas ON bancas.bancaID = id where c = "g" AND resID = :resID
--suspender_nuevo
INSERT INTO suspender (sID,limite,minMonto,resID) VALUES (:sID,:limite,:minMonto,:resID)
--suspender_remover
DELETE FROM suspender WHERE sID = :sID AND resID = :resID
--usuario_comer
select * from comer_usuario
join us.usuarios ON usuarios.usuarioID = comer_usuario.cid
WHERE uid = :uid;
--mensajes_destinos
SELECT * FROM (
	SELECT 0 bID, "C:"||nombre nombre, "c"||cID usID FROM comer_usuario JOIN usuarios ON usuarios.usuarioID = comer_usuario.cID WHERE uID = :uID
	UNION
	SELECT bancaID bID, "G:"||nombre nombre, "g"||bancaID usID FROM bancas WHERE usuarioID = :uID
	UNION
	SELECT bancaID bID, "T:"||nombre nombre, "t"||taquillaID usID FROM taquillas WHERE usuarioID = :uID
) ORDER BY bID
--bancaID
SELECT nombre, bancaID uID, "g"||bancaID usID, contacto from us.bancas WHERE bancaID = :id
--taquillaID
SELECT nombre, taquillaID uID, "t"||taquillaID usID, contacto from us.taquillas WHERE taquillaID = :id
--usuarioID
SELECT nombre, usuarioID uID, "u"||usuarioID usID, contacto from us.usuarios WHERE usuarioID = :id
--comercialID
SELECT nombre, usuarioID uID, "c"||usuarioID usID, contacto from us.usuarios WHERE usuarioID = :id