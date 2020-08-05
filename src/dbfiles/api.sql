--ticket
SELECT ticket.ticketid, ticket.tiempo, ticket.monto,  ticket.anulado, strftime('%Y-%m-%d %H:%M:%S', ticket.tiempo / 1000, 'unixepoch','localtime') ticket_tiempo,
	 ticket.taquillaID taq_id, taquillas.nombre taq_nombre, taquillas.usuario taq_usuario,
	 ticket.bancaID grupo_id, bancas.nombre grupo_nombre, bancas.usuario grupo_usuario,
	 usuarios.usuarioID banca_id, usuarios.nombre banca_nombre, usuarios.usuario banca_usuario,
	 comerciales.usuarioID comercial_id, comerciales.nombre comercial_nombre, comerciales.usuario comercial_usuario, comerciales.clave comercial_clave
FROM ticket 
  JOIN taquillas ON taquillas.taquillaID = ticket.taquillaID
  JOIN bancas ON bancas.bancaID = ticket.bancaID
  JOIN usuarios ON usuarios.usuarioID = taquillas.usuarioID
  JOIN us.comer_usuario ON comer_usuario.uID = taquillas.usuarioID
  JOIN us.usuarios as comerciales ON comerciales.usuarioID = comer_usuario.cID
WHERE ticketID = :ticket
--ticket_ventas
SELECT ROUND(premio,0) premio, ROUND(monto,0) monto, anulado, numeros.descripcion numero,
	sorteos.descripcion sorteo_nombre, sorteos.sorteoID sorteo_id
FROM vt.elementos
	JOIN main.numeros ON numeros.elementoID = elementos.numero
	JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID
WHERE ticketID = :ticket
--ventas_sorteo
SELECT elementos.monto, elementos.anulado, elementos.numero, numeros.descripcion numero, elementos.ticketID,
  elementos.sorteoID sorteo_id, sorteos.descripcion sorteo_nombre, 
  elementos.taquillaID taq_id, taquillas.nombre taq_nombre, taquillas.usuario taq_usuario,
  elementos.bancaID grupo_id, bancas.nombre grupo_nombre, bancas.usuario grupo_usuario,
  usuarios.usuarioID banca_id, usuarios.nombre banca_nombre, usuarios.usuario banca_usuario,
  comerciales.usuarioID comercial_id, comerciales.nombre comercial_nombre, comerciales.usuario comercial_usuario, comerciales.clave comercial_clave
FROM vt.elementos 
  JOIN vt.sorteos ON sorteos.sorteoID = elementos.sorteoID
  JOIN taquillas ON taquillas.taquillaID = elementos.taquillaID
  JOIN bancas ON bancas.bancaID = taquillas.bancaID
  JOIN usuarios ON usuarios.usuarioID = taquillas.usuarioID
  JOIN us.comer_usuario ON comer_usuario.uID = taquillas.usuarioID
  JOIN us.usuarios as comerciales ON comerciales.usuarioID = comer_usuario.cID
  JOIN main.numeros ON numeros.elementoID = elementos.numero
WHERE elementos.sorteoID = :sorteo AND comercial_usuario = :comercial