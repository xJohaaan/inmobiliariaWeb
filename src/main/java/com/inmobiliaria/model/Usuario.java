package com.inmobiliaria.model;

import java.util.List;

public class Usuario {
    private int idUsuario;
    private String correo;
    private String contrasena;
    private String salt;
    private String estado;
    private List<Rol> roles; // Permite manejar la relacion N:M de usuario_rol

    public Usuario() {}

    public Usuario(int idUsuario, String correo, String contrasena, String salt, String estado) {
        this.idUsuario = idUsuario;
        this.correo = correo;
        this.contrasena = contrasena;
        this.salt = salt;
        this.estado = estado;
    }

    public int getIdUsuario() { return idUsuario; }
    public void setIdUsuario(int idUsuario) { this.idUsuario = idUsuario; }

    public String getCorreo() { return correo; }
    public void setCorreo(String correo) { this.correo = correo; }

    public String getContrasena() { return contrasena; }
    public void setContrasena(String contrasena) { this.contrasena = contrasena; }

    public String getSalt() { return salt; }
    public void setSalt(String salt) { this.salt = salt; }

    public String getEstado() { return estado; }
    public void setEstado(String estado) { this.estado = estado; }

    public List<Rol> getRoles() { return roles; }
    public void setRoles(List<Rol> roles) { this.roles = roles; }
}