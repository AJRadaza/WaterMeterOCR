import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:sqflite/sqflite.dart';
import 'overlay_painter.dart';
import 'display_picture_screen.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;
  final Future<Database> database;
  final int staffId;
  final String meterNumber;

  const CameraScreen({
    super.key, 
    required this.camera, 
    required this.database, 
    required this.staffId, 
    required this.meterNumber,
  });

  @override
  CameraScreenState createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<File> _cropImage(String imagePath) async {
    try {
      final imageBytes = File(imagePath).readAsBytesSync();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      final screenSize = MediaQuery.of(context).size;

      // Define the rectangle dimensions similar to a TextField
      final rectWidth = (image.width * 0.8).toInt();
      final rectHeight = (70.0 * image.height / screenSize.height).toInt(); // Adjust height proportionally
      final rectLeft = ((image.width - rectWidth) / 2).toInt();
      final rectTop = ((image.height - rectHeight) / 2).toInt();

      final croppedImage = img.copyCrop(
        image,
        rectLeft,
        rectTop,
        rectWidth,
        rectHeight,
      );
      final croppedImagePath = '${Directory.systemTemp.path}/cropped_image_${DateTime.now().millisecondsSinceEpoch}.png';
      File(croppedImagePath).writeAsBytesSync(img.encodePng(croppedImage));
      return File(croppedImagePath);
    } catch (e) {
      print('Error cropping image: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Water Meter Reading')),
      body: Center(
        child: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Container(
                width: 1080, // Set the desired width
                height: 1920, // Set the desired height
                child: Stack(
                  children: [
                    Center(child: CameraPreview(_controller)),
                    CustomPaint(
                      painter: OverlayPainter(),
                      child: Container(),
                    ),
                  ],
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: FloatingActionButton(
            onPressed: () async {
              try {
                await _initializeControllerFuture;
                final image = await _controller.takePicture();
                if (!mounted) return;
                final croppedImage = await _cropImage(image.path);
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DisplayPictureScreen(
                      imagePath: croppedImage.path,
                      database: widget.database,
                      staffId: widget.staffId,
                      meterNumber: widget.meterNumber,
                      onReadingSaved: () {
                        // Reload pending requests
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              } catch (e) {
                print('Error taking picture: $e');
              }
            },
            child: Icon(Icons.camera_alt),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}