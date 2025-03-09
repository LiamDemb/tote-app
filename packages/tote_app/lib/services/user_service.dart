import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:tote_app/models/user_model.dart';
import 'package:tote_app/services/api_service.dart';

class UserService {
  // Create or update a user in our database based on Firebase user
  Future<UserModel?> syncUserWithDatabase(firebase_auth.User firebaseUser) async {
    try {
      // Check if user already exists in our database
      final existingUser = await getUserByFirebaseUid(firebaseUser.uid);
      
      if (existingUser != null) {
        // User exists, return the existing user
        return existingUser;
      } else {
        // User doesn't exist, create a new user
        return await createUser(firebaseUser);
      }
    } catch (e) {
      print('Error syncing user with database: $e');
      // Don't fail the entire auth flow if database sync fails
      // Instead return a minimal user model based on Firebase info
      return UserModel(
        id: firebaseUser.uid, // Use Firebase UID as fallback ID
        email: firebaseUser.email ?? '',
        firebaseUid: firebaseUser.uid,
        firstName: firebaseUser.displayName?.split(' ').first,
        lastName: firebaseUser.displayName?.split(' ').length ?? 0 > 1 
            ? firebaseUser.displayName?.split(' ').skip(1).join(' ') 
            : null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }
  
  // Get user by Firebase UID
  Future<UserModel?> getUserByFirebaseUid(String firebaseUid) async {
    try {
      final response = await ApiService.get('api/users/firebase/$firebaseUid');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserModel.fromJson(data);
      } else if (response.statusCode == 404) {
        // User not found
        return null;
      } else {
        throw Exception('Failed to get user: ${response.body}');
      }
    } catch (e) {
      print('Error getting user by Firebase UID: $e');
      return null;
    }
  }
  
  // Create a new user in our database
  Future<UserModel?> createUser(firebase_auth.User firebaseUser) async {
    try {
      // Extract name parts if available
      String? firstName;
      String? lastName;
      
      if (firebaseUser.displayName != null) {
        final nameParts = firebaseUser.displayName!.split(' ');
        firstName = nameParts.first;
        if (nameParts.length > 1) {
          lastName = nameParts.skip(1).join(' ');
        }
      }
      
      final userData = {
        'email': firebaseUser.email,
        'firebaseUid': firebaseUser.uid,
        'firstName': firstName,
        'lastName': lastName,
        'authProvider': firebaseUser.providerData.isNotEmpty 
            ? firebaseUser.providerData.first.providerId 
            : 'email',
      };
      
      final response = await ApiService.post('api/users', body: userData);
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return UserModel.fromJson(data);
      } else {
        throw Exception('Failed to create user: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }
  
  // Update user profile
  Future<UserModel?> updateUserProfile(String userId, Map<String, dynamic> profileData) async {
    try {
      final response = await ApiService.patch('api/users/$userId', body: profileData);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserModel.fromJson(data);
      } else {
        throw Exception('Failed to update user profile: ${response.body}');
      }
    } catch (e) {
      print('Error updating user profile: $e');
      return null;
    }
  }
  
  // Diagnostic method to check API connectivity
  Future<Map<String, dynamic>> checkApiConnectivity() async {
    return await ApiService.checkApiStatus();
  }
} 