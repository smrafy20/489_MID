// lib/screens/entity_form_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:bangladesh_map_app/constants/app_constants.dart';
import 'package:bangladesh_map_app/models/entity.dart';
import 'package:bangladesh_map_app/providers/entity_provider.dart';
import 'package:bangladesh_map_app/services/image_service.dart';
import 'package:bangladesh_map_app/services/location_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EntityFormScreen extends StatefulWidget {
  final Entity? entity;
  const EntityFormScreen({super.key, this.entity});

  @override
  State<EntityFormScreen> createState() => _EntityFormScreenState();
}

class _EntityFormScreenState extends State<EntityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  final _imageService = ImageService();
  final _locationService = LocationService();
  File? _imageFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.entity != null) {
      _titleController.text = widget.entity!.title;
      _latController.text = widget.entity!.lat.toString();
      _lonController.text = widget.entity!.lon.toString();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      final position = await _locationService.getCurrentPosition();
      _latController.text = position.latitude.toString();
      _lonController.text = position.longitude.toString();
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final file = await _imageService.pickImage(source);
    if (file != null) {
      setState(() {
        _imageFile = file;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_imageFile == null && widget.entity == null) {
        Fluttertoast.showToast(msg: 'Please select an image');
        return;
      }
      setState(() => _isLoading = true);
      
      final entityProvider = Provider.of<EntityProvider>(context, listen: false);
      final entity = Entity(
        id: widget.entity?.id,
        title: _titleController.text,
        lat: double.parse(_latController.text),
        lon: double.parse(_lonController.text),
      );

      bool success;
      if (widget.entity == null) {
        success = await entityProvider.createEntity(entity, _imageFile!);
      } else {
        success = await entityProvider.updateEntity(entity, _imageFile);
      }

      setState(() => _isLoading = false);

      if (success) {
        Fluttertoast.showToast(msg: 'Entity saved successfully');
        if (mounted) Navigator.pop(context);
      } else {
        Fluttertoast.showToast(msg: 'Failed to save entity');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entity == null ? AppConstants.createEntity : AppConstants.editEntity),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: AppConstants.title),
                      validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
                    ),
                    TextFormField(
                      controller: _latController,
                      decoration: const InputDecoration(labelText: AppConstants.latitude),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Please enter latitude' : null,
                    ),
                    TextFormField(
                      controller: _lonController,
                      decoration: const InputDecoration(labelText: AppConstants.longitude),
                      keyboardType: TextInputType.number,
                      validator: (value) => value!.isEmpty ? 'Please enter longitude' : null,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _getCurrentLocation,
                      icon: const Icon(Icons.my_location),
                      label: const Text(AppConstants.getCurrentLocation),
                    ),
                    const SizedBox(height: 20),
                    _imageFile != null
                        ? Image.file(_imageFile!, height: 150)
                        : (widget.entity?.imagePath != null
                            ? Image.network(Provider.of<EntityProvider>(context, listen: false).getFullImageUrl(widget.entity!.imagePath), height: 150)
                            : const Text('No image selected')),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.camera),
                          icon: const Icon(Icons.camera),
                          label: const Text(AppConstants.takePhoto),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _pickImage(ImageSource.gallery),
                          icon: const Icon(Icons.photo_library),
                          label: const Text(AppConstants.chooseImage),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitForm,
                      child: Text(widget.entity == null ? AppConstants.save : AppConstants.update),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}