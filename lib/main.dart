import 'package:flutter/material.dart';
import 'package:flutter_mode_render/ui/mode_item_widget.dart';
import 'package:flutter_mode_render/ui/mode_row_widget.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  static const textStyle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );
  static const selectedTextStyle = TextStyle(
    color: Colors.yellow,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
  var _selectedIndex = 0;
  var _horizontalDrag = 0.0;
  Animation<double>? _animation;

  late final _animationController = AnimationController(
    vsync: this,
    duration: kTabScrollDuration,
  );
  late final _curve = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          color: Colors.blueGrey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 150),
            child: Center(
              child: AbsorbPointer(
                absorbing: _animationController.isAnimating,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() => _horizontalDrag += details.delta.dx);
                  },
                  child: ModeRowWidget(
                    selectedIndex:
                        _animation?.value ?? _selectedIndex.toDouble(),
                    isAnimating: _animationController.isAnimating,
                    horizontalDrag: _horizontalDrag,
                    onIndexChanged: _onIndexChange,
                    children: [
                      ModeItemWidget<int>(
                        value: 0,
                        groupValue: _selectedIndex,
                        text: 'VIDEO',
                        textStyle: MainApp.textStyle,
                        selectedTextStyle: MainApp.selectedTextStyle,
                        spacing: 10,
                        onChanged: _onChange,
                      ),
                      ModeItemWidget<int>(
                        value: 1,
                        groupValue: _selectedIndex,
                        text: 'PHOTO',
                        textStyle: MainApp.textStyle,
                        selectedTextStyle: MainApp.selectedTextStyle,
                        spacing: 10,
                        onChanged: _onChange,
                      ),
                      ModeItemWidget<int>(
                        value: 2,
                        groupValue: _selectedIndex,
                        text: 'SLOW-MO',
                        textStyle: MainApp.textStyle,
                        selectedTextStyle: MainApp.selectedTextStyle,
                        spacing: 10,
                        onChanged: _onChange,
                      ),
                      ModeItemWidget<int>(
                        value: 3,
                        groupValue: _selectedIndex,
                        text: 'TIME-LAPSE',
                        textStyle: MainApp.textStyle,
                        selectedTextStyle: MainApp.selectedTextStyle,
                        spacing: 10,
                        onChanged: _onChange,
                      ),
                      ModeItemWidget<int>(
                        value: 4,
                        groupValue: _selectedIndex,
                        text: 'PARALLAX',
                        textStyle: MainApp.textStyle,
                        selectedTextStyle: MainApp.selectedTextStyle,
                        spacing: 10,
                        onChanged: _onChange,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onChange(int value) {
    if (_selectedIndex == value) {
      return;
    }
    _horizontalDrag = 0;
    _animation?.removeListener(_updateSate);
    _animation = Tween<double>(
      begin: _selectedIndex.toDouble(),
      end: value.toDouble(),
    ).animate(_curve)
      ..addListener(() => _updateSate());
    _selectedIndex = value;
    _animationController.reset();
    _animationController.forward();
    debugPrint('onChange: $value');
  }

  void _onIndexChange(int value) {
    debugPrint('onIndexChange: $value');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onChange(value);
    });
  }

  void _updateSate() {
    setState(() {});
  }
}
