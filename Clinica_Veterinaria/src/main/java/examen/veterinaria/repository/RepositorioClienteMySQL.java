package examen.veterinaria.repository;

import examen.veterinaria.model.Cliente;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RepositorioClienteMySQL implements RepositorioCliente {
    private Connection conectar() throws SQLException {
        return DriverManager.getConnection(
            ConfiguracionMySQL.obtenerUrl(),
            ConfiguracionMySQL.obtenerUsuario(),
            ConfiguracionMySQL.obtenerContrasena()
        );
    }

    @Override
    public List<Cliente> cargarTodos() {
        List<Cliente> clientes = new ArrayList<>();
        String sql = "{CALL sp_listar_clientes()}";
        try (Connection conexion = conectar();
             CallableStatement procedimiento = conexion.prepareCall(sql);
             ResultSet resultados = procedimiento.executeQuery()) {
            while (resultados.next()) {
                clientes.add(new Cliente(
                    resultados.getString("cedula"),
                    resultados.getString("nombre"),
                    resultados.getString("telefono")
                ));
            }
            return clientes;
        } catch (SQLException e) {
            throw new PersistenciaException("No fue posible consultar los clientes en MySQL.", e);
        }
    }

    @Override
    public void insertar(Cliente cliente) {
        String sql = "{CALL sp_insertar_cliente(?, ?, ?)}";
        try (Connection conexion = conectar();
             CallableStatement procedimiento = conexion.prepareCall(sql)) {
            procedimiento.setString(1, cliente.getCedula());
            procedimiento.setString(2, cliente.getNombre());
            procedimiento.setString(3, cliente.getTelefono());
            procedimiento.execute();
        } catch (SQLException e) {
            throw new PersistenciaException(obtenerMensaje(e), e);
        }
    }

    private String obtenerMensaje(SQLException e) {
        if (e.getSQLState() != null && e.getSQLState().startsWith("45")) {
            return e.getMessage();
        }
        return "No fue posible guardar el cliente en MySQL.";
    }
}
