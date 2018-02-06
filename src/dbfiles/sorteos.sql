--sorteo
SELECT * FROM vt.sorteos WHERE sorteoID = :sorteoID
--sorteos
SELECT * FROM sorteos
--sorteos_fecha
SELECT * FROM vt.sorteos WHERE fecha = :fecha ORDER BY cierra
--sorteos_fecha_taq
SELECT sorteoID, descripcion, fecha, abierta, abre, cierra, ganador, sorteos.sorteo FROM vt.sorteos 
JOIN (SELECT * FROM (SELECT * FROM us.taquillas_sorteo 
 WHERE (taquillas_sorteo.banca = :banca OR taquillas_sorteo.banca = 0) AND (taquillas_sorteo.taquilla = :taquilla OR taquillas_sorteo.taquilla = 0) ORDER BY taquilla ASC, banca ASC, ID ASC) GROUP BY sorteo ) as taquillas 
ON taquillas.sorteo = sorteos.sorteo 
WHERE sorteos.fecha = :fecha AND taquillas.publico = 1
--sorteos_dia
SELECT * FROM vt.sorteos WHERE fecha = :dia AND abierta = true ORDER BY abre
--sorteos_fecha_lista
SELECT sorteoID,sorteos.descripcion,sorteos.sorteo,numeros.numero g,numeros.descripcion gn FROM vt.sorteos 
LEFT JOIN numeros ON numeros.elementoID = sorteos.ganador 
WHERE fecha = :lista ORDER BY sorteos.sorteo, cierra
--sorteos_fecha_lista_admin
SELECT sorteoID,sorteos.descripcion,sorteos.sorteo,abierta,numeros.numero g,numeros.descripcion gn FROM vt.sorteos 
LEFT JOIN numeros ON numeros.elementoID = sorteos.ganador JOIN admins_meta ON admins_meta.valor = sorteos.sorteo 
WHERE fecha = :lista AND adminID = :adminID ORDER BY sorteos.sorteo, cierra
--sorteos_fecha_nombres
SELECT sorteoID,descripcion,sorteo FROM vt.sorteos WHERE fecha = :nombres ORDER BY sorteos.sorteo, sorteoID
--sorteos_fecha_agrupado
SELECT descripcion, sorteo FROM vt.sorteos WHERE fecha = :gfecha GROUP BY sorteo
--nuevo
INSERT INTO vt.sorteos (descripcion,fecha,abre,cierra,abierta,sorteo) VALUES (:descripcion,:fecha,:abre,:cierra,:abierta,:sorteo)
--remover
DELETE FROM vt.sorteos WHERE sorteoID = :sorteoID
--editar
UPDATE vt.sorteos SET abierta = :abierta WHERE sorteoID = :sorteo
--premio
SELECT sorteoID,descripcion,ganador FROM vt.sorteos WHERE sorteoID = :sorteoID
--presorteos
SELECT * FROM pre_sorteos ORDER BY sorteo, sorteoID
--presorteo_nuevo
INSERT INTO pre_sorteos (descripcion,inicio,final,sorteo) VALUES (:descripcion,:inicio,:final,:sorteo)
--presorteo_remover
DELETE FROM pre_sorteos WHERE sorteoID = :sorteoID
--publicar
INSERT INTO us.taquillas_sorteo (taquilla,banca,sorteo,publico) VALUES (:taquillaID,:bancaID,:sorteo,:publico)
--publicos
SELECT ID,taquilla,sorteo,publico FROM us.taquillas_sorteo WHERE banca = :bancaID
--remover_publico
DELETE FROM us.taquillas_sorteo WHERE ID = :id AND banca = :bancaID
--editar_publico
UPDATE us.taquillas_sorteo SET publico = :publico WHERE ID = :id AND banca = :bancaID
--usuario_publico
SELECT sorteoID, nombre FROM us.usuario_sorteos JOIN main.sorteos ON usuario_sorteos.sorteo = sorteos.sorteoID WHERE (usuarioID = :usuarioID OR usuarioID = 0)
--fecha_usuario
SELECT sorteos.sorteoID, sorteos.sorteo, sorteos.descripcion, cierra, abierta, ganador, numeros.numero g, numeros.descripcion gn 
FROM vt.sorteos 
JOIN us.usuario_sorteos ON sorteos.sorteo = usuario_sorteos.sorteo 
LEFT JOIN main.numeros ON sorteos.ganador = numeros.elementoID 
WHERE fecha = :fecha AND (usuarioID = :usuarioID OR usuarioID = 0) 
ORDER BY sorteos.sorteo, sorteos.cierra
--lista_usuario
SELECT sorteos.sorteoID, sorteos.descripcion, numeros.numero g, numeros.descripcion gn, cierra, abierta
FROM vt.sorteos 
JOIN us.usuario_sorteos ON sorteos.sorteo = usuario_sorteos.sorteo
LEFT JOIN main.numeros ON sorteos.ganador = numeros.elementoID 
WHERE fecha = :lista AND (usuarioID = :usuarioID OR usuarioID = 0) 
ORDER BY sorteos.sorteo, sorteos.cierra
--end