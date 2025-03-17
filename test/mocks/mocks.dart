import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_project_bdclpm/features/expense/controllers/scan_expense_controller.dart';
import 'package:flutter_project_bdclpm/features/expense/controllers/cloud.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/vision/v1.dart' as vision;
import 'package:gcloud/storage.dart';
import 'package:flutter_project_bdclpm/features/expense/data/auth_client_wrapper.dart';
@GenerateMocks([
  FirebaseAuth,
  auth.AuthClient,
  User,
  UserCredential,
  auth.AutoRefreshingAuthClient,
  Storage,
  Bucket,
  vision.VisionApi,
  vision.ImagesResource,
  UserMetadata,
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
  http.Client,
  SharedPreferences,
  stt.SpeechToText,
  NavigatorState,
  GlobalKey,
  ScaffoldMessengerState,
  FilePicker,
  Permission,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  QuerySnapshot,
  QueryDocumentSnapshot,
  WriteBatch,
  FirebaseStorage,
  Reference,
  UploadTask,
  TaskSnapshot,
  ImagePicker,
  PickedFile,
  XFile,
  CameraController,
  CameraDescription,
  FlutterLocalNotificationsPlugin,
  InitializationSettings,
  NotificationDetails,
  ScanExpenseController,
  CloudApi,
  AuthClientWrapper
])
void main() {}
