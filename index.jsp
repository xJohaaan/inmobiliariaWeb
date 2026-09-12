<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.Locale" %>
<%@ include file="WEB-INF/jspf/conexion.jspf" %>
<%
    String usuario = (String) session.getAttribute("usuarioLogueado");
    java.util.List<String> roles = (java.util.List<String>) session.getAttribute("usuarioRoles");

    Connection con = null;
    java.util.ArrayList<Integer> destacadas = new java.util.ArrayList<Integer>();
    java.util.ArrayList<String> titulos = new java.util.ArrayList<String>();
    java.util.ArrayList<String> ciudades = new java.util.ArrayList<String>();
    java.util.ArrayList<String> tipos = new java.util.ArrayList<String>();
    java.util.ArrayList<Double> precios = new java.util.ArrayList<Double>();
    java.util.ArrayList<String> imagenes = new java.util.ArrayList<String>();
    java.util.ArrayList<String> codigos = new java.util.ArrayList<String>();
    java.util.ArrayList<String> zonas = new java.util.ArrayList<String>();
    try {
        con = obtenerConexion();
        String sql = "SELECT p.id_propiedad, p.titulo_publicacion, p.precio, p.matricula_inmobiliaria, tp.nombre AS tipo, " +
                     "b.nombre_barrio, c.nombre_ciudad, " +
                     "(SELECT url_ruta_imagen FROM imagen_propiedad i WHERE i.id_propiedad=p.id_propiedad ORDER BY i.id_imagen LIMIT 1) AS img " +
                     "FROM propiedad p " +
                     "JOIN tipo_propiedad tp ON tp.id_tipo=p.id_tipo " +
                     "JOIN barrio b ON b.id_barrio=p.id_barrio " +
                     "JOIN ciudad c ON c.id_ciudad=b.id_ciudad " +
                     "WHERE p.estado='Disponible' ORDER BY p.id_propiedad DESC LIMIT 6";
        PreparedStatement ps = con.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            destacadas.add(rs.getInt("id_propiedad"));
            titulos.add(rs.getString("titulo_publicacion"));
            ciudades.add(rs.getString("nombre_barrio") + ", " + rs.getString("nombre_ciudad"));
            tipos.add(rs.getString("tipo"));
            precios.add(rs.getDouble("precio"));
            String img = rs.getString("img");
            imagenes.add(img != null ? img : "https://picsum.photos/seed/none/900/600");
            String mat = rs.getString("matricula_inmobiliaria");
            codigos.add(mat != null ? mat : "Sin código");
        }
        rs.close(); ps.close();

        PreparedStatement psZ = con.prepareStatement("SELECT nombre_ciudad FROM ciudad ORDER BY nombre_ciudad");
        ResultSet rsZ = psZ.executeQuery();
        while (rsZ.next()) zonas.add(rsZ.getString(1));
        rsZ.close(); psZ.close();
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        cerrarConexion(con);
    }

    String rutaPanel = "index.jsp";
    if (usuario != null && roles != null) {
        if (roles.contains("admin")) rutaPanel = "admin/index.jsp";
        else if (roles.contains("agente")) rutaPanel = "agente/index.jsp";
        else if (roles.contains("cliente")) rutaPanel = "cliente/index.jsp";
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inmobiliaria Arco Real</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <link href="css/estilos.css" rel="stylesheet">
</head>
<body>

<div class="topbar py-2">
    <div class="container d-flex flex-wrap justify-content-between gap-2">
        <div class="d-flex flex-wrap gap-3 align-items-center">
            <a href="tel:6012345678"><i class="bi bi-telephone"></i> (601) 234 5678</a>
            <a href="mailto:contacto@arcoreal.com"><i class="bi bi-envelope"></i> contacto@arcoreal.com</a>
            <span class="sep d-none d-md-inline">L&ndash;V 8am a 5:30pm &middot; S&aacute;b 8am a 12pm</span>
        </div>
        <div class="d-flex gap-3">
            <a href="#"><i class="bi bi-instagram"></i></a>
            <a href="#"><i class="bi bi-facebook"></i></a>
            <a href="#"><i class="bi bi-whatsapp"></i></a>
        </div>
    </div>
</div>

<nav class="navbar navbar-expand-lg navbar-light navbar-inmo sticky-top">
    <div class="container">
        <a class="navbar-brand" href="index.jsp"><i class="bi bi-building-check"></i> Inmobiliaria Arco Real</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navLanding" aria-controls="navLanding" aria-expanded="false" aria-label="Abrir menú">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navLanding">
            <ul class="navbar-nav ms-auto align-items-lg-center gap-lg-1">
                <li class="nav-item"><a class="nav-link active" href="index.jsp">Inicio</a></li>
                <li class="nav-item"><a class="nav-link" href="buscar.jsp"><i class="bi bi-search"></i> Catálogo</a></li>
                <% if (usuario == null) { %>
                    <li class="nav-item"><a class="nav-link" href="login.jsp">Iniciar Sesión</a></li>
                    <li class="nav-item ms-lg-2"><a class="btn btn-success btn-sm px-3" href="registro.jsp">Registrarse</a></li>
                <% } else { %>
                    <li class="nav-item ms-lg-2"><a class="btn btn-primary btn-sm px-3" href="<%= rutaPanel %>"><i class="bi bi-grid"></i> Mi Panel</a></li>
                <% } %>
            </ul>
        </div>
    </div>
</nav>

<header class="hero-inmo">
    <div class="container">
        <div class="row align-items-center gy-5">
            <div class="col-lg-6">
                <span class="cred-badge mb-3"><i class="bi bi-patch-check-fill"></i> 15+ AÑOS EN EL PAÍS</span>
                <h1 class="display-5 mb-3">Encuentra tu próximo inmueble con respaldo experto</h1>
                <p class="lead mb-4">Conectamos familias y negocios con el espacio ideal. Compra, arrienda o vende con transacciones seguras y acompañamiento jurídico en cada paso.</p>
                <div class="d-flex flex-wrap gap-2">
                    <span class="cred-badge"><i class="bi bi-award-fill"></i> Lonja de Propiedad Raíz</span>
                    <span class="cred-badge"><i class="bi bi-shield-check"></i> Inmuebles verificados</span>
                </div>
            </div>
            <div class="col-lg-6">
                <div class="card card-busqueda">
                    <div class="card-body p-4">
                        <h5 class="fw-bold mb-1">Búsqueda rápida</h5>
                        <p class="small text-muted mb-3">Filtra por tipo, ciudad y precio.</p>
                        <form action="buscar.jsp" method="GET" class="row g-2">
                            <div class="col-6">
                                <label class="form-label small mb-1">Tipo de inmueble:</label>
                                <select name="tipo" class="form-select">
                                    <option value="">Todos los tipos</option>
                                    <%
                                        Connection c2 = null;
                                        try { c2 = obtenerConexion();
                                            PreparedStatement ps2 = c2.prepareStatement("SELECT id_tipo, nombre FROM tipo_propiedad ORDER BY nombre");
                                            ResultSet rs2 = ps2.executeQuery();
                                            while (rs2.next()) { %><option value="<%= rs2.getInt(1) %>"><%= rs2.getString(2) %></option><% }
                                            rs2.close(); ps2.close();
                                        } catch (Exception e) { } finally { cerrarConexion(c2); }
                                    %>
                                </select>
                            </div>
                            <div class="col-6">
                                <label class="form-label small mb-1">Ciudad:</label>
                                <select name="ciudad" class="form-select">
                                    <option value="">Cualquier zona</option>
                                    <%
                                        Connection c3 = null;
                                        try { c3 = obtenerConexion();
                                            PreparedStatement ps3 = c3.prepareStatement("SELECT id_ciudad, nombre_ciudad FROM ciudad ORDER BY nombre_ciudad");
                                            ResultSet rs3 = ps3.executeQuery();
                                            while (rs3.next()) { %><option value="<%= rs3.getInt(1) %>"><%= rs3.getString(2) %></option><% }
                                            rs3.close(); ps3.close();
                                        } catch (Exception e) { } finally { cerrarConexion(c3); }
                                    %>
                                </select>
                            </div>
                            <div class="col-6">
                                <label class="form-label small mb-1">Precio mín:</label>
                                <input type="number" name="pmin" class="form-control" placeholder="0" min="0" step="1000000">
                            </div>
                            <div class="col-6">
                                <label class="form-label small mb-1">Precio máx:</label>
                                <input type="number" name="pmax" class="form-control" placeholder="Sin límite" min="0" step="1000000">
                            </div>
                            <div class="col-12 mt-2">
                                <button type="submit" class="btn btn-success w-100 py-2"><i class="bi bi-search"></i> Buscar</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</header>

<section class="py-5">
    <div class="container">
        <div class="row align-items-end mb-4">
            <div class="col-md-8">
                <div class="section-titulo">
                    <span class="kicker">Lo más visto</span>
                    <h2>Inmuebles destacados</h2>
                    <p class="mb-0">Selección curada con los mejores precios y ubicaciones del momento.</p>
                </div>
            </div>
            <div class="col-md-4 text-md-end mt-3 mt-md-0">
                <a href="buscar.jsp" class="btn btn-outline-primary"><i class="bi bi-grid"></i> Ver todo el catálogo</a>
            </div>
        </div>
        <div class="row g-4">
            <% for (int i = 0; i < destacadas.size(); i++) { %>
                <div class="col-12 col-sm-6 col-lg-4">
                    <div class="card card-propiedad h-100 shadow-sm">
                        <div class="img-wrapper">
                            <img src="<%= imagenes.get(i) %>" alt="<%= titulos.get(i) %>">
                            <span class="badge-destacada"><i class="bi bi-star-fill"></i> Destacada</span>
                        </div>
                        <div class="card-body">
                            <p class="precio">$ <%= String.format(Locale.US, "%,.0f", precios.get(i)) %></p>
                            <h5 class="card-title"><%= titulos.get(i) %></h5>
                            <p class="codigo mb-1"><i class="bi bi-upc-scan"></i> <%= codigos.get(i) %></p>
                            <p class="text-muted small mb-3"><i class="bi bi-geo-alt"></i> <%= ciudades.get(i) %> &middot; <%= tipos.get(i) %></p>
                            <a href="propiedad.jsp?id=<%= destacadas.get(i) %>" class="btn btn-primary w-100">Ver ficha</a>
                        </div>
                    </div>
                </div>
            <% } %>
            <% if (destacadas.isEmpty()) { %>
                <div class="col-12"><div class="alert alert-info">Aún no hay propiedades publicadas.</div></div>
            <% } %>
        </div>
    </div>
</section>

<section class="franja-stats">
    <div class="container">
        <div class="row g-4">
            <div class="col-6 col-lg-3 stat-item">
                <div class="stat-num">15+</div>
                <div class="stat-label">Años de experiencia</div>
                <div class="stat-line"></div>
            </div>
            <div class="col-6 col-lg-3 stat-item">
                <div class="stat-num">500+</div>
                <div class="stat-label">Inmuebles gestionados</div>
                <div class="stat-line"></div>
            </div>
            <div class="col-6 col-lg-3 stat-item">
                <div class="stat-num">100%</div>
                <div class="stat-label">Transacciones seguras</div>
                <div class="stat-line"></div>
            </div>
            <div class="col-6 col-lg-3 stat-item">
                <div class="stat-num">24/7</div>
                <div class="stat-label">Asesoría y respaldo</div>
                <div class="stat-line"></div>
            </div>
        </div>
    </div>
</section>

<section class="py-5 bg-white">
    <div class="container">
        <div class="section-titulo text-center mb-5">
            <span class="kicker">Soluciones integrales</span>
            <h2>Nuestros servicios</h2>
            <p>Una inmobiliaria completa: desde encontrar tu próximo hogar hasta cuidar la inversión que ya tienes.</p>
        </div>
        <div class="row g-4">
            <div class="col-12 col-md-6 col-lg-3">
                <div class="servicio-card">
                    <div class="icono-servicio mb-3"><i class="bi bi-house-heart"></i></div>
                    <div class="fs-5 mb-2">Arriendos</div>
                    <p class="text-muted mb-3">Administramos inmuebles residenciales y comerciales con renta segura para el propietario.</p>
                    <a href="buscar.jsp" class="btn btn-outline-success btn-sm">Solicitar info</a>
                </div>
            </div>
            <div class="col-12 col-md-6 col-lg-3">
                <div class="servicio-card">
                    <div class="icono-servicio mb-3"><i class="bi bi-key"></i></div>
                    <div class="fs-5 mb-2">Ventas</div>
                    <p class="text-muted mb-3">Vendemos tu inmueble con respaldo jurídico, fotos profesionales y publicidad en el catálogo.</p>
                    <a href="buscar.jsp" class="btn btn-outline-success btn-sm">Solicitar info</a>
                </div>
            </div>
            <div class="col-12 col-md-6 col-lg-3">
                <div class="servicio-card">
                    <div class="icono-servicio mb-3"><i class="bi bi-calculator"></i></div>
                    <div class="fs-5 mb-2">Avalúos</div>
                    <p class="text-muted mb-3">Avalúos comerciales para venta, arrendamiento, garantías o trámites bancarios.</p>
                    <a href="buscar.jsp" class="btn btn-outline-success btn-sm">Solicitar info</a>
                </div>
            </div>
            <div class="col-12 col-md-6 col-lg-3">
                <div class="servicio-card">
                    <div class="icono-servicio mb-3"><i class="bi bi-shield-lock"></i></div>
                    <div class="fs-5 mb-2">Asesoría jurídica</div>
                    <p class="text-muted mb-3">Acompañamiento documental y legal en cada paso de tu operación inmobiliaria.</p>
                    <a href="buscar.jsp" class="btn btn-outline-success btn-sm">Solicitar info</a>
                </div>
            </div>
        </div>
    </div>
</section>

<section class="py-5 fondo-claro">
    <div class="container">
        <div class="banner-avaluo row align-items-center g-4">
            <div class="col-lg-7">
                <span class="kicker">100% Gratis &middot; Sin compromiso</span>
                <h2 class="mb-3">¿Sabes cuánto vale tu inmueble hoy?</h2>
                <ul class="list-unstyled mb-0">
                    <li><i class="bi bi-check-circle-fill me-2"></i>Reporte profesional con metodología de mercado</li>
                    <li><i class="bi bi-check-circle-fill me-2"></i>Comparativo con inmuebles de la zona</li>
                    <li><i class="bi bi-check-circle-fill me-2"></i>Recomendaciones para vender o arrendar más rápido</li>
                </ul>
            </div>
            <div class="col-lg-5">
                <div class="bg-white text-dark rounded-4 p-4 shadow">
                    <h6 class="fw-bold mb-1">Solicita tu avalúo gratis</h6>
                    <p class="small text-muted">Te contactamos en menos de 24 horas.</p>
                    <a href="mailto:contacto@arcoreal.com" class="btn btn-success w-100 mb-2"><i class="bi bi-whatsapp"></i> Quiero mi avalúo</a>
                    <p class="small text-muted mb-0 text-center"><i class="bi bi-shield-lock"></i> Tus datos están protegidos.</p>
                </div>
            </div>
        </div>
    </div>
</section>

<section class="py-5">
    <div class="container">
        <div class="row align-items-center g-5">
            <div class="col-lg-6">
                <img src="https://picsum.photos/seed/inmobiliaria/900/640" class="img-fluid rounded-4 shadow" alt="Equipo Inmobiliaria Arco Real">
            </div>
            <div class="col-lg-6">
                <span class="kicker">Conócenos</span>
                <h2 class="fw-bold text-primary mb-3">Más que una inmobiliaria, tu aliado de confianza</h2>
                <p class="text-muted mb-3">Nuestra misión es facilitar decisiones inmobiliarias inteligentes con asesoría experta, transparencia y respaldo legal.</p>
                <p class="text-muted mb-4">Contamos con un equipo certificado en avalúos, gestión jurídica y comercialización inmobiliaria, comprometido con acompañarte desde la búsqueda hasta la entrega.</p>
                <a href="registro.jsp" class="btn btn-primary px-4"><i class="bi bi-person-plus"></i> Crea tu cuenta</a>
            </div>
        </div>
    </div>
</section>

<% if (!zonas.isEmpty()) { %>
<section class="py-5 fondo-claro">
    <div class="container">
        <div class="section-titulo text-center mb-4">
            <span class="kicker">Cobertura</span>
            <h2>Zonas que cubrimos</h2>
            <p>Operamos en las principales ciudades del país.</p>
        </div>
        <div class="d-flex flex-wrap justify-content-center gap-2">
            <% for (String z : zonas) { %>
                <a href="buscar.jsp" class="chip-zona"><i class="bi bi-geo-alt"></i> <%= z %></a>
            <% } %>
        </div>
    </div>
</section>
<% } %>

<section class="py-5">
    <div class="container" style="max-width: 860px;">
        <div class="section-titulo text-center mb-4">
            <span class="kicker">Resolvemos tus dudas</span>
            <h2>Preguntas frecuentes</h2>
        </div>
        <div class="accordion" id="faqLanding">
            <div class="accordion-item mb-3">
                <h2 class="accordion-header">
                    <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#faq1" aria-expanded="true">
                        ¿Qué documentos necesito para arrendar un inmueble?
                    </button>
                </h2>
                <div id="faq1" class="accordion-collapse collapse show" data-bs-parent="#faqLanding">
                    <div class="accordion-body text-muted">Cédula, certificado laboral o de ingresos y extractos bancarios. Te asesoramos en todo el proceso desde tu panel de cliente.</div>
                </div>
            </div>
            <div class="accordion-item mb-3">
                <h2 class="accordion-header">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq2">
                        ¿Cómo agendo una visita a una propiedad?
                    </button>
                </h2>
                <div id="faq2" class="accordion-collapse collapse" data-bs-parent="#faqLanding">
                    <div class="accordion-body text-muted">Crea una cuenta de cliente, inicia sesión y en la ficha de la propiedad encontrarás el botón "Agendar cita de visita".</div>
                </div>
            </div>
            <div class="accordion-item mb-3">
                <h2 class="accordion-header">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq3">
                        ¿En cuánto tiempo publican mi inmueble?
                    </button>
                </h2>
                <div id="faq3" class="accordion-collapse collapse" data-bs-parent="#faqLanding">
                    <div class="accordion-body text-muted">Nuestro equipo revisa y publica el inmueble en el catálogo en un promedio de 24 a 48 horas.</div>
                </div>
            </div>
            <div class="accordion-item">
                <h2 class="accordion-header">
                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#faq4">
                        ¿Es seguro radicar una solicitud de compra o arriendo?
                    </button>
                </h2>
                <div id="faq4" class="accordion-collapse collapse" data-bs-parent="#faqLanding">
                    <div class="accordion-body text-muted">Sí. Las solicitudes se procesan con trazabilidad y acompañamiento; puedes subir los documentos desde tu panel de cliente de forma privada.</div>
                </div>
            </div>
        </div>
    </div>
</section>

<section class="pb-5">
    <div class="container">
        <div class="banner-contacto row align-items-center g-4">
            <div class="col-lg-7">
                <span class="kicker" style="color:#d3ffe2;">Hablemos hoy</span>
                <h2 class="mb-2">Tu próximo inmueble está a un mensaje de distancia</h2>
                <p class="mb-0" style="color:#cfe0f0;">Nuestro equipo de asesores responderá en el menor tiempo posible.</p>
            </div>
            <div class="col-lg-5 d-flex flex-column flex-sm-row gap-2 justify-content-lg-end">
                <a href="tel:6012345678" class="btn btn-blanco"><i class="bi bi-whatsapp"></i> Escribir por WhatsApp</a>
                <a href="tel:6012345678" class="btn btn-outline-light"><i class="bi bi-telephone"></i> Llamar</a>
            </div>
        </div>
    </div>
</section>

<footer class="footer-inmo pt-5">
    <div class="container">
        <div class="row gy-4 pb-4">
            <div class="col-md-5">
                <a class="navbar-brand fw-bold marca" href="index.jsp" style="font-size:1.2rem;"><i class="bi bi-building-check"></i> Inmobiliaria Arco Real</a>
                <p class="small mt-3">Más de 15 años conectando familias y negocios con el inmueble ideal, con respaldo experto y transacciones seguras.</p>
            </div>
            <div class="col-6 col-md-2">
                <h6>Enlaces</h6>
                <ul class="list-unstyled small mb-0">
                    <li class="mb-1"><a href="index.jsp">Inicio</a></li>
                    <li class="mb-1"><a href="buscar.jsp">Catálogo</a></li>
                    <li class="mb-1"><a href="login.jsp">Iniciar sesión</a></li>
                    <li><a href="registro.jsp">Registrarse</a></li>
                </ul>
            </div>
            <div class="col-6 col-md-2">
                <h6>Servicios</h6>
                <ul class="list-unstyled small mb-0">
                    <li class="mb-1"><a href="buscar.jsp">Arriendos</a></li>
                    <li class="mb-1"><a href="buscar.jsp">Ventas</a></li>
                    <li class="mb-1"><a href="buscar.jsp">Avalúos</a></li>
                    <li><a href="buscar.jsp">Asesoría jurídica</a></li>
                </ul>
            </div>
            <div class="col-12 col-md-3">
                <h6>Contacto</h6>
                <ul class="list-unstyled small mb-0">
                    <li class="mb-1"><i class="bi bi-telephone"></i> (601) 234 5678</li>
                    <li class="mb-1"><i class="bi bi-envelope"></i> contacto@arcoreal.com</li>
                    <li><i class="bi bi-clock"></i> L&ndash;V: 8 a.m. &ndash; 5:30 p.m.<br>S&aacute;b: 8 a.m. &ndash; 12 m.</li>
                </ul>
            </div>
        </div>
    </div>
    <div class="footer-bar py-3">
        <div class="container d-flex flex-wrap justify-content-between gap-2">
            <span>&copy; 2026 Inmobiliaria Arco Real. Todos los derechos reservados.</span>
            <span><a href="buscar.jsp">Catálogo</a> &middot; <a href="login.jsp">Iniciar sesión</a> &middot; <a href="registro.jsp">Registrarse</a></span>
        </div>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>