import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppImage extends StatelessWidget {
  const AppImage({super.key,required this.image,this.width,this.height, this.personImage,  this.fit});

 final String image;
 final bool? personImage;
 final double? height;
 final double? width;
 final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: image,
      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => personImage != null ? const Icon(Icons.person) :  Image.asset('assets/images/logo.png'),
      fit: fit ?? BoxFit.cover,
      width: width ??  60, // 2 * radius
      height: height ?? 60, // 2 * radius
    );
  }
}
