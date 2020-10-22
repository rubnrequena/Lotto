--sql_parametros
SELECT * FROM usuarios WHERE usuarioID = :padreID
--fdd29ed26e0da352612bdc8ca918226d
SELECT nombre, taquillaid FROM taquillas WHERE usuarioID = :usuario ORDER BY nombre ASC
--f3714ca394491659136687c08635958b
SELECT usuarioID, sorteos.nombre nombre, sorteos.sorteoID operadora,
	coalesce(comision.valor, comision)*100 comision,
	coalesce(participacion.valor, participacion)*100 participacion,
	CASE WHEN comision.valor IS NULL THEN 1 ELSE 0 END cmpred,
	CASE WHEN participacion.valor IS NULL THEN 1 ELSE 0 END partpred
FROM comer_usuario
  JOIN usuarios ON comer_usuario.uID = usuarios.usuarioID
  LEFT JOIN us.comisiones as comision 
	ON comer_usuario.uID = comision.usuario 
	   AND comision.rol = 3  AND comision.tipo = 0
  LEFT JOIN us.comisiones as participacion 
	ON comer_usuario.uID = participacion.usuario
	   AND participacion.rol = 3 AND participacion.tipo = 1
  JOIN sorteos ON sorteos.sorteoid = comision.operadora
WHERE comer_usuario.cID = :padreID and usuarioid = :usuarioID
--533a1c25611f9f98d8d405f302e7ed71
SELECT usuarioID, sorteos.nombre nombre, sorteos.sorteoID operadora,
	coalesce(comision.valor, comision)*100 comision,
	coalesce(participacion.valor, participacion)*100 participacion,
	CASE WHEN comision.valor IS NULL THEN 1 ELSE 0 END cmpred,
	CASE WHEN participacion.valor IS NULL THEN 1 ELSE 0 END partpred
FROM comer_usuario
  JOIN usuarios ON comer_usuario.uID = usuarios.usuarioID
  LEFT JOIN us.comisiones as comision 
	ON comer_usuario.uID = comision.usuario 
	   AND comision.operadora = :operadora AND comision.rol = 3  AND comision.tipo = 0
  LEFT JOIN us.comisiones as participacion 
	ON comer_usuario.uID = participacion.usuario
	   AND participacion.operadora = :operadora AND participacion.rol = 3 AND participacion.tipo = 1
  JOIN sorteos ON sorteos.sorteoid = comision.operadora
WHERE comer_usuario.cID = :padreID and usuarioid = :usuarioID