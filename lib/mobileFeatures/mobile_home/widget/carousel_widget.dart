import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:merinocizgi/core/theme/colors.dart';

class CarouselWidget extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final double height;
  final VoidCallback? onSeeMore;

  const CarouselWidget({
    super.key,
    required this.title,
    required this.children,
    this.height = 250,
    this.onSeeMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: GoogleFonts.oswald(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              // if (onSeeMore != null)
              GestureDetector(
                onTap: onSeeMore,
                child: Text(
                  'Daha fazla',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: height,
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(width: 16);
            },
            padding: const EdgeInsets.only(left: 16),
            scrollDirection: Axis.horizontal,
            itemCount: children.length,
            itemBuilder: (BuildContext context, int index) {
              final child = children[index];
              return child;
            },
          ),
        ),
      ],
    );
  }
}
