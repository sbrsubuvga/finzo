import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class GoogleDriveService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/drive.file',
    ],
  );

  GoogleSignInAccount? _currentUser;
  drive.DriveApi? _driveApi;

  // Sign in to Google
  Future<bool> signIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return false;
      }

      _currentUser = account;
      final authHeaders = await account.authHeaders;
      
      final client = GoogleAuthClient(http.Client(), authHeaders);
      _driveApi = drive.DriveApi(client);

      return true;
    } catch (e) {
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
    _driveApi = null;
  }

  // Check if signed in
  bool isSignedIn() {
    return _currentUser != null && _driveApi != null;
  }

  // Upload backup file to Google Drive
  Future<String?> uploadBackup(File file) async {
    if (!isSignedIn()) {
      final signedIn = await signIn();
      if (!signedIn) {
        throw Exception('Not signed in to Google');
      }
    }

    try {
      final fileName = file.path.split('/').last;
      final media = drive.Media(file.openRead(), file.lengthSync());

      final driveFile = drive.File();
      driveFile.name = fileName;

      final uploadedFile = await _driveApi!.files.create(
        driveFile,
        uploadMedia: media,
      );

      return uploadedFile.id;
    } catch (e) {
      throw Exception('Failed to upload to Google Drive: $e');
    }
  }

  // List backup files from Google Drive
  Future<List<drive.File>> listBackups() async {
    if (!isSignedIn()) {
      throw Exception('Not signed in to Google');
    }

    try {
      final response = await _driveApi!.files.list(
        q: "name contains 'finzo_backup' and mimeType='application/json'",
        orderBy: 'modifiedTime desc',
      );

      return response.files ?? [];
    } catch (e) {
      throw Exception('Failed to list backups: $e');
    }
  }

  // Download backup file from Google Drive
  Future<String> downloadBackup(String fileId) async {
    if (!isSignedIn()) {
      throw Exception('Not signed in to Google');
    }

    try {
      final response = await _driveApi!.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      );

      if (response is drive.Media) {
        final bytes = await response.stream.toList();
        final data = bytes.expand((x) => x).toList();
        return String.fromCharCodes(data);
      } else {
        throw Exception('Unexpected response type');
      }
    } catch (e) {
      throw Exception('Failed to download backup: $e');
    }
  }

  // Delete backup file from Google Drive
  Future<void> deleteBackup(String fileId) async {
    if (!isSignedIn()) {
      throw Exception('Not signed in to Google');
    }

    try {
      await _driveApi!.files.delete(fileId);
    } catch (e) {
      throw Exception('Failed to delete backup: $e');
    }
  }
}

// Helper class for Google Auth
class GoogleAuthClient extends http.BaseClient {
  final http.Client _client;
  final Map<String, String> _headers;

  GoogleAuthClient(this._client, this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _client.send(request);
  }

  @override
  void close() => _client.close();
}

