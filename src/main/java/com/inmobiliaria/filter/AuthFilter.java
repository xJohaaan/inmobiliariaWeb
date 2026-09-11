package com.inmobiliaria.filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

// Esta anotacion le dice al servidor que intercepte cualquier peticion a estas 3 carpetas
@WebFilter(urlPatterns = {"/admin/*", "/agente/*", "/cliente/*"})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Metodo requerido por la interfaz, se ejecuta al iniciar el servidor
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        
        // Obtenemos la sesion actual (false significa que no cree una nueva si no existe)
        HttpSession session = req.getSession(false);
        
        // Verificamos si existe la variable "usuarioLogueado" que creamos en el AuthServlet
        boolean isLoggedIn = (session != null && session.getAttribute("usuarioLogueado") != null);

        if (!isLoggedIn) {
            // Si intenta entrar a una carpeta protegida sin sesion, lo mandamos a acceso denegado
            // getContextPath() asegura que la ruta base del proyecto (ej. /inmobiliariaWeb) se respete
            res.sendRedirect(req.getContextPath() + "/acceso.jsp");
            return;
        }

        // Si la sesion existe, le abrimos la puerta y dejamos que la peticion continue
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // Metodo requerido por la interfaz, se ejecuta al apagar el filtro
    }
}