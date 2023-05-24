import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mode_render/ui/mode_item_widget.dart';

class ModeRowWidget extends MultiChildRenderObjectWidget {
  final double selectedIndex;
  final double horizontalDrag;
  final bool isAnimating;
  final ValueChanged<int> onIndexChanged;

  const ModeRowWidget({
    super.key,
    required List<ModeItemWidget> super.children,
    required this.selectedIndex,
    required this.horizontalDrag,
    required this.isAnimating,
    required this.onIndexChanged,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderModeRow(
      selectedIndex: selectedIndex,
      isAnimating: isAnimating,
      horizontalDrag: horizontalDrag,
      onIndexChanged: onIndexChanged,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderObject renderObject) {
    if (renderObject is RenderModeRow) {
      renderObject
        ..selectedIndex = selectedIndex
        ..isAnimating = isAnimating
        ..horizontalDrag = horizontalDrag
        ..onIndexChanged = onIndexChanged;
    }
  }
}

class RenderModeRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, FlexParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, FlexParentData> {
  double _selectedIndex;
  double _horizontalDrag;
  ValueChanged<int> _onIndexChanged;
  bool _isAnimating;

  RenderModeRow({
    required double selectedIndex,
    required double horizontalDrag,
    required bool isAnimating,
    required ValueChanged<int> onIndexChanged,
  })  : _selectedIndex = selectedIndex,
        _horizontalDrag = horizontalDrag,
        _isAnimating = isAnimating,
        _onIndexChanged = onIndexChanged;

  double get selectedIndex => _selectedIndex;
  set selectedIndex(double value) {
    if (_selectedIndex == value) {
      return;
    }
    _selectedIndex = value;
    markNeedsLayout();
  }

  double get horizontalDrag => _horizontalDrag;
  set horizontalDrag(double value) {
    if (_horizontalDrag == value) {
      return;
    }
    _horizontalDrag = value;
    markNeedsLayout();
  }

  ValueChanged<int> get onIndexChanged => _onIndexChanged;
  set onIndexChanged(ValueChanged<int> value) {
    if (_onIndexChanged == value) {
      return;
    }
    _onIndexChanged = value;
    markNeedsLayout();
  }

  bool get isAnimating => _isAnimating;
  set isAnimating(bool value) {
    if (_isAnimating == value) {
      return;
    }
    _isAnimating = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! FlexParentData) {
      child.parentData = FlexParentData();
    }
  }

  @override
  void performLayout() {
    size = _performLayout(constraints: constraints, dry: false);

    final children = getChildrenAsList();
    final truncatedIndex = selectedIndex.truncate();
    final indexRemainder = selectedIndex - truncatedIndex;

    if (!isAnimating) {
      _checkOnIndexChanged(children: children, index: truncatedIndex);
    }

    final residualDistance = indexRemainder *
        _getDistanceToNext(
          children: children,
          index: truncatedIndex,
        );

    var forwarddOffset = Offset(size.width / 2 - residualDistance, 0);
    var backOffset = forwarddOffset;
    for (var i = truncatedIndex; i < children.length; i++) {
      final child = children[i];
      final childParentData = child.parentData as FlexParentData;
      late double dx;
      if (i == truncatedIndex) {
        final childHalfWidth = child.size.width / 2;
        dx = forwarddOffset.dx - childHalfWidth;
        forwarddOffset += Offset(childHalfWidth, 0);
        backOffset -= Offset(childHalfWidth, 0);
      } else {
        dx = forwarddOffset.dx;
        forwarddOffset += Offset(child.size.width, 0);
      }
      childParentData.offset = Offset(dx, _getCenterY(child));
    }
    for (var i = truncatedIndex - 1; i >= 0; i--) {
      final child = children[i];
      final childParentData = child.parentData as FlexParentData;
      backOffset -= Offset(child.size.width, 0);
      childParentData.offset = Offset(backOffset.dx, _getCenterY(child));
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    var child = firstChild;
    final clipRect = Offset.zero & size;
    while (child != null) {
      final childParentData = child.parentData as FlexParentData;
      context.pushClipRect(
        needsCompositing,
        offset,
        clipRect,
        (context, offset) {
          if (child == null) {
            return;
          }
          context.paintChild(child, childParentData.offset + offset);
        },
      );
      child = childParentData.nextSibling;
    }
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    return _performLayout(constraints: constraints, dry: true);
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToFirstActualBaseline(baseline);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  Size _performLayout({
    required BoxConstraints constraints,
    required bool dry,
  }) {
    var height = 0.0;

    var child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as FlexParentData;
      if (!dry) {
        child.layout(
          BoxConstraints(maxHeight: constraints.maxHeight),
          parentUsesSize: true,
        );
      } else {
        child.getDryLayout(BoxConstraints(maxHeight: constraints.maxHeight));
      }
      height = math.max(height, child.size.height);
      child = childParentData.nextSibling;
    }

    return Size(constraints.maxWidth, height);
  }

  double _getCenterY(RenderBox child) {
    return (size.height - child.size.height) / 2;
  }

  void _checkOnIndexChanged({
    required List<RenderBox> children,
    required int index,
  }) {
    final distance = _getDistanceToNext(
      children: children,
      index: index,
    );
    if (distance <= horizontalDrag.abs()) {
      final newIndex = index - horizontalDrag.sign.toInt();
      if (newIndex < 0 || newIndex >= children.length) {
        return;
      }
      onIndexChanged(newIndex);
    }
  }

  double _getDistanceToNext({
    required List<RenderBox> children,
    required int index,
  }) {
    final nextIndex = index + 1;
    if (nextIndex >= children.length) {
      return 0;
    }
    return (children[index].size.width + children[nextIndex].size.width) / 2;
  }
}
