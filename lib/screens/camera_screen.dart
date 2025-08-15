import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

enum _CameraState { loading, ready, error }

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  _CameraState _cameraState = _CameraState.loading;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _cameraState = _CameraState.error);
        return;
      }
      _controller = CameraController(cameras.first, ResolutionPreset.medium);
      await _controller.initialize();
      if (mounted) setState(() => _cameraState = _CameraState.ready);
    } catch (e) {
      if (mounted) setState(() => _cameraState = _CameraState.error);
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    if (_cameraState == _CameraState.ready) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_cameraState != _CameraState.ready) return;
    try {
      final image = await _controller.takePicture();
      if (mounted) Navigator.pop(context, image.path);
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      body: _buildBody(),
      floatingActionButton: _cameraState == _CameraState.ready
          ? FloatingActionButton(
              onPressed: _takePicture,
              child: const Icon(Icons.camera_alt),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBody() {
    switch (_cameraState) {
      case _CameraState.loading:
        return const Center(child: CircularProgressIndicator());
      case _CameraState.error:
        return const Center(child: Text('Failed to initialize camera.'));
      case _CameraState.ready:
        return CameraPreview(_controller);
    }
  }
}