DROP DATABASE IF EXISTS veterinaria;
CREATE DATABASE veterinaria
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE veterinaria;

CREATE TABLE cliente (
    cedula VARCHAR(20) NOT NULL,
    nombre VARCHAR(80) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    PRIMARY KEY (cedula),
    CONSTRAINT chk_cliente_datos
        CHECK (cedula <> '' AND nombre <> '' AND telefono <> '')
) ENGINE = InnoDB;

CREATE TABLE mascota (
    codigo VARCHAR(15) NOT NULL,
    nombre VARCHAR(80) NOT NULL,
    especie ENUM('PERRO', 'GATO', 'OTRO') NOT NULL,
    edad INT NOT NULL,
    cedula_cliente VARCHAR(20) NOT NULL,
    PRIMARY KEY (codigo),
    CONSTRAINT fk_mascota_cliente
        FOREIGN KEY (cedula_cliente)
        REFERENCES cliente (cedula)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT chk_mascota_datos
        CHECK (codigo <> '' AND nombre <> '' AND edad BETWEEN 0 AND 40)
) ENGINE = InnoDB;

INSERT INTO cliente (cedula, nombre, telefono) VALUES
    ('101110111', 'Ana Mora', '88881111'),
    ('202220222', 'Luis Solis', '87772222');

INSERT INTO mascota (codigo, nombre, especie, edad, cedula_cliente) VALUES
    ('M01', 'Luna', 'GATO', 3, '101110111'),
    ('M02', 'Rocky', 'PERRO', 5, '202220222'),
    ('M03', 'Nina', 'PERRO', 1, '101110111');

DELIMITER //

CREATE PROCEDURE sp_listar_clientes()
SQL SECURITY DEFINER
BEGIN
    SELECT cedula, nombre, telefono
    FROM cliente
    ORDER BY cedula;
END//

CREATE PROCEDURE sp_insertar_cliente(
    IN p_cedula VARCHAR(20),
    IN p_nombre VARCHAR(80),
    IN p_telefono VARCHAR(20)
)
SQL SECURITY DEFINER
BEGIN
    IF EXISTS (SELECT 1 FROM cliente WHERE cedula = p_cedula) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ya existe un cliente con esa cedula';
    END IF;

    INSERT INTO cliente (cedula, nombre, telefono)
    VALUES (p_cedula, p_nombre, p_telefono);
END//

CREATE PROCEDURE sp_listar_mascotas()
SQL SECURITY DEFINER
BEGIN
    SELECT codigo, nombre, especie, edad, cedula_cliente
    FROM mascota
    ORDER BY codigo;
END//

CREATE PROCEDURE sp_insertar_mascota(
    IN p_codigo VARCHAR(15),
    IN p_nombre VARCHAR(80),
    IN p_especie ENUM('PERRO', 'GATO', 'OTRO'),
    IN p_edad INT,
    IN p_cedula_cliente VARCHAR(20)
)
SQL SECURITY DEFINER
BEGIN
    IF EXISTS (SELECT 1 FROM mascota WHERE codigo = p_codigo) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Ya existe una mascota con ese codigo';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM cliente WHERE cedula = p_cedula_cliente) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No existe el cliente dueño';
    END IF;

    INSERT INTO mascota (codigo, nombre, especie, edad, cedula_cliente)
    VALUES (p_codigo, p_nombre, p_especie, p_edad, p_cedula_cliente);
END//

CREATE PROCEDURE sp_actualizar_mascota(
    IN p_codigo VARCHAR(15),
    IN p_nombre VARCHAR(80),
    IN p_especie ENUM('PERRO', 'GATO', 'OTRO'),
    IN p_edad INT,
    IN p_cedula_cliente VARCHAR(20)
)
SQL SECURITY DEFINER
BEGIN
    IF NOT EXISTS (SELECT 1 FROM mascota WHERE codigo = p_codigo) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No existe la mascota que desea actualizar';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM cliente WHERE cedula = p_cedula_cliente) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No existe el cliente dueño';
    END IF;

    UPDATE mascota
    SET nombre = p_nombre,
        especie = p_especie,
        edad = p_edad,
        cedula_cliente = p_cedula_cliente
    WHERE codigo = p_codigo;
END//

CREATE PROCEDURE sp_eliminar_mascota(
    IN p_codigo VARCHAR(15)
)
SQL SECURITY DEFINER
BEGIN
    IF NOT EXISTS (SELECT 1 FROM mascota WHERE codigo = p_codigo) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No existe la mascota que desea eliminar';
    END IF;

    DELETE FROM mascota
    WHERE codigo = p_codigo;
END//

CREATE PROCEDURE sp_listar_mascotas_con_dueno()
SQL SECURITY DEFINER
BEGIN
    SELECT m.codigo,
           m.nombre,
           m.especie,
           m.edad,
           m.cedula_cliente,
           c.nombre AS nombre_cliente
    FROM mascota AS m
    INNER JOIN cliente AS c ON c.cedula = m.cedula_cliente
    ORDER BY m.codigo;
END//

DELIMITER ;
