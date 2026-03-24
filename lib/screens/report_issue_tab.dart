import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../services/firestore_service.dart';
import '../services/image_picker_service.dart';
import '../services/location_service.dart';
import '../widgets/primary_button.dart';

class ReportIssueTab extends StatefulWidget {
  final String userId;

  const ReportIssueTab({super.key, required this.userId});

  @override
  State<ReportIssueTab> createState() => _ReportIssueTabState();
}

class _ReportIssueTabState extends State<ReportIssueTab> {
  final TextEditingController _descriptionController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  final MapController _mapController = MapController();

  LatLng _currentLatLng = const LatLng(20.5937, 78.9629);
  LatLng? _selectedLatLng;
  XFile? _selectedImage;
  bool _loading = false;
  bool _locating = false;
  String _submitStage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markCurrentLocation(showErrors: false);
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _markCurrentLocation({bool showErrors = true}) async {
    if (_locating) return;
    setState(() => _locating = true);
    try {
      final position = await LocationService.getCurrentLocation();
      final latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentLatLng = latLng;
        _selectedLatLng = latLng;
      });
      _mapController.move(latLng, 16);
      if (!mounted || !showErrors) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Current location captured.')),
      );
    } catch (e) {
      if (!mounted || !showErrors) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _pickImage() async {
    if (_loading) return;
    final source = await showModalBottomSheet<String>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, 'camera'),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, 'gallery'),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    XFile? file;
    if (source == 'camera') {
      file = await ImagePickerService.pickFromCamera();
    } else {
      file = await ImagePickerService.pickFromGallery();
    }

    if (file != null) {
      setState(() => _selectedImage = file);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image selected.')),
      );
    }
  }

  Future<void> _submitIssue() async {
    if (widget.userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please sign in again, then submit the issue.')),
      );
      return;
    }
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the issue.')),
      );
      return;
    }
    if (_selectedLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please mark your location.')),
      );
      return;
    }
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image.')),
      );
      return;
    }

    setState(() {
      _loading = true;
      _submitStage = 'Uploading image...';
    });

    try {
      String imageUrl = '';
      String imageBase64 = '';
      bool uploadedWithImage = false;

      try {
        imageUrl = await _firestoreService
            .uploadIssueImage(userId: widget.userId, image: _selectedImage!)
            .timeout(const Duration(seconds: 90));
        uploadedWithImage = true;
      } catch (_) {
        imageBase64 = await _firestoreService
            .encodeIssueImageFallback(_selectedImage!)
            .timeout(const Duration(seconds: 30));
        uploadedWithImage = true;
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Cloud upload failed, so the photo will be saved with the report directly.',
            ),
          ),
        );
      }

      if (!mounted) return;
      setState(() => _submitStage =
          uploadedWithImage ? 'Saving report...' : 'Saving report without image...');
      await _firestoreService
          .createIssue(
            userId: widget.userId,
            description: _descriptionController.text.trim(),
            latitude: _selectedLatLng!.latitude,
            longitude: _selectedLatLng!.longitude,
            imageUrl: imageUrl,
            imageBase64: imageBase64,
          )
          .timeout(const Duration(seconds: 45));

      if (!mounted) return;
      setState(() {
        _descriptionController.clear();
        _selectedImage = null;
        _selectedLatLng = null;
      });

      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Report Uploaded'),
          content: Text(
            uploadedWithImage
                ? 'Your issue was submitted successfully.'
                : 'Your issue was submitted, but the image could not be attached.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submit failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _submitStage = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final markerPos = _selectedLatLng;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F766E), Color(0xFF0284C7)],
              ),
            ),
            child: const Text(
              'Field Reporting Console',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentLatLng,
                  initialZoom: 14,
                  onTap: (_, latLng) {
                    setState(() => _selectedLatLng = latLng);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName:
                        'com.example.cleanliness_environmental_awareness',
                  ),
                  if (_selectedLatLng != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLatLng!,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_pin,
                            size: 40,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  const Positioned(
                    right: 8,
                    bottom: 8,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Color(0xAAFFFFFF),
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Text(
                          '(c) OpenStreetMap contributors',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            text: _locating ? 'Detecting Location...' : 'Mark Location',
            icon: Icons.my_location,
            onPressed: (_loading || _locating) ? () {} : _markCurrentLocation,
          ),
          if (_submitStage.isNotEmpty) ...[
            const SizedBox(height: 10),
            LinearProgressIndicator(
              borderRadius: BorderRadius.circular(8),
              minHeight: 6,
            ),
            const SizedBox(height: 6),
            Text(_submitStage,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
          if (markerPos != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Selected coordinates: ${markerPos.latitude.toStringAsFixed(5)}, ${markerPos.longitude.toStringAsFixed(5)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Describe issue',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _loading ? null : _pickImage,
            icon: const Icon(Icons.upload_file_outlined),
            label: Text(
                _selectedImage == null ? 'Upload Image' : 'Image Selected'),
          ),
          if (_selectedImage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: kIsWeb
                    ? Image.network(_selectedImage!.path,
                        height: 140, width: double.infinity, fit: BoxFit.cover)
                    : Image.file(File(_selectedImage!.path),
                        height: 140, width: double.infinity, fit: BoxFit.cover),
              ),
            ),
          const SizedBox(height: 14),
          PrimaryButton(
            text: _loading ? 'Please wait...' : 'Submit Issue',
            icon: Icons.send,
            onPressed: _loading ? () {} : _submitIssue,
          ),
        ],
      ),
    );
  }
}
