--2e1dd9aed9c21e58f649de33fc56c006
SELECT sorteos.nombre operadora, 
  reportes.fecha,COALESCE(taquillas_comision.comision,taquillas.comision)*0.01 cb,
  ROUND(SUM(jugada),2) jg, ROUND(SUM(premio),2) pr, ROUND(SUM(jugada*COALESCE(taquillas_comision.comision,taquillas.comision)*0.01),2) cm
FROM vt.reportes
JOIN us.taquillas ON taquillas.taquillaID = reportes.taquillaID 
JOIN us.comer_usuario ON comer_usuario.uID = taquillas.usuarioID
JOIN vt.sorteos ON vt.sorteos.sorteoID = reportes.sorteoID 
JOIN main.sorteos ON main.sorteos.sorteoID = vt.sorteos.sorteo
LEFT JOIN taquillas_comision ON taquillas_comision.taquillaID = reportes.taquillaID AND taquillas_comision.sorteo = sorteos.sorteo
WHERE reportes.fecha BETWEEN :inicio AND :fin AND reportes.taquillaID = :taquillaID
GROUP BY sorteos.sorteo
ORDER BY sorteos.nombre ASC