package examen.veterinaria.repository;

import examen.veterinaria.model.Especie;
import examen.veterinaria.model.Mascota;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RepositorioMascotaMySQL implements RepositorioMascota {
    private Connection conectar() throws SQLException {
        return DriverManager.getConnection(
            ConfiguracionMySQL.obtenerUrl(),
            ConfiguracionMySQL.obtenerUsuario(),
            ConfiguracionMySQL.obtenerContrasena()
        );
    }

    @Override
    public List<Mascota> cargarTodos() {
        List<Mascota> mascotas = new ArrayList<>();
        String sql = "{CALL sp_listar_mascotas()}";
        try (Connection conexion = conectar();
             CallableStatement procedimiento = conexion.prepareCall(sql);
             ResultSet resultados = procedimiento.executeQuery()) {
            while (resultados.next()) {
                mascotas.add(new Mascota(
                    resultados.getString("codigo"),
                    resultados.getString("nombre"),
                    Especie.valueOf(resultados.getString("especie")),
                    resultados.getInt("edad"),
                    resultados.getString("cedula_cliente")
                ));
            }
            return mascotas;
        } catch (SQLException e) {
            throw new PersistenciaException("No fue posible consultar las mascotas en MySQL.", e);
        }
    }

    @Override
    public void insertar(Mascota mascota) {
        String sql = "{CALL sp_insertar_mascota(?, ?, ?, ?, ?)}";
        ejecutarActualizacion(sql, mascota);
    }

    @Override
    public void actualizar(Mascota mascota) {
        String sql = "{CALL sp_actualizar_mascota(?, ?, ?, ?, ?)}";
        ejecutarActualizacion(sql, mascota);
    }

    private void ejecutarActualizacion(String sql, Mascota mascota) {
        try (Connection conexion = conectar();
             CallableStatement procedimiento = conexion.prepareCall(sql)) {
            procedimiento.setString(1, mascota.getCodigo());
            procedimiento.setString(2, mascota.getNombre());
            procedimiento.setString(3, mascota.getEspecie().name());
            procedimiento.setInt(4, mascota.getEdad());
            procedimiento.setString(5, mascota.getCedulaCliente());
            procedimiento.execute();
        } catch (SQLException e) {
            throw new PersistenciaException(obtenerMensaje(e), e);
        }
    }

    @Override
    public void eliminar(String codigo) {
        String sql = "{CALL sp_eliminar_mascota(?)}";
        try (Connection conexion = conectar();
             CallableStatement procedimiento = conexion.prepareCall(sql)) {
            procedimiento.setString(1, codigo);
            procedimiento.execute();
        } catch (SQLException e) {
            throw new PersistenciaException(obtenerMensaje(e), e);
        }
    }

    @Override
    public List<String> listarConDueno() {
        List<String> filas = new ArrayList<>();
        String sql = "{CALL sp_listar_mascotas_con_dueno()}";
        try (Connection conexion = conectar();
             CallableStatement procedimiento = conexion.prepareCall(sql);
             ResultSet resultados = procedimiento.executeQuery()) {
            while (resultados.next()) {
                Mascota mascota = new Mascota(
                    resultados.getString("codigo"),
                    resultados.getString("nombre"),
                    Especie.valueOf(resultados.getString("especie")),
                    resultados.getInt("edad"),
                    resultados.getString("cedula_cliente")
                );
                filas.add(mascota + " | Cliente: " + resultados.getString("nombre_cliente"));
            }
            return filas;
        } catch (SQLException e) {
            throw new PersistenciaException("No fue posible consultar las mascotas con sus dueños.", e);
        }
    }

    private String obtenerMensaje(SQLException e) {
        if (e.getSQLState() != null && e.getSQLState().startsWith("45")) {
            return e.getMessage();
        }
        return "No fue posible completar la operación con MySQL.";
    }
}
