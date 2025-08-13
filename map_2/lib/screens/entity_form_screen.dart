import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/entity.dart';
import 'package:map_2/screens/camera_screen.dart';
import '../providers/entity_provider.dart';

class EntityFormScreen extends StatefulWidget {
  final Entity? entity;

  const EntityFormScreen({super.key, this.entity});

  @override
  _EntityFormScreenState createState() => _EntityFormScreenState();
}

class _EntityFormScreenState extends State<EntityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late double _lat;
  late double _lon;
  File? _image;
  bool _isSubmitting = false;

  final _latController = TextEditingController();
  final _lonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.entity != null) {
      _title = widget.entity!.title;
      _lat = widget.entity!.lat;
      _lon = widget.entity!.lon;
      _latController.text = _lat.toString();
      _lonController.text = _lon.toString();
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePicture() async {
    final imagePath = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const CameraScreen(),
      ),
    );

    if (imagePath != null) {
      setState(() {
        _image = File(imagePath);
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _lat = position.latitude;
      _lon = position.longitude;
      _latController.text = _lat.toString();
      _lonController.text = _lon.toString();
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSubmitting = true;
      });
      final entityProvider = Provider.of<EntityProvider>(context, listen: false);
      try {
        if (widget.entity == null) {
          await entityProvider.createEntity(_title, _lat, _lon, _image?.path);
        } else {
          await entityProvider.updateEntity(widget.entity!.id, _title, _lat, _lon, _image?.path);
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit entity: $e')),
        );
      } finally {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entity == null ? 'Add Entity' : 'Edit Entity'),
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: widget.entity?.title,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                      onSaved: (value) => _title = value!,
                    ),
                    TextFormField(
                      controller: _latController,
                      decoration: const InputDecoration(labelText: 'Latitude'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a latitude';
                        }
                        return null;
                      },
                      onSaved: (value) => _lat = double.parse(value!),
                    ),
                    TextFormField(
                      controller: _lonController,
                      decoration: const InputDecoration(labelText: 'Longitude'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a longitude';
                        }
                        return null;
                      },
                      onSaved: (value) => _lon = double.parse(value!),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _image == null
                            ? const Text('No image selected.')
                            : Image.file(_image!, width: 100, height: 100),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _pickImage,
                          child: const Text('Pick Image'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _takePicture,
                          child: const Text('Take Picture'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _getCurrentLocation,
                      child: const Text('Get Current Location'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
