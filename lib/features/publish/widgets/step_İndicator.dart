import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class StepIndicator extends StatelessWidget {
  final List<String> steps;
  final int currentStep;
  final Color activeColor;
  final Color inactiveColor;
  final double circleSize;
  final double borderWidth;
  final double lineThickness;
  // final void Function(int)? onStepTapped; // ← yeni

  const StepIndicator({
    required this.steps,
    this.currentStep = 0,
    this.activeColor = Colors.green,
    this.inactiveColor = Colors.grey,
    this.circleSize = 32.0,
    this.borderWidth = 3.0,
    this.lineThickness = 4.0,
    // this.onStepTapped, // ← yeni
  });

  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _buildSteps(),
    );
  }

  List<Widget> _buildSteps() {
    final widgets = <Widget>[];

    for (var i = 0; i < steps.length; i++) {
      final bool isActive = i == currentStep;
      final bool isDone = i < currentStep;

      // Circle with outline
      widgets.add(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: circleSize,
              height: circleSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDone || isActive) ? activeColor : Colors.white,
                border: Border.all(
                  color: (isDone || isActive) ? activeColor : inactiveColor,
                  width: borderWidth,
                ),
              ),
              child: Text(
                '${i + 1}',
                style: TextStyle(
                  color: (isDone || isActive) ? Colors.white : inactiveColor,
                  fontWeight: FontWeight.bold,
                  fontSize: circleSize * 0.5,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              steps[i],
              style: TextStyle(
                fontSize: 12,
                color: (isDone || isActive) ? activeColor : inactiveColor,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      );

      // Connector line (no arrow)
      if (i < steps.length - 1) {
        widgets.add(
          Container(
            width: circleSize / 2,
            height: lineThickness,
            color: isDone ? activeColor : inactiveColor,
            margin: const EdgeInsets.symmetric(horizontal: 8.0),
          ),
        );
      }
    }

    return widgets;
  }
}

// Kullanım:
// StepIndicator(
//   steps: ['Series', 'Episodes', 'Review'],
//   currentStep: 1,
//   activeColor: Colors.green,
//   inactiveColor: Colors.grey.shade300,
//   circleSize: 36,
//   borderWidth: 4,
//   lineThickness: 5,
// );
