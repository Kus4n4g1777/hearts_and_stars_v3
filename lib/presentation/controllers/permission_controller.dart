import 'dart:developer';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  var cameraPermission = await Permission.camera.request();
  var microphonePermission = await Permission.microphone.request();
  var photosPermission = await Permission.photos.request();
  var storagePermission = await Permission.storage.request();

  if (cameraPermission.isGranted &&
      microphonePermission.isGranted &&
      photosPermission.isGranted &&
      storagePermission.isGranted) {
    log("Todos los permisos concedidos");
  } else {
    log("Algunos permisos no fueron concedidos");
    if (!cameraPermission.isGranted) log("Permiso de cámara no concedido");
    if (!microphonePermission.isGranted) log("Permiso de micrófono no concedido");
    if (!photosPermission.isGranted) log("Permiso de fotos no concedido");
    if (!storagePermission.isGranted) log("Permiso de almacenamiento no concedido");
  }
}