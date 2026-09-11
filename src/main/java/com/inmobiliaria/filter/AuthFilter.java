package com.inmobiliaria.filter;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

// Intercepta cualquier peticion a las carpetas privadas
@WebFilter(urlPatterns = {"/admin/*", "/agente/*", "/cliente/*"})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);
        boolean isLoggedIn = (session != null && session.getAttribute("usuarioLogueado") != null);

        if (!isLoggedIn) {
            res.sendRedirect(req.getContextPath() + "/acceso.jsp");
            return;
        }

        // Verifica que el usuario tenga el rol requerido por la ruta a la que entra
        String ruta = req.getRequestURI().substring(req.getContextPath().length());
        String rolRequerido = null;
        if (ruta.startsWith("/admin/")) {
            rolRequerido = "admin";
        } else if (ruta.startsWith("/agente/")) {
            rolRequerido = "agente";
        } else if (ruta.startsWith("/cliente/")) {
            rolRequerido = "cliente";
        }

        if (rolRequerido != null) {
            List<String> roles = (List<String>) session.getAttribute("usuarioRoles");
            if (roles == null || !roles.contains(rolRequerido)) {
                res.sendRedirect(req.getContextPath() + "/acceso.jsp");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}