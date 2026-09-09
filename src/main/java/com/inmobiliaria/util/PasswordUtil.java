package com.inmobiliaria.util;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Base64;

public class PasswordUtil {

    // Genera un Salt aleatorio de 16 bytes
    public static String generateSalt() {
        SecureRandom random = new SecureRandom();
        byte[] salt = new byte[16];
        random.nextBytes(salt);
        return Base64.getEncoder().encodeToString(salt);
    }

    // Genera un Hash SHA-256 combinando la contraseña con el Salt
    public static String hashPassword(String password, String salt) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            // Se concatena el salt a la clave antes de encriptar
            digest.update(salt.getBytes());
            byte[] encodedHash = digest.digest(password.getBytes());
            
            StringBuilder hexString = new StringBuilder();
            for (byte b : encodedHash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            e.printStackTrace();
            throw new RuntimeException("Error al cifrar la contraseña");
        }
    }

    // Verifica si la clave ingresada coincide con el hash guardado usando el salt original
    public static boolean verifyPassword(String inputPassword, String storedHash, String storedSalt) {
        String hashOfInput = hashPassword(inputPassword, storedSalt);
        return hashOfInput.equals(storedHash);
    }
}