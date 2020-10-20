--comercializadoras
SELECT * FROM us.usuarios WHERE tipo = 2
--login
SELECT usuarioID,usuario,nombre,tipo,activo,renta,comision,participacion,contacto FROM us.usuarios WHERE (tipo = 2 OR tipo = 3) AND usuario = :us AND clave = :cl
--usuarios
SELECT usuarioID,usuario,clave,activo,registrado,nombre,tipo,renta,comision,participacion FROM comer_usuario JOIN usuarios ON usuarios.usuarioID = comer_usuario.uID WHERE cID = :usuarioID
--link
INSERT INTO comer_usuario (cID,uID) VALUES (:cID,:uID);