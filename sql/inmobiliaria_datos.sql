-- =====================================================
-- ESQUEMA + DATOS DE LA BASE DE DATOS inmobiliaria_db
-- Generado desde la BD online (Clever Cloud)
-- =====================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- =====================================================
-- FASE 1: TABLAS BASE (Sin dependencias)
-- =====================================================

CREATE TABLE `rol` (
    `id_rol` INT AUTO_INCREMENT PRIMARY KEY,
    `nombre` VARCHAR(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `usuario` (
    `id_usuario` INT AUTO_INCREMENT PRIMARY KEY,
    `correo` VARCHAR(100) NOT NULL,
    `contrasena` VARCHAR(255) NOT NULL,
    `salt` VARCHAR(255) DEFAULT NULL,
    `estado` ENUM('Activa','Inactiva') DEFAULT 'Activa',
    UNIQUE KEY `correo` (`correo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `inmobiliaria` (
    `id_inmobiliaria` INT AUTO_INCREMENT PRIMARY KEY,
    `nit` VARCHAR(20) NOT NULL UNIQUE,
    `nombre_empresa` VARCHAR(100) NOT NULL,
    `telefono` VARCHAR(20),
    `correo_contacto` VARCHAR(100)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `ciudad` (
    `id_ciudad` INT AUTO_INCREMENT PRIMARY KEY,
    `nombre_ciudad` VARCHAR(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `tipo_propiedad` (
    `id_tipo` INT AUTO_INCREMENT PRIMARY KEY,
    `nombre` VARCHAR(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `caracteristica` (
    `id_caracteristica` INT AUTO_INCREMENT PRIMARY KEY,
    `nombre` VARCHAR(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- FASE 2: TABLAS CON DEPENDENCIAS DE 1er NIVEL
-- =====================================================

CREATE TABLE `perfil` (
    `id_perfil` INT AUTO_INCREMENT PRIMARY KEY,
    `id_usuario` INT NOT NULL UNIQUE,
    `nombres` VARCHAR(100) NOT NULL,
    `apellidos` VARCHAR(100) NOT NULL,
    `documento` VARCHAR(20) NOT NULL UNIQUE,
    `telefono` VARCHAR(20),
    `direccion` VARCHAR(150),
    `foto` VARCHAR(255),
    FOREIGN KEY (`id_usuario`) REFERENCES `usuario`(`id_usuario`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `usuario_rol` (
    `id_usuario` INT NOT NULL,
    `id_rol` INT NOT NULL,
    `fecha_asignacion` DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id_usuario`, `id_rol`),
    FOREIGN KEY (`id_usuario`) REFERENCES `usuario`(`id_usuario`) ON DELETE CASCADE,
    FOREIGN KEY (`id_rol`) REFERENCES `rol`(`id_rol`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `barrio` (
    `id_barrio` INT AUTO_INCREMENT PRIMARY KEY,
    `id_ciudad` INT NOT NULL,
    `nombre_barrio` VARCHAR(100) NOT NULL,
    `estrato` INT NOT NULL,
    FOREIGN KEY (`id_ciudad`) REFERENCES `ciudad`(`id_ciudad`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `auditoria` (
    `id_auditoria` INT AUTO_INCREMENT PRIMARY KEY,
    `id_usuario` INT,
    `accion_realizada` VARCHAR(255) NOT NULL,
    `fecha_hora` DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`id_usuario`) REFERENCES `usuario`(`id_usuario`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- FASE 3: TABLA CENTRAL DEL NEGOCIO (Propiedad)
-- =====================================================

CREATE TABLE `propiedad` (
    `id_propiedad` INT AUTO_INCREMENT PRIMARY KEY,
    `matricula_inmobiliaria` VARCHAR(50) NOT NULL UNIQUE,
    `id_inmobiliaria` INT NOT NULL,
    `id_barrio` INT NOT NULL,
    `id_tipo` INT NOT NULL,
    `titulo_publicacion` VARCHAR(150) NOT NULL,
    `descripcion` TEXT,
    `precio` DECIMAL(15, 2) NOT NULL,
    `estado` ENUM('Disponible','Alquilado','Vendido','De_baja') DEFAULT 'Disponible',
    FOREIGN KEY (`id_inmobiliaria`) REFERENCES `inmobiliaria`(`id_inmobiliaria`) ON DELETE CASCADE,
    FOREIGN KEY (`id_barrio`) REFERENCES `barrio`(`id_barrio`) ON DELETE RESTRICT,
    FOREIGN KEY (`id_tipo`) REFERENCES `tipo_propiedad`(`id_tipo`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- FASE 4: TABLAS CON DEPENDENCIAS DE 2do NIVEL
-- =====================================================

CREATE TABLE `imagen_propiedad` (
    `id_imagen` INT AUTO_INCREMENT PRIMARY KEY,
    `id_propiedad` INT NOT NULL,
    `url_ruta_imagen` VARCHAR(255) NOT NULL,
    FOREIGN KEY (`id_propiedad`) REFERENCES `propiedad`(`id_propiedad`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `propiedad_caracteristica` (
    `id_propiedad` INT NOT NULL,
    `id_caracteristica` INT NOT NULL,
    `cantidad` INT DEFAULT 1,
    PRIMARY KEY (`id_propiedad`, `id_caracteristica`),
    FOREIGN KEY (`id_propiedad`) REFERENCES `propiedad`(`id_propiedad`) ON DELETE CASCADE,
    FOREIGN KEY (`id_caracteristica`) REFERENCES `caracteristica`(`id_caracteristica`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `cita` (
    `id_cita` INT AUTO_INCREMENT PRIMARY KEY,
    `id_propiedad` INT NOT NULL,
    `id_usuario` INT NOT NULL,
    `fecha_hora` DATETIME NOT NULL,
    `estado` ENUM('Pendiente','Aprobada','Rechazada') DEFAULT 'Pendiente',
    UNIQUE (`id_propiedad`, `fecha_hora`),
    FOREIGN KEY (`id_propiedad`) REFERENCES `propiedad`(`id_propiedad`) ON DELETE CASCADE,
    FOREIGN KEY (`id_usuario`) REFERENCES `usuario`(`id_usuario`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `solicitud` (
    `id_solicitud` INT AUTO_INCREMENT PRIMARY KEY,
    `id_propiedad` INT NOT NULL,
    `id_usuario` INT NOT NULL,
    `tipo_tramite` ENUM('Compra','Arriendo') NOT NULL,
    `estado` ENUM('En revisión','Aprobada','Rechazada') DEFAULT 'En revisión',
    `fecha_solicitud` DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`id_propiedad`) REFERENCES `propiedad`(`id_propiedad`) ON DELETE CASCADE,
    FOREIGN KEY (`id_usuario`) REFERENCES `usuario`(`id_usuario`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `favorito` (
    `id_favorito` INT AUTO_INCREMENT PRIMARY KEY,
    `id_usuario` INT NOT NULL,
    `id_propiedad` INT NOT NULL,
    FOREIGN KEY (`id_usuario`) REFERENCES `usuario`(`id_usuario`) ON DELETE CASCADE,
    FOREIGN KEY (`id_propiedad`) REFERENCES `propiedad`(`id_propiedad`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE `mensaje` (
    `id_mensaje` INT AUTO_INCREMENT PRIMARY KEY,
    `id_remitente` INT NOT NULL,
    `id_destinatario` INT NOT NULL,
    `id_propiedad` INT NOT NULL,
    `contenido_texto` TEXT NOT NULL,
    `fecha_envio` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `leido` BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (`id_remitente`) REFERENCES `usuario`(`id_usuario`) ON DELETE CASCADE,
    FOREIGN KEY (`id_destinatario`) REFERENCES `usuario`(`id_usuario`) ON DELETE CASCADE,
    FOREIGN KEY (`id_propiedad`) REFERENCES `propiedad`(`id_propiedad`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- FASE 5: TABLAS CON DEPENDENCIAS DE 3er NIVEL
-- =====================================================

CREATE TABLE `documento_solicitud` (
    `id_documento` INT AUTO_INCREMENT PRIMARY KEY,
    `id_solicitud` INT NOT NULL,
    `nombre_documento` VARCHAR(100) NOT NULL,
    `ruta_archivo` VARCHAR(255) NOT NULL,
    FOREIGN KEY (`id_solicitud`) REFERENCES `solicitud`(`id_solicitud`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- DATOS
-- =====================================================

INSERT INTO `rol` (`id_rol`, `nombre`) VALUES
(1,'admin'),(2,'agente'),(3,'cliente');

INSERT INTO `usuario` (`id_usuario`, `correo`, `contrasena`, `salt`, `estado`) VALUES
(1,'agente1@inmobiliaria.com','361df6e3ebc5a33a6c57c0bc1179201260f769c1f9e807538c276369bf5b5b7c','SirNSRhWz5uHLRr5zSs5vg==','Activa'),
(2,'yanfri@gmail.com','dc6ab47486cd1ff602d20117780cd202a94a5f96a351d5dc016bf919b5e80c79','owM1Upo99XmS/fs/QeN9lw==','Activa'),
(3,'cliente1@test.com','b1464a07963e6f79f454097f2e0613a7fcde0f3a701476a72fb00ab6c6a91be0','RHYJFFNv0O+rlH3BeSQ6HA==','Activa'),
(4,'admin@test.com','323270c0b249356b73b56b29f6b32bf5e75a00c4c6b396683975a3028bd99c50','FRG24RjSkoGobB4v58p0lA==','Activa'),
(5,'nuevo@test.com','4dd3575b643a2bdb61a7cdc93037877bb1ac8f2c8ea20cd4c20df8310120bb8b','jP55ALyFWeQdoYp++cDY6w==','Activa'),
(6,'hola@gmail.com','900ddf74cbc4bba9af460570ce3459116b23819340c005c1be010c7d2730dfd4','qk21LcFGBT6HPdaEpP3Iqg==','Activa');

INSERT INTO `inmobiliaria` (`id_inmobiliaria`, `nit`, `nombre_empresa`, `telefono`, `correo_contacto`) VALUES
(1,'900123456-7','Inmobiliaria Arco Real','6012345678','contacto@arcoreal.com'),
(2,'900987654-3','Gestiones Inmobiliarias del Valle','6029876543','info@giv.com');

INSERT INTO `ciudad` (`id_ciudad`, `nombre_ciudad`) VALUES
(1,'Bogotá'),(2,'Medellín'),(3,'Cali'),(4,'Bucaramanga');

INSERT INTO `tipo_propiedad` (`id_tipo`, `nombre`) VALUES
(1,'Apartamento'),(2,'Casa'),(3,'Local Comercial'),(4,'Terreno'),(5,'Local');

INSERT INTO `caracteristica` (`id_caracteristica`, `nombre`) VALUES
(1,'Habitaciones'),(2,'Baños'),(3,'Parqueaderos'),(4,'Área (m²)'),(5,'Nivel/Piso');

INSERT INTO `perfil` (`id_perfil`, `id_usuario`, `nombres`, `apellidos`, `documento`, `telefono`, `direccion`, `foto`) VALUES
(1,3,'Carlos','Perez','1234567','3115551234','Calle 1 #2-3',NULL),
(2,2,'Camilo','Diaz','292034842','3192847130','Cra 10 #19-29','');

INSERT INTO `usuario_rol` (`id_usuario`, `id_rol`, `fecha_asignacion`) VALUES
(1,2,'2026-09-10 23:03:07'),
(2,3,'2026-09-12 12:44:00'),
(3,3,'2026-09-10 23:42:42'),
(4,1,'2026-09-10 23:42:42'),
(5,3,'2026-09-10 23:56:40'),
(6,3,'2026-09-11 00:00:49');

INSERT INTO `barrio` (`id_barrio`, `id_ciudad`, `nombre_barrio`, `estrato`) VALUES
(1,1,'Chapinero',4),(2,1,'Suba',3),(3,1,'Usaquén',5),(4,2,'El Poblado',5),(5,2,'Laureles',4),(6,3,'Granada',4),(7,3,'Peñalosa',3);

INSERT INTO `auditoria` (`id_auditoria`, `id_usuario`, `accion_realizada`, `fecha_hora`) VALUES
(1,3,'Actualizó su perfil (documento 1234567)','2026-09-10 23:42:57'),
(2,3,'Agendó cita para la propiedad 1 (2026-09-20T10:00)','2026-09-10 23:45:35'),
(3,3,'Radicó solicitud 1 (Compra) para propiedad 1','2026-09-10 23:57:57'),
(4,1,'Aprobó la cita 1','2026-09-10 23:58:03'),
(5,1,'Aprobó la solicitud 1','2026-09-10 23:58:03'),
(6,4,'Agregó ciudad al catálogo','2026-09-10 23:58:36'),
(7,4,'Agregó tipo al catálogo','2026-09-10 23:58:36'),
(8,1,'Editó la propiedad 1','2026-09-10 23:58:36'),
(9,4,'Actualizó roles/estado del usuario yanfri@gmail.com (id 2)','2026-09-12 12:44:00'),
(10,2,'Actualizó su perfil (documento 292034842)','2026-09-12 14:05:00'),
(11,2,'Radicó solicitud 2 (Arriendo) para propiedad 4','2026-09-12 14:43:43'),
(12,1,'Rechazó la solicitud 2','2026-09-12 14:44:15'),
(13,2,'Actualizó su perfil (documento 292034842)','2026-09-12 14:59:17'),
(14,2,'Agendó cita para la propiedad 4 (2026-09-15T17:59)','2026-09-12 14:59:46'),
(15,2,'Envió mensaje sobre la propiedad 4 al agente 1','2026-09-12 16:08:04'),
(16,1,'Envió mensaje sobre la propiedad 4 al cliente 2','2026-09-12 16:08:43'),
(17,1,'Aprobó la cita 3','2026-09-15 13:17:18');

INSERT INTO `propiedad` (`id_propiedad`, `matricula_inmobiliaria`, `id_inmobiliaria`, `id_barrio`, `id_tipo`, `titulo_publicacion`, `descripcion`, `precio`, `estado`) VALUES
(1,'1N-55001',1,1,1,'Apartamento actualizado','Editado',950000000.00,'Disponible'),
(2,'50C-88452',1,4,2,'Casa campestre en El Poblado','Casa de dos plantas con patio amplio y zona de asadores.',4500000000.00,'Disponible'),
(3,'50N-11204',2,6,3,'Local comercial en Granada','Local con excelente flujo peatonal, ideal para restaurante o tienda.',1200000000.00,'Disponible'),
(4,'1N-99231',1,2,1,'Apartamento acogedor en Suba','Mapa de 2 alcobas con balcón y vista a la ciudad.',250000000.00,'Disponible'),
(5,'50C-77410',2,5,2,'Casa en Laureles','Casa tradicional remodelada, 4 habitaciones y estudio.',2150000000.00,'Disponible'),
(6,'1N-109882',1,3,4,'Terreno urbanizable en Usaquén','Terreno de 1.200 m² con uso mixto aprobado.',3200000000.00,'Disponible');

INSERT INTO `imagen_propiedad` (`id_imagen`, `id_propiedad`, `url_ruta_imagen`) VALUES
(2,2,'https://images.unsplash.com/photo-1778158257064-e8603dc1105a?q=80&w=900&auto=format&fit=crop'),
(3,3,'https://images.unsplash.com/photo-1770962282626-61b2f4931bf7?q=80&w=900&auto=format&fit=crop'),
(4,4,'https://images.unsplash.com/photo-1750639258780-6883beec9efd?q=80&w=900&auto=format&fit=crop'),
(5,5,'https://images.unsplash.com/photo-1761135149034-1d0c084826db?q=80&w=900&auto=format&fit=crop'),
(6,6,'https://images.unsplash.com/photo-1773322326419-3d3a7124ca0a?q=80&w=900&auto=format&fit=crop'),
(7,1,'https://images.unsplash.com/photo-1761319914911-71b059a655d8?q=80&w=900&auto=format&fit=crop');

INSERT INTO `propiedad_caracteristica` (`id_propiedad`, `id_caracteristica`, `cantidad`) VALUES
(1,2,3),(2,1,5),(2,2,4),(2,3,2),(2,4,400),(2,5,2),(3,4,90),(3,5,1),(4,1,2),(4,2,1),(4,3,1),(4,4,68),(4,5,6),(5,1,4),(5,2,3),(5,3,1),(5,4,260),(5,5,2),(6,4,1200);

INSERT INTO `cita` (`id_cita`, `id_propiedad`, `id_usuario`, `fecha_hora`, `estado`) VALUES
(1,1,3,'2026-09-20 15:00:00','Aprobada'),
(3,4,2,'2026-09-15 22:59:00','Aprobada');

INSERT INTO `solicitud` (`id_solicitud`, `id_propiedad`, `id_usuario`, `tipo_tramite`, `estado`, `fecha_solicitud`) VALUES
(1,1,3,'Compra','Aprobada','2026-09-10 23:57:57'),
(2,4,2,'Arriendo','Rechazada','2026-09-12 14:43:43');

INSERT INTO `documento_solicitud` (`id_documento`, `id_solicitud`, `nombre_documento`, `ruta_archivo`) VALUES
(1,1,'upload_test.txt','uploads/solicitudes/1789102677242-3-upload_test.txt'),
(2,2,'prueba1.txt','uploads/solicitudes/1789242223503-2-prueba1.txt'),
(3,2,'prueba2.txt','uploads/solicitudes/1789242223504-2-prueba2.txt');

INSERT INTO `favorito` (`id_favorito`, `id_usuario`, `id_propiedad`) VALUES
(2,3,1),(3,6,1),(4,2,3);

INSERT INTO `mensaje` (`id_mensaje`, `id_remitente`, `id_destinatario`, `id_propiedad`, `contenido_texto`, `fecha_envio`, `leido`) VALUES
(7,2,1,4,'hola quiero mas informacion','2026-09-12 16:08:04',1),
(8,1,2,4,'hola, cuentame','2026-09-12 16:08:43',0);

SET FOREIGN_KEY_CHECKS = 1;
