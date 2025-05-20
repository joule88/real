import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'api_constants.dart';

class UploadService {
  static Future<List<String>> uploadImages(List<XFile> images) async {
    final uri = Uri.parse(ApiConstants.baseUrl + '/upload-images');
    var request = http.MultipartRequest('POST', uri);

    for (var image in images) {
      request.files.add(await http.MultipartFile.fromPath(
        'images[]',
        image.path,
        filename: image.name,
      ));
    }

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final data = jsonDecode(responseData);
      return List<String>.from(data['urls']);
    } else {
      throw Exception('Failed to upload images');
    }
  }
}
