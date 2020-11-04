--sql_parametros
SELECT * FROM usuarios WHERE usuarioID = :padreID
--fdd29ed26e0da352612bdc8ca918226d
SELECT nombre, taquillaid FROM taquillas WHERE usuarioID = :usuario ORDER BY nombre ASC
--f3714ca394491659136687c08635958b
SELECT nombre, operadoraID operadora, usuarioID usuario, 
  COALESCE((SELECT valor FROM comisiones WHERE usuario = usuarioID and rol = 3 AND tipo = 0 AND operadora = operadoraID), pcm)*100 comision,
  COALESCE((SELECT valor FROM comisiones WHERE usuario = usuarioID and rol = 3 AND tipo = 1 AND operadora = operadoraID), ppt)*100 participacion
FROM (
  SELECT operadora operadoraID, comisiones.usuario usuarioID, sorteos.nombre, 
  usuarios.comision pcm, usuarios.participacion ppt
  FROM comisiones 
  JOIN usuarios ON usuarios.usuarioID = comisiones.usuario
  JOIN sorteos ON sorteos.sorteoID = comisiones.operadora
  JOIN comer_usuario ON comer_usuario.uID = usuarios.usuarioID
  WHERE rol = 3 AND comisiones.usuario = :usuarioID and comer_usuario.cID = :padreID
  GROUP BY operadora
)
ORDER BY nombre
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
ORDER BY sorteos.nombre
--comisiones_grupo_pred
SELECT comision*100 comision, participacion*100 participacion FROM bancas WHERE bancaID = :grupoID
--comisiones_grupo
SELECT nombre, operadoraID operadora, usuarioID usuario, 
  COALESCE((SELECT valor FROM comisiones WHERE usuario = usuarioID and rol = 2 AND tipo = 0 AND operadora = operadoraID), pcm)*100 comision,
  COALESCE((SELECT valor FROM comisiones WHERE usuario = usuarioID and rol = 2 AND tipo = 1 AND operadora = operadoraID), ppt)*100 participacion
FROM (
  SELECT operadora operadoraID, comisiones.usuario usuarioID, sorteos.nombre, 
  bancas.comision pcm, bancas.participacion ppt, bancas.participacion 
  FROM comisiones 
  JOIN bancas ON bancas.bancaID = comisiones.usuario
  JOIN sorteos ON sorteos.sorteoID = comisiones.operadora
  JOIN comer_usuario ON comer_usuario.uID = bancas.usuarioID
  WHERE rol = 2 AND comisiones.usuario = :grupoID and comer_usuario.cID = :padreID
  GROUP BY operadora
)
ORDER BY nombre
--comision_grupos
SELECT bancaID, nombre,
	coalesce(comision.valor, comision)*100 comision,
	coalesce(participacion.valor, participacion)*100 participacion,
	CASE WHEN comision.valor IS NULL THEN 1 ELSE 0 END cmpred,
	CASE WHEN participacion.valor IS NULL THEN 1 ELSE 0 END partpred
FROM bancas
  LEFT JOIN us.comisiones as comision 
	ON bancas.bancaID = comision.usuario 
	  AND comision.operadora = :operadora AND comision.rol = 2  AND comision.tipo = 0
  LEFT JOIN us.comisiones as participacion 
	ON bancas.bancaID = participacion.usuario
	  AND participacion.operadora = :operadora AND participacion.rol = 2 AND participacion.tipo = 1
WHERE bancas.usuarioID = :usuario
--comisiones_usuario
SELECT * FROM taquillas_comision WHERE bancaid = :padreID and grupoid = 0 and taquillaid = 0
--lista_grupos_min
SELECT nombre, bancaID FROM bancas WHERE usuarioID = :usuarioID
--numero_id
SELECT elementoID, descripcion FROM numeros WHERE numero = :numero and sorteo = :sorteo