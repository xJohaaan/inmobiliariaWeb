<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    session.setAttribute("__rolesRequeridos", new String[]{"agente"});
%>
<%@ include file="../../WEB-INF/jspf/seguridad.jspf" %>
<%@ include file="../../WEB-INF/jspf/conexion.jspf" %>
<%
    int idProp = 0;
    try { idProp = Integer.parseInt(request.getParameter("id")); } catch (Exception e) { idProp = 0; }

    String matricula = "", titulo = "", desc = "", precio = "", estado = "Disponible";
    int inmId = 0, ciuId = 0, barId = 0, tipoId = 0;
    java.util.ArrayList<String> imgsActuales = new java.util.ArrayList<String>();
    java.util.ArrayList<Integer> caractsSel = new java.util.ArrayList<Integer>();
    java.util.HashMap<Integer, Integer> cantMap = new java.util.HashMap<Integer, Integer>();

    Connection con = null;
    try {
        con = obtenerConexion();
        if (idProp > 0) {
            PreparedStatement ps = con.prepareStatement(
                "SELECT matricula_inmobiliaria, id_inmobiliaria, id_barrio, id_tipo, titulo_publicacion, descripcion, precio, estado, b.id_ciudad " +
                "FROM propiedad p JOIN barrio b ON b.id_barrio=p.id_barrio WHERE id_propiedad=?");
            ps.setInt(1, idProp);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                matricula = rs.getString("matricula_inmobiliaria");
                inmId = rs.getInt("id_inmobiliaria");
                barId = rs.getInt("id_barrio");
                tipoId = rs.getInt("id_tipo");
                titulo = rs.getString("titulo_publicacion");
                String d = rs.getString("descripcion"); desc = d != null ? d : "";
                precio = rs.getString("precio");
                estado = rs.getString("estado");
                ciuId = rs.getInt("id_ciudad");
            }
            rs.close(); ps.close();

            PreparedStatement pi = con.prepareStatement("SELECT url_ruta_imagen FROM imagen_propiedad WHERE id_propiedad=? ORDER BY id_imagen");
            pi.setInt(1, idProp);
            ResultSet ri = pi.executeQuery();
            while (ri.next()) imgsActuales.add(ri.getString(1));
            ri.close(); pi.close();

            PreparedStatement pc = con.prepareStatement("SELECT id_caracteristica, cantidad FROM propiedad_caracteristica WHERE id_propiedad=?");
            pc.setInt(1, idProp);
            ResultSet rc = pc.executeQuery();
            while (rc.next()) {
                int idCar = rc.getInt(1);
                caractsSel.add(idCar);
                cantMap.put(idCar, rc.getInt(2));
            }
            rc.close(); pc.close();
        }
    } catch (Exception e) { e.printStackTrace(); } finally { cerrarConexion(con); }

    String __tituloPanel = idProp > 0 ? "Editar Propiedad" : "Nueva Propiedad";
%>
<%@ include file="../../WEB-INF/jspf/cabecera_dash.jspf" %>

<div class="card shadow-sm mx-auto" style="max-width:900px">
    <div class="card-body p-4">
        <form method="POST" action="controlador_propiedad.jsp">
            <input type="hidden" name="accion" value="<%= idProp > 0 ? "editar" : "crear" %>">
            <% if (idProp > 0) { %><input type="hidden" name="id" value="<%= idProp %>"><% } %>

            <div class="row g-3">
                <div class="col-md-6">
                    <label class="form-label">Matrícula inmobiliaria *</label>
                    <input type="text" name="matricula" class="form-control" value="<%= matricula %>" required <%= idProp > 0 ? "readonly" : "" %>>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Inmobiliaria *</label>
                    <select name="id_inmobiliaria" class="form-select" required>
                        <option value="">Seleccione...</option>
                        <%
                            Connection cI = null;
                            try { cI = obtenerConexion();
                                PreparedStatement psI = cI.prepareStatement("SELECT id_inmobiliaria, nombre_empresa FROM inmobiliaria ORDER BY nombre_empresa");
                                ResultSet rsI = psI.executeQuery();
                                while (rsI.next()) {
                                    int idI = rsI.getInt(1);
                                    String selI = idI == inmId ? "selected" : "";
                        %><option value="<%= idI %>" <%= selI %>><%= rsI.getString(2) %></option><%
                                }
                                rsI.close(); psI.close();
                            } catch (Exception e) {} finally { cerrarConexion(cI); }
                        %>
                    </select>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Ciudad *</label>
                    <select id="selCiudad" name="id_ciudad" class="form-select" required onchange="filtrarBarrios()">
                        <option value="">Seleccione...</option>
                        <%
                            Connection cC = null;
                            try { cC = obtenerConexion();
                                PreparedStatement psC = cC.prepareStatement("SELECT id_ciudad, nombre_ciudad FROM ciudad ORDER BY nombre_ciudad");
                                ResultSet rsC = psC.executeQuery();
                                while (rsC.next()) {
                                    int idC = rsC.getInt(1);
                                    String selC = idC == ciuId ? "selected" : "";
                        %><option value="<%= idC %>" <%= selC %>><%= rsC.getString(2) %></option><%
                                }
                                rsC.close(); psC.close();
                            } catch (Exception e) {} finally { cerrarConexion(cC); }
                        %>
                    </select>
                </div>
                <div class="col-md-6">
                    <label class="form-label">Barrio *</label>
                    <select id="selBarrio" name="id_barrio" class="form-select" required>
                        <option value="">Primero elige ciudad</option>
                        <%
                            Connection cB = null;
                            try { cB = obtenerConexion();
                                PreparedStatement psB = cB.prepareStatement("SELECT id_barrio, id_ciudad, nombre_barrio FROM barrio ORDER BY nombre_barrio");
                                ResultSet rsB = psB.executeQuery();
                                while (rsB.next()) {
                                    int idB = rsB.getInt(1), idCi = rsB.getInt(2);
                                    String selB = idB == barId ? "selected" : "";
                        %><option value="<%= idB %>" data-ciudad="<%= idCi %>" <%= selB %>><%= rsB.getString(3) %></option><%
                                }
                                rsB.close(); psB.close();
                            } catch (Exception e) {} finally { cerrarConexion(cB); }
                        %>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Tipo de propiedad *</label>
                    <select name="id_tipo" class="form-select" required>
                        <option value="">Seleccione...</option>
                        <%
                            Connection cT = null;
                            try { cT = obtenerConexion();
                                PreparedStatement psT = cT.prepareStatement("SELECT id_tipo, nombre FROM tipo_propiedad ORDER BY nombre");
                                ResultSet rsT = psT.executeQuery();
                                while (rsT.next()) {
                                    int idT = rsT.getInt(1);
                                    String selT = idT == tipoId ? "selected" : "";
                        %><option value="<%= idT %>" <%= selT %>><%= rsT.getString(2) %></option><%
                                }
                                rsT.close(); psT.close();
                            } catch (Exception e) {} finally { cerrarConexion(cT); }
                        %>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Precio (COP) *</label>
                    <input type="number" name="precio" class="form-control" value="<%= precio %>" min="1" step="1000" required>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Estado</label>
                    <select name="estado" class="form-select">
                        <option value="Disponible" <%= estado.equals("Disponible") ? "selected" : "" %>>Disponible</option>
                        <option value="Alquilado" <%= estado.equals("Alquilado") ? "selected" : "" %>>Alquilado</option>
                        <option value="Vendido" <%= estado.equals("Vendido") ? "selected" : "" %>>Vendido</option>
                    </select>
                </div>
                <div class="col-12">
                    <label class="form-label">Título de la publicación *</label>
                    <input type="text" name="titulo" class="form-control" value="<%= titulo %>" required>
                </div>
                <div class="col-12">
                    <label class="form-label">Descripción</label>
                    <textarea name="descripcion" class="form-control" rows="3"><%= desc %></textarea>
                </div>
            </div>

            <hr class="my-4">
            <h6 class="fw-bold"><i class="bi bi-list-check"></i> Características del inmueble</h6>
            <div class="row g-2">
                <%
                    Connection cCar = null;
                    try { cCar = obtenerConexion();
                        PreparedStatement psCar = cCar.prepareStatement("SELECT id_caracteristica, nombre FROM caracteristica ORDER BY id_caracteristica");
                        ResultSet rsCar = psCar.executeQuery();
                        while (rsCar.next()) {
                            int idCar = rsCar.getInt(1);
                            String nomCar = rsCar.getString(2);
                            boolean marcada = caractsSel.contains(idCar);
                            int cant = cantMap.containsKey(idCar) ? cantMap.get(idCar) : 1;
                            String valorNumerico = idCar == 1 || idCar == 2 || idCar == 4 ? nomCar : "cantidad";
                %>
                    <div class="col-6 col-md-4">
                        <div class="border rounded-3 p-2 d-flex align-items-center gap-2">
                            <input type="checkbox" name="caracteristicas" id="chk_<%= idCar %>" value="<%= idCar %>" class="form-check-input" <%= marcada ? "checked" : "" %> onchange="toggleCant('cant_<%= idCar %>')">
                            <span class="flex-grow-1 small"><%= nomCar %></span>
                            <input type="number" name="cantidad_<%= idCar %>" id="cant_<%= idCar %>" class="form-control form-control-sm" style="width:70px"
                                   value="<%= cant %>" min="0" <%= marcada ? "" : "disabled" %> oninput="document.getElementById('chk_<%= idCar %>').checked=true">
                        </div>
                    </div>
                <%
                        }
                        rsCar.close(); psCar.close();
                    } catch (Exception e) { e.printStackTrace(); } finally { cerrarConexion(cCar); }
                %>
            </div>
            <div class="form-text mt-1">Marca la característica y ajusta la cantidad. Si no hay casilla de cantidad, cuenta como 1.</div>

            <hr class="my-4">
            <h6 class="fw-bold"><i class="bi bi-images"></i> Galería de imágenes (URLs)</h6>
            <div class="row g-2" id="filaImagenes">
                <% if (imgsActuales.isEmpty()) { %>
                    <div class="col-12"><input type="url" name="imagenes" class="form-control" placeholder="https://.../foto1.jpg"></div>
                    <div class="col-12"><input type="url" name="imagenes" class="form-control" placeholder="https://.../foto2.jpg"></div>
                    <div class="col-12"><input type="url" name="imagenes" class="form-control" placeholder="https://.../foto3.jpg"></div>
                <% } else { %>
                    <% for (String img : imgsActuales) { %>
                        <div class="col-12"><input type="url" name="imagenes" class="form-control" value="<%= img %>"></div>
                    <% } %>
                <% } %>
            </div>
            <button type="button" class="btn btn-sm btn-outline-secondary mt-2" onclick="agregarImagen()"><i class="bi bi-plus-circle"></i> Agregar otra imagen</button>

            <div class="d-grid mt-4">
                <button class="btn btn-primary btn-lg" type="submit"><i class="bi bi-save"></i> Guardar propiedad</button>
            </div>
        </form>
    </div>
</div>

<script>
    function filtrarBarrios() {
        var cid = document.getElementById('selCiudad').value || '0';
        var barrios = document.getElementById('selBarrio').querySelectorAll('option[data-ciudad]');
        var hay = false;
        for (var i = 0; i < barrios.length; i++) {
            var ok = barrios[i].getAttribute('data-ciudad') === cid;
            barrios[i].style.display = ok ? '' : 'none';
            if (ok) hay = true;
        }
        if (!hay) document.getElementById('selBarrio').value = '';
    }
    function toggleCant(id) {
        var c = document.getElementById(id);
        if (c) c.disabled = !c.checked;
    }
    function agregarImagen() {
        var fila = document.getElementById('filaImagenes');
        var div = document.createElement('div');
        div.className = 'col-12';
        div.innerHTML = '<input type="url" name="imagenes" class="form-control" placeholder="https://.../foto.jpg">';
        fila.appendChild(div);
    }
    window.addEventListener('load', filtrarBarrios);
</script>

</main>
<footer class="footer-inmo py-3 text-center mt-auto">
    <span class="small"><a class="text-white" href="mis_propiedades.jsp">Volver a propiedades</a></span>
</footer>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>