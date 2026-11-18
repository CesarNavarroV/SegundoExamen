# Guia ejecucion

La aplicacion esta hecha para clientes y mascotas para una veterinaria. Antes tenia los datos en txt
pero ahora se migraron a MySql, ahora funciona bien, creo jeje

## Que necesita tener instalado

- IntelliJ IDEA
- MySQL Server 8
- Yo le pongo un conector, lo dejare en el repo, vas en proyect structure, modulos y metes el .jar que adjuntare.
  (A priori sirve sin eso, pero ya es un ritual cada que hago mysql y no quiero quitarlo pa ver si falla mi codigo xd)

Aqui se usa `vet_app` como usuario normal de la aplicacion.
Lo admin se hace con `root`

## base de datos

Primero abres MySQL y despues uno se conecta con el usuario admin configurado en database. 
Y desde ahi:

1. Abres el `veterinaria.sql`.
2. Ejecutas el script completo con el rayito.
3. fijese aver si existe la base `veterinaria`.
4.  tambien las tablas `cliente`, `mascota` y los procedimientos.

## Usuarios

El script crea estos usuarios:

- `vet_definer`: cuenta usada por MySQL para ejecutar los procesos internos.
- `vet_app`: cuenta que usa la intellij. solo tiene permiso para ejecutar los procesos.

## Configurar para correrlo bn

1. En Run, vas a edit configuration.
2. Seleccionas la configuracion de `Main`.
3. Agrega estas variables:

```text
VET_DB_URL=jdbc:mysql://localhost:3306/veterinaria?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
VET_DB_USER=vet_app
VET_DB_PASSWORD=tu_contrasena_de_vet_app, en mi caso puse VetApp123!
```

## Ejecucion pro

Ejecutas el `Main`. La ventana deberia abrir normal


## Pruebas de seguridad

Para comprobar que `vet_app` no tiene acceso directo a las tablas, abre una
conexion con ese usuario y prueba esto:

```sql
CALL sp_listar_mascotas();
```

Esto DEBERIA funcionar.

Luego:

```sql
SELECT * FROM mascota;
```

DEBERIAS recibir un error de permisos, ami si me salio xd.
