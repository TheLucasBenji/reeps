import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Servicio para subir imágenes a Cloudinary
class CloudinaryService {
  // Credenciales de Cloudinary
  static const String cloudName = 'dkloiir4x';
  static const String uploadPreset = 'reeps_profile';

  /// Sube una imagen de perfil y retorna la URL de la imagen
  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      // Timestamp para ID único (unsigned no soporta overwrite)
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = 'profile_images'
        ..fields['public_id'] = '${userId}_$timestamp'
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();

      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonData = json.decode(responseData);
        final url = jsonData['secure_url'] as String?;
        return url;
      } else {
        throw Exception('Error al subir imagen: $responseData');
      }
    } catch (e) {
      rethrow;
    }
  }
}
