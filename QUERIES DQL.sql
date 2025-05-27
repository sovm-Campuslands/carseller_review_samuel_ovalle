-- 
-- 1RA CONSULTA: Nomina de los Empleados
-- 

SELECT 
    s.DIRECCION AS Sucursal, -- Nombre de la sucursal donde trabaja el empleado.
    a.NOMBRE AS Area, -- Área a la que pertenece el empleado.
    c.NOMBRE AS Cargo, -- Cargo específico del empleado.
    e.ID AS ID_Empleado, -- Identificador único del empleado.
    CONCAT(e.NOMBRE, ' ', e.APELLIDO) AS Full_Name, -- Nombre completo del empleado.
    e.TELEFONO, -- Teléfono del empleado.
    e.EMAIL, -- Correo electrónico del empleado.
    e.SALARIO_BASE, -- Salario base del empleado.
    -- Suma de todos los devengados (bonos, horas extras, etc.)
    SUM(CASE WHEN con.TIPO = 'DEVENGADO' THEN con.MONTO ELSE 0 END) AS Total_Devengados, 
    -- Suma de todas las deducciones (descuentos, sanciones, etc.)
    SUM(CASE WHEN con.TIPO = 'DEDUCCION' THEN -con.MONTO ELSE 0 END) AS Total_Deducciones, 
    -- Cálculo del salario final del empleado después de deducciones y devengados.
    e.SALARIO_BASE 
        + SUM(CASE WHEN con.TIPO = 'DEVENGADO' THEN con.MONTO ELSE 0 END) 
        + SUM(CASE WHEN con.TIPO = 'DEDUCCION' THEN -con.MONTO ELSE 0 END) AS Total_a_Pagar 
FROM EMPLEADO e
JOIN AREA a ON e.AREA_ID = a.ID -- Relaciona el empleado con su área.
JOIN SUCURSAL s ON e.SUCURSAL_ID = s.ID -- Relaciona el empleado con su sucursal.
JOIN CARGO c ON e.CARGO_ID = c.ID -- Relaciona el empleado con su cargo.
LEFT JOIN NOMINA n ON e.ID = n.EMPLEADO_ID -- Relaciona el empleado con su nómina.
LEFT JOIN CONCEPTO con ON n.ID = con.NOMINA_ID -- Relaciona la nómina con los conceptos de pago.

GROUP BY s.DIRECCION, a.NOMBRE, c.NOMBRE, e.ID, e.NOMBRE, e.APELLIDO, e.TELEFONO, e.EMAIL, e.SALARIO_BASE
ORDER BY s.DIRECCION, a.NOMBRE, c.NOMBRE, e.ID;

-- 
-- 2DA CONSULTA: Lista de empleados x Sucursal y Area. 
-- 

SELECT 
    s.DIRECCION AS Sucursal,
    a.NOMBRE AS Area,
    COUNT(e.ID) AS Total_Empleados
FROM EMPLEADO e
JOIN SUCURSAL s ON e.SUCURSAL_ID = s.ID
JOIN AREA a ON e.AREA_ID = a.ID
GROUP BY s.DIRECCION, a.NOMBRE
ORDER BY s.DIRECCION, a.NOMBRE;

-- 
-- 3RA CONSULTA: Novedades por empleado en rango de fecha Agrupado por Sucursal.
-- 

SELECT 
   s.DIRECCION AS Sucursal,
   e.ID AS ID_Empleado,
   CONCAT(e.NOMBRE, ' ', e.APELLIDO) AS Full_Name,
   e.TELEFONO,
   e.EMAIL,
   n.FECHA AS Fecha_Novedad,
   n.DESCRIPCION AS Detalle_Novedad,
   n.JUSTIFICACION
FROM NOVEDADES n
JOIN EMPLEADO e ON n.NOMINA_ID = e.ID
JOIN SUCURSAL s ON e.SUCURSAL_ID = s.ID
WHERE n.FECHA BETWEEN '2023-01-01' AND '2025-12-31'
ORDER BY s.DIRECCION, n.FECHA;

-- 
-- 4TA Consulta: Nomina total x Area y Sucursal.
--
 
SELECT 
	s.DIRECCION AS Sucursal,
    a.NOMBRE AS Area,
    SUM(e.SALARIO_BASE) AS Salario_Total,
    COALESCE(SUM(CASE WHEN c.TIPO = 'DEVENGADO' THEN c.MONTO ELSE 0 END), 0) AS Total_Devengados,
    COALESCE(SUM(CASE WHEN c.TIPO = 'DEDUCCION' THEN c.MONTO ELSE 0 END), 0) AS Total_Deducciones,
    SUM(e.SALARIO_BASE) + 
    COALESCE(SUM(CASE WHEN c.TIPO = 'DEVENGADO' THEN c.MONTO ELSE 0 END), 0) - 
    COALESCE(SUM(CASE WHEN c.TIPO = 'DEDUCCION' THEN c.MONTO ELSE 0 END), 0) AS Nomina_Final
FROM EMPLEADO e
JOIN AREA a ON e.AREA_ID = a.ID
JOIN SUCURSAL s ON e.SUCURSAL_ID = s.ID
LEFT JOIN NOMINA n ON e.ID = n.EMPLEADO_ID
LEFT JOIN CONCEPTO c ON n.ID = c.NOMINA_ID
GROUP BY s.DIRECCION, a.NOMBRE
ORDER BY s.DIRECCION, a.NOMBRE;

 