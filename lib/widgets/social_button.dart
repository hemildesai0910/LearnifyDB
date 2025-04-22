import 'package:flutter/material.dart';

class SocialButton extends StatelessWidget {
  final String icon;
  final VoidCallback? onTap;
  final bool isLoading;

  const SocialButton({
    Key? key,
    required this.icon,
    this.onTap,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
            : Image.asset(
                icon,
                height: 24,
                width: 24,
              ),
      ),
    );
  }
} 