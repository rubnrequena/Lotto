--sql_parametros
SELECT * FROM usuarios WHERE usuarioID = :padreID
--fdd29ed26e0da352612bdc8ca918226d
SELECT nombre, taquillaid FROM taquillas WHERE usuarioID = :usuario ORDER BY nombre ASC