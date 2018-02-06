--login
SELECT * FROM "main"."admins" 
WHERE usuario = :usr AND clave = :clv
--sorteos_admin
SELECT sorteoID, nombre  FROM admins_meta 
JOIN main.sorteos ON admins_meta.valor = sorteos.sorteoID 
WHERE adminID = :adminID
--sorteos
SELECT sorteoID, descripcion 
FROM main.sorteos
--sorteos_dia
SELECT sorteos.fecha, sorteos.sorteoID, sorteos.descripcion, sorteos.ganador, elementos.bancaID, elementos.taquillaID, SUM(monto) jugado, SUM(premio) premio, bancas.renta, bancas.comision, taquillas.comision 
FROM elementos 
JOIN numeros ON elementos.numero = numeros.elementoID 
JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID 
JOIN us.taquillas ON taquillas.taquillaID = elementos.taquillaID 
JOIN us.bancas ON bancas.bancaID = elementos.bancaID 
WHERE sorteos.fecha = :fecha AND elementos.anulado = 0 
GROUP BY elementos.sorteoID 
ORDER BY elementos.sorteoID, elementos.bancaID ASC, elementos.taquillaID ASC
--numeros_admin
SELECT elementoID, numero, descripcion, numeros.sorteo FROM numeros JOIN admins_meta ON admins_meta.valor = numeros.sorteo WHERE adminID = :adminID ORDER BY numeros.sorteo, numeros.numero
--usuario_reg_sorteo
INSERT INTO us.usuario_sorteos (usuarioID,sorteo) VALUES (:usuarioID,:sorteo)
--usuario_del_sorteo
DELETE FROM us.usuario_sorteos WHERE sid = :sid AND sorteo = :sorteo
--usuario_sorteos
SELECT sid, usuarios.usuarioID, usuarios.nombre, usuarios.usuario, sorteos.nombre
FROM usuario_sorteos 
LEFT JOIN us.usuarios ON usuarios.usuarioID = usuario_sorteos.usuarioID 
JOIN main.sorteos ON sorteos.sorteoID = usuario_sorteos.sorteo
ORDER BY usuario_sorteos.sorteo
--usuario_sorteo_id
SELECT sid, usuarios.usuarioID, usuarios.nombre, usuarios.usuario, sorteos.nombre
FROM usuario_sorteos 
JOIN us.usuarios ON usuarios.usuarioID = usuario_sorteos.usuarioID 
JOIN main.sorteos ON sorteos.sorteoID = usuario_sorteos.sorteo
WHERE sorteo = :sorteo
ORDER BY usuario_sorteos.sorteo