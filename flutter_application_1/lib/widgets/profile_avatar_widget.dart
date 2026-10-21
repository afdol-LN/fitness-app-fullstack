import 'package:flutter/material.dart';
import 'package:flutter_application_1/config/app.config.dart';

class ProfileAvatarWidget extends StatefulWidget {
  final double size;
  final VoidCallback onAvatarTap;

  final bool showCameraIcon;
  final VoidCallback? onCameraTap;
  final String? imageFileName;

  const ProfileAvatarWidget({
    super.key,
    required this.size,
    required this.onAvatarTap,
    required this.imageFileName,
    this.showCameraIcon = false,
    this.onCameraTap,
  });

  @override
  State<ProfileAvatarWidget> createState() => _ProfileAvatarWidgetState();
}

class _ProfileAvatarWidgetState extends State<ProfileAvatarWidget> {
  String? _imageUrl;

  void _updateImageUrl() {
    final fileName = widget.imageFileName;

    setState(() {
      _imageUrl = (fileName == null || fileName.isEmpty)
          ? null
          : "${AppConfig.imageBaseApi}/$fileName";
    });
  }

  @override
  void initState() {
    super.initState();
    _updateImageUrl();
  }

  @override
  void didUpdateWidget(covariant ProfileAvatarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageFileName != widget.imageFileName) {
      _updateImageUrl();
    }
  }

  Widget _getCameraIcon() {
    if (!widget.showCameraIcon) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 0,
      right: 0,
      child: GestureDetector(
        onTap: widget.onCameraTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.brown,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.camera_alt,
            color: Colors.white,
            size: widget.size * 0.25,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: widget.onAvatarTap,
            child: CircleAvatar(
              radius: widget.size,
              backgroundColor: Colors.grey[400],
              backgroundImage: (_imageUrl != null && _imageUrl!.isNotEmpty)
                  ? NetworkImage(_imageUrl!)
                  : null,
              onBackgroundImageError:
                  (_imageUrl != null && _imageUrl!.isNotEmpty)
                  ? (exception, stackTrace) {
                      debugPrint("Load avatar failed: $exception");
                    }
                  : null,
              child: (_imageUrl == null || _imageUrl!.isEmpty)
                  ? Icon(
                      Icons.person,
                      size: widget.size,
                      color: Colors.grey[600],
                    )
                  : null,
            ),
          ),

          _getCameraIcon(),
        ],
      ),
    );
  }
}
