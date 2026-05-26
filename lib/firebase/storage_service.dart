import 'package:image_picker/image_picker.dart';

class StorageService {
  // Firebase Storage has been disabled to support the free plan without upload failures.
  // final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Mock/Bypass upload: Returns null since image posting is disabled
  Future<String?> uploadPostImage({
    required XFile imageFile,
    required String userId,
  }) async {
    return null;
  }

  /// Mock/Bypass upload: Returns a static default profile image URL to avoid Storage usage
  Future<String?> uploadProfileImage({
    required XFile imageFile,
    required String userId,
  }) async {
    return 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&q=80&w=200';
  }
}
