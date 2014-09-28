--
-- Estructura de tabla para la tabla demos_config
--

CREATE TABLE IF NOT EXISTS demos_config (
  id_config int NOT NULL ,
  id_admin_rel int NOT NULL,
  driver varchar(50) NOT NULL,
  dominio varchar(100) NOT NULL,
  bd_name varchar(50) NOT NULL,
  bd_puerto varchar(20) NOT NULL,
  bd_user varchar(50) NOT NULL,
  bd_passw varchar(50) NOT NULL,
  host_ip varchar(100) DEFAULT NULL,
  host_puerto varchar(20) DEFAULT NULL,
  host_user varchar(50) DEFAULT NULL,
  host_passw varchar(50) DEFAULT NULL,
  date_add int NOT NULL,
  date_update int NOT NULL,
  PRIMARY KEY (id_config)
);

--
-- Volcar la base de datos para la tabla demos_config
--

INSERT INTO demos_config (id_config, id_admin_rel, driver, dominio, bd_name, bd_puerto, bd_user, bd_passw, host_ip, host_puerto, host_user, host_passw, date_add, date_update) VALUES
(1, 1, 'MySQL', '127.0.0.1', 'demo_ocio', '3306', 'root', '', '', '', '', '', 0, 0),
(2, 1, 'MySQL', '127.0.0.1', 'demo_deportes', '3306', 'root', '', '', '', '', '', 0, 0),
(3, 1, 'MySQL', '127.0.0.1', 'demo_tienda', '3306', 'root', '', '', '', '', '', 0, 0),
(4, 1, 'MySQL', '127.0.0.1', 'demo_colegio', '3306', 'root', '', '', '', '', '', 0, 0),
(5, 1, 'MySQL', '127.0.0.1', 'demo_comerciales', '3306', 'root', '', NULL, NULL, NULL, NULL, 0, 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla demos_users_config
--

CREATE TABLE IF NOT EXISTS demos_users_config (
  email varchar(150) NOT NULL,
  id_config_rel int NOT NULL,
  nombre_apellidos varchar(150) NOT NULL,
  user_login varchar(50) NOT NULL,
  user_passw varchar(50) NOT NULL,
  date_add int NOT NULL,
  date_update int NOT NULL,
  PRIMARY KEY (email,id_config_rel)
);

--
-- Volcar la base de datos para la tabla demos_users_config
--


select * from demos_users_config
select * from demos_config

