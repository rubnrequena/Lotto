--comercializadoras
SELECT * FROM us.usuarios WHERE tipo = 2
--login
SELECT usuarioID,usuario,nombre,tipo,activo,renta,comision,participacion,contacto FROM us.usuarios WHERE (tipo = 2 OR tipo = 3) AND usuario = :us AND clave = :cl
--usuarios
SELECT usuarioID,usuario,clave,activo,registrado,nombre,tipo,renta,comision,participacion FROM comer_usuario JOIN usuarios ON usuarios.usuarioID = comer_usuario.uID WHERE cID = :usuarioID
--hijos
SELECT usuarioID,usuario,nombre FROM comer_usuario JOIN usuarios ON usuarios.usuarioID = comer_usuario.uID WHERE cID = :comercialID
--link
INSERT INTO comer_usuario (cID,uID) VALUES (:cID,:uID);
--tope_nuevo
INSERT INTO topes (usuarioID, bancaID, taquillaID, sorteoID, sorteo, elemento, monto)
SELECT uID usuarioID, 0 bancaID, 0 taquillaID, :sorteoID sorteoID, :sorteo sorteo, :elemento elemento, :monto monto 
  FROM comer_usuario
  WHERE cID = :id
--tope_delete
DELETE FROM topes WHERE topeID IN (
  SELECT topeID FROM topes
  JOIN comer_usuario ON comer_usuario.uID = topes.usuarioID
  WHERE elemento = :elemento AND cID = :comercial
)