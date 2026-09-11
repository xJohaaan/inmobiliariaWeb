package com.inmobiliaria.dao;

import com.inmobiliaria.config.ConexionBD;
import com.inmobiliaria.model.Usuario;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UsuarioDAO {

    // Método para registrar un nuevo usuario
    public String registrarUsuario(Usuario usuario) {
        String sql = "INSERT INTO usuario (correo, contrasena, salt, estado) VALUES (?, ?, ?, ?)";
        
        // El bloque try-with-resources cierra automáticamente la conexión y el statement
        try (Connection conn = ConexionBD.getConexion();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, usuario.getCorreo());
            pstmt.setString(2, usuario.getContrasena()); // Aquí ya viene el hash
            pstmt.setString(3, usuario.getSalt());
            pstmt.setString(4, usuario.getEstado() != null ? usuario.getEstado() : "Activa");
            
            pstmt.executeUpdate();
            return "Registro exitoso";
            
        } catch (SQLException e) {
            // El estado SQL que empieza por "23" indica violación de integridad (UNIQUE)
            if (e.getSQLState() != null && e.getSQLState().startsWith("23")) {
                return "Error: El correo ya se encuentra registrado."; // Mensaje amigable exigido
            }
            e.printStackTrace();
            return "Error interno en la base de datos.";
        }
    }

    // Método para buscar un usuario por su correo (usado en el Login)
    public Usuario obtenerUsuarioPorCorreo(String correo) {
        Usuario usuario = null;
        String sql = "SELECT id_usuario, correo, contrasena, salt, estado FROM usuario WHERE correo = ?";
        
        try (Connection conn = ConexionBD.getConexion();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, correo);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    usuario = new Usuario(
                        rs.getInt("id_usuario"),
                        rs.getString("correo"),
                        rs.getString("contrasena"),
                        rs.getString("salt"),
                        rs.getString("estado")
                    );
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return usuario; // Retorna nulo si el correo no existe en la BD
    }
}