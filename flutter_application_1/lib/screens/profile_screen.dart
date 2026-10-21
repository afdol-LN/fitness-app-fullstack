import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/app.config.dart';
import 'package:flutter_application_1/widgets/profile_avatar_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  String? _imageFileName;
  final ImagePicker _picker = ImagePicker();

  void _getImageFromDevice() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imageFileName = prefs.getString("image_url");

    setState(() {
      _imageFileName = imageFileName;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _getImageFromDevice();
  }

  // laptop/PC (Windows, macOS, Linux) หรือรันบน browser
  bool get _isDesktopOrWeb =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.linux;

  Future<void> _uploadImageToServer(XFile imageFile) async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("${AppConfig.apiBaseUrl}/upload"),
    );

    request.headers.addAll({
      'Authorization': 'Bearer ${prefs.getString("access_token")}',
      'Accept': 'application/json',
    });

    try {
      // อ่านเป็น bytes เพื่อให้ใช้ได้ทั้งมือถือ, laptop และ web
      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        await imageFile.readAsBytes(),
        filename: imageFile.name,
      );
      request.files.add(multipartFile);

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        throw Exception("อัปโหลดไม่สำเร็จ (${response.statusCode})");
      }

      var responseData = jsonDecode(response.body);

      if (responseData["isError"] == true) {
        throw Exception(responseData["errorMessage"] ?? "อัปโหลดไม่สำเร็จ");
      }

      final newImageUrl = responseData["data"];
      await prefs.setString("image_url", newImageUrl);

      if (!mounted) return;
      setState(() {
        _imageFileName = newImageUrl;
        _isLoading = false;
      });
    } catch (error) {
      debugPrint("Upload profile image failed: $error");
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("อัปโหลดรูปไม่สำเร็จ: $error")));
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 500,
      maxHeight: 500,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    await _uploadImageToServer(pickedFile);
  }

  void _showImageSourcePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              // บน laptop/web ImageSource.gallery จะเปิดหน้าต่างเลือกไฟล์ในเครื่อง
              ListTile(
                leading: Icon(
                  _isDesktopOrWeb ? Icons.folder_open : Icons.photo_library,
                ),
                title: Text(
                  _isDesktopOrWeb ? 'เลือกไฟล์จากเครื่อง' : 'เลือกจากแกลเลอรี่',
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              // แสดงปุ่มกล้องเฉพาะเครื่องที่รองรับ (desktop ไม่รองรับกล้อง)
              if (_picker.supportsImageSource(ImageSource.camera))
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('ถ่ายภาพใหม่'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Profile'),
      ),
      body: Column(
        children: [
          (_isLoading)
              ? SizedBox.shrink()
              : ProfileAvatarWidget(
                  size: 60,
                  imageFileName: _imageFileName,
                  showCameraIcon: true,
                  onAvatarTap: () async {},
                  onCameraTap: () async {
                    _showImageSourcePicker(context);
                  },
                ),
        ],
      ),
    );
  }
}
