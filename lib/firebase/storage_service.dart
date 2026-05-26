import 'package:image_picker/image_picker.dart';

class StorageService {
  // Firebase Storage is disabled for now to stay on the Firebase free plan and avoid upload errors.
  // In the future, we can uncomment the FirebaseStorage code if we get a paid plan.
  // final FirebaseStorage _storage = FirebaseStorage.instance;

  // We don't upload images for posts anymore, so this just returns null.
  Future<String?> uploadPostImage({
    required XFile imageFile,
    required String userId,
  }) async {
    return null;
  }

  // Returns a static Unsplash placeholder image instead of uploading to Firebase Storage.
  // This keeps the profile screen working with a default picture.
  Future<String?> uploadProfileImage({
    required XFile imageFile,
    required String userId,
  }) async {
    return 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&q=80&w=200';
  }
}
