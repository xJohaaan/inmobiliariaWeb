package com.inmobiliaria.controller;

import com.inmobiliaria.dao.UsuarioDAO;
import com.inmobiliaria.model.Usuario;
import com.inmobiliaria.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

// Esta anotacion define la URL a la que apuntarán tus formularios web
@WebServlet("/auth") 
public class AuthServlet extends HttpServlet {
    
    private UsuarioDAO usuarioDAO = new UsuarioDAO();

    // Se ejecuta cuando el formulario hace un POST (Login o Registro)
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String accion = request.getParameter("accion"); // Un campo oculto en tu HTML dirá si es "login" o "registro"

        if ("registrar".equals(accion)) {
            registrarUsuario(request, response);
        } else if ("login".equals(accion)) {
            iniciarSesion(request, response);
        }
    }

    // Se ejecuta cuando entras por URL normal (se usa para el Logout)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String accion = request.getParameter("accion");
        if ("logout".equals(accion)) {
            request.getSession().invalidate(); // Destruye la sesion
            response.sendRedirect("login.jsp");
        }
    }

    private void registrarUsuario(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String correo = request.getParameter("correo");
        String contrasena = request.getParameter("contrasena");

        // 1. Generamos el salt y ciframos la clave
        String salt = PasswordUtil.generateSalt();
        String hash = PasswordUtil.hashPassword(contrasena, salt);

        // 2. Metemos los datos en el POJO
        Usuario nuevoUsuario = new Usuario(0, correo, hash, salt, "Activa");
        
        // 3. Enviamos al DAO y guardamos la respuesta (éxito o correo duplicado)
        String resultado = usuarioDAO.registrarUsuario(nuevoUsuario);

        // 4. Devolvemos el mensaje a la vista
        request.getSession().setAttribute("mensajeRegistro", resultado);
        response.sendRedirect("registro.jsp");
    }

    private void iniciarSesion(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String correo = request.getParameter("correo");
        String contrasena = request.getParameter("contrasena");

        // 1. Buscamos al usuario en la BD
        Usuario usuario = usuarioDAO.obtenerUsuarioPorCorreo(correo);

        // 2. Verificamos que exista y que la clave coincida
        if (usuario != null && PasswordUtil.verifyPassword(contrasena, usuario.getContrasena(), usuario.getSalt())) {
            
            // Validar estado de la cuenta
            if ("Inactiva".equals(usuario.getEstado())) {
                request.getSession().setAttribute("errorLogin", "Tu cuenta está inactiva.");
                response.sendRedirect("login.jsp");
                return;
            }
            
            // 3. Si todo está bien, iniciamos la sesion
            HttpSession session = request.getSession();
            session.setAttribute("usuarioLogueado", usuario);
            
            // Redireccion temporal (luego se ajustará por rol a sus respectivos dashboards)
            response.sendRedirect("index.jsp"); 
        } else {
            // 4. Si falla, lo devolvemos al login con error
            request.getSession().setAttribute("errorLogin", "Credenciales incorrectas.");
            response.sendRedirect("login.jsp");
        }
    }
}