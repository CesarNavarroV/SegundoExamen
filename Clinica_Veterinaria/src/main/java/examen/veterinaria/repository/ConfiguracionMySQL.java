package examen.veterinaria.repository;

public final class ConfiguracionMySQL {
    private ConfiguracionMySQL() {
    }

    public static String obtenerUrl() {
        return obtener("VET_DB_URL");
    }

    public static String obtenerUsuario() {
        return obtener("VET_DB_USER");
    }

    public static String obtenerContrasena() {
        return obtener("VET_DB_PASSWORD");
    }

    private static String obtener(String nombre) {
        String valor = System.getenv(nombre);
        if (valor == null || valor.isBlank()) {
            throw new PersistenciaException(
                "Configure la variable de entorno " + nombre + " antes de iniciar la aplicación.",
                null
            );
        }
        return valor.trim();
    }
}
