--topes_banca
SELECT creado, topes.usuarioID, topes.bancaID, topeID, monto, topes.taquillaID, taquillas.nombre "taquilla", sorteos.descripcion, topes.sorteo, topes.sorteoID, numeros.descripcion elemento, compartido 
FROM us.topes 
LEFT JOIN us.taquillas ON taquillas.taquillaID = topes.taquillaID 
LEFT JOIN vt.sorteos ON sorteos.sorteoID = topes.sorteoID 
LEFT JOIN numeros ON numeros.elementoID = topes.elemento 
WHERE (topes.bancaID = :bancaID OR topes.bancaID = 0) AND (topes.usuarioID = :usuarioID OR topes.usuarioID = 0) 
ORDER BY compartido DESC, elemento DESC, topes.sorteoID DESC, topes.taquillaID DESC, topes.bancaID DESC, topes.sorteo DESC, topeID DESC
--topes_usuario
SELECT creado, topes.usuarioID, topes.bancaID, topeID, monto, topes.taquillaID, taquillas.nombre "taquilla", sorteos.descripcion, topes.sorteo, topes.sorteoID, numeros.descripcion elemento, compartido 
FROM us.topes 
LEFT JOIN us.taquillas ON taquillas.taquillaID = topes.taquillaID 
LEFT JOIN vt.sorteos ON sorteos.sorteoID = topes.sorteoID 
LEFT JOIN numeros ON numeros.elementoID = topes.elemento 
WHERE (topes.usuarioID = :usuarioID OR topes.usuarioID = 0) 
ORDER BY compartido DESC, elemento DESC, topes.sorteoID DESC, topes.taquillaID DESC, topes.bancaID DESC, topes.sorteo DESC, topeID DESC