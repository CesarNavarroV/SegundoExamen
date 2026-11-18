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
