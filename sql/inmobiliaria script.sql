create database inmobiliaria_db
character set utf8mb4
collate utf8mb4_unicode_ci;

use inmobiliaria_db;
-- =================================================================
-- FASE 1: TABLAS INDEPENDIENTES (Sin llaves foráneas)
-- =================================================================

CREATE TABLE rol (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    correo VARCHAR(100) NOT NULL UNIQUE, -- Restricción UNIQUE obligatoria (Credencial)
    contrasena VARCHAR(255) NOT NULL, -- Se guardará el Hash
    estado ENUM('Activa', 'Inactiva') DEFAULT 'Activa'
);

CREATE TABLE inmobiliaria (
    id_inmobiliaria INT AUTO_INCREMENT PRIMARY KEY,
    nit VARCHAR(20) NOT NULL UNIQUE,
    nombre_empresa VARCHAR(100) NOT NULL,
    telefono VARCHAR(20),
    correo_contacto VARCHAR(100)
);

CREATE TABLE ciudad (
    id_ciudad INT AUTO_INCREMENT PRIMARY KEY,
    nombre_ciudad VARCHAR(100) NOT NULL
);

CREATE TABLE tipo_propiedad (
    id_tipo INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL -- Ej: Casa, Apartamento, Local
);

CREATE TABLE caracteristica (
    id_caracteristica INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL -- Ej: Piscina, Ascensor
);

-- =================================================================
-- FASE 2: TABLAS CON DEPENDENCIAS DE 1er NIVEL
-- =================================================================

-- Relación 1:1 con Usuario
CREATE TABLE perfil (
    id_perfil INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL UNIQUE, -- UNIQUE garantiza la relación 1:1
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    documento VARCHAR(20) NOT NULL UNIQUE,
    telefono VARCHAR(20),
    direccion VARCHAR(150),
    foto VARCHAR(255),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE
);

-- Relación N:M entre Usuario y Rol
CREATE TABLE usuario_rol (
    id_usuario INT NOT NULL,
    id_rol INT NOT NULL,
    fecha_asignacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_usuario, id_rol), -- Llave compuesta actúa como UNIQUE
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_rol) REFERENCES rol(id_rol) ON DELETE CASCADE
);

-- Nueva Tabla Agregada: Barrio (Depende de Ciudad)
CREATE TABLE barrio (
    id_barrio INT AUTO_INCREMENT PRIMARY KEY,
    id_ciudad INT NOT NULL,
    nombre_barrio VARCHAR(100) NOT NULL,
    estrato INT NOT NULL,
    FOREIGN KEY (id_ciudad) REFERENCES ciudad(id_ciudad) ON DELETE RESTRICT
);

CREATE TABLE auditoria (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    accion_realizada VARCHAR(255) NOT NULL,
    fecha_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE SET NULL
);

-- =================================================================
-- FASE 3: TABLA CENTRAL DEL NEGOCIO (Propiedad)
-- =================================================================

-- Relación 1:N desde Inmobiliaria, Barrio y Tipo
CREATE TABLE propiedad (
    id_propiedad INT AUTO_INCREMENT PRIMARY KEY,
    matricula_inmobiliaria VARCHAR(50) NOT NULL UNIQUE, -- Restricción UNIQUE obligatoria
    id_inmobiliaria INT NOT NULL,
    id_barrio INT NOT NULL,
    id_tipo INT NOT NULL,
    titulo_publicacion VARCHAR(150) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(15, 2) NOT NULL,
    estado ENUM('Disponible', 'Alquilado', 'Vendido', 'De_baja') DEFAULT 'Disponible',
    FOREIGN KEY (id_inmobiliaria) REFERENCES inmobiliaria(id_inmobiliaria) ON DELETE CASCADE,
    FOREIGN KEY (id_barrio) REFERENCES barrio(id_barrio) ON DELETE RESTRICT,
    FOREIGN KEY (id_tipo) REFERENCES tipo_propiedad(id_tipo) ON DELETE RESTRICT
);

-- =================================================================
-- FASE 4: TABLAS CON DEPENDENCIAS DE 2do NIVEL (Operaciones)
-- =================================================================

-- Relación 1:N con Propiedad
CREATE TABLE imagen_propiedad (
    id_imagen INT AUTO_INCREMENT PRIMARY KEY,
    id_propiedad INT NOT NULL,
    url_ruta_imagen VARCHAR(255) NOT NULL,
    FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad) ON DELETE CASCADE
);

-- Relación N:M entre Propiedad y Caracteristica
CREATE TABLE propiedad_caracteristica (
    id_propiedad INT NOT NULL,
    id_caracteristica INT NOT NULL,
    cantidad INT DEFAULT 1,
    PRIMARY KEY (id_propiedad, id_caracteristica),
    FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad) ON DELETE CASCADE,
    FOREIGN KEY (id_caracteristica) REFERENCES caracteristica(id_caracteristica) ON DELETE CASCADE
);

-- Relación 1:N desde Usuario (Cliente) y Propiedad
CREATE TABLE cita (
    id_cita INT AUTO_INCREMENT PRIMARY KEY,
    id_propiedad INT NOT NULL,
    id_usuario INT NOT NULL,
    fecha_hora DATETIME NOT NULL,
    estado ENUM('Pendiente', 'Aprobada', 'Rechazada') DEFAULT 'Pendiente',
    UNIQUE (id_propiedad, fecha_hora), -- Impide dos citas a la misma hora en el mismo lugar
    FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad) ON DELETE CASCADE,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE
);

CREATE TABLE solicitud (
    id_solicitud INT AUTO_INCREMENT PRIMARY KEY,
    id_propiedad INT NOT NULL,
    id_usuario INT NOT NULL,
    tipo_tramite ENUM('Compra', 'Arriendo') NOT NULL,
    estado ENUM('En revisión', 'Aprobada', 'Rechazada') DEFAULT 'En revisión',
    fecha_solicitud DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad) ON DELETE CASCADE,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE
);

CREATE TABLE favorito (
    id_favorito INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_propiedad INT NOT NULL,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad) ON DELETE CASCADE
);

-- Nueva Tabla Agregada: Mensaje (Chat de contacto)
CREATE TABLE mensaje (
    id_mensaje INT AUTO_INCREMENT PRIMARY KEY,
    id_remitente INT NOT NULL,
    id_destinatario INT NOT NULL,
    id_propiedad INT NOT NULL,
    contenido_texto TEXT NOT NULL,
    fecha_envio DATETIME DEFAULT CURRENT_TIMESTAMP,
    leido BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_remitente) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_destinatario) REFERENCES usuario(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_propiedad) REFERENCES propiedad(id_propiedad) ON DELETE CASCADE
);

-- =================================================================
-- FASE 5: TABLAS CON DEPENDENCIAS DE 3er NIVEL
-- =================================================================

-- Depende de Solicitud
CREATE TABLE documento_solicitud (
    id_documento INT AUTO_INCREMENT PRIMARY KEY,
    id_solicitud INT NOT NULL,
    nombre_documento VARCHAR(100) NOT NULL,
    ruta_archivo VARCHAR(255) NOT NULL,
    FOREIGN KEY (id_solicitud) REFERENCES solicitud(id_solicitud) ON DELETE CASCADE
);