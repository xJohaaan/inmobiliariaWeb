package com.inmobiliaria.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class ConexionBD {

    
    private static final String URL = "jdbc:mysql://localhost:3306/inmobiliaria_db";
    private static final String USER = "root";
    private static final String PASSWORD = "Sneyder_321"; 
    private static final String DRIVER = "com.mysql.cj.jdbc.Driver";

    private static Connection conexion = null;

    // Constructor privado para evitar instancias (Patron Singleton)
    private ConexionBD() {}

    public static Connection getConexion() {
        try {
            if (conexion == null || conexion.isClosed()) {
                Class.forName(DRIVER);
                conexion = DriverManager.getConnection(URL, USER, PASSWORD);
                System.out.println("Conexion a la base de datos establecida con exito.");
            }
        } catch (ClassNotFoundException e) {
            System.err.println("Error: Driver JDBC no encontrado. Revisa la carpeta WEB-INF/lib.");
            e.printStackTrace();
        } catch (SQLException e) {
            System.err.println("Error al conectar con la base de datos: " + e.getMessage());
            e.printStackTrace();
        }
        return conexion;
    }

    public static void cerrarConexion() {
        if (conexion != null) {
            try {
                conexion.close();
                System.out.println("Conexion cerrada correctamente.");
            } catch (SQLException e) {
                System.err.println("Error al cerrar la conexion: " + e.getMessage());
            }
        }
    }
}