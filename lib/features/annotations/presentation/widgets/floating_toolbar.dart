/// Floating Toolbar Widget
///
/// Yatay, sürüklenebilir, minimal tasarım.
/// Flexcil benzeri soft görünüm.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf_annotator/features/annotations/domain/entities/drawing_tool.dart';
import 'package:pdf_annotator/features/annotations/presentation/providers/drawing_provider.dart';

class FloatingToolbar extends ConsumerStatefulWidget {
  final String documentId;
  final int pageNumber;

  const FloatingToolbar({
    super.key,
    required this.documentId,
    required this.pageNumber,
  });

  @override
  ConsumerState<FloatingToolbar> createState() => _FloatingToolbarState();
}

class _FloatingToolbarState extends ConsumerState<FloatingToolbar> {
  Offset _position = const Offset(50, 120);
  bool _isExpanded = true;
  bool _showColorPalette = false;
  bool _showStrokeWidth = false;

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(drawingControllerProvider);

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onPanUpdate: _onDrag,
            child: _isExpanded
                ? _buildExpandedToolbar(controller)
                : _buildCollapsedToolbar(),
          ),
          if (_isExpanded && _showColorPalette) _buildColorPanel(controller),
          if (_isExpanded && _showStrokeWidth)
            _buildStrokeWidthPanel(controller),
        ],
      ),
    );
  }

  void _onDrag(DragUpdateDetails details) {
    setState(() {
      _position += details.delta;
      final screenSize = MediaQuery.of(context).size;
      _position = Offset(
        _position.dx.clamp(0, screenSize.width - 300),
        _position.dy.clamp(0, screenSize.height - 200),
      );
    });
  }

  Widget _buildExpandedToolbar(DrawingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sürükleme tutamağı
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Icon(Icons.drag_indicator, color: Colors.grey, size: 18),
          ),

          _buildDivider(),

          // Araç butonları
          _ToolButton(
            icon: Icons.pan_tool_outlined,
            isSelected: controller.selectedTool == DrawingTool.none,
            onPressed: () {
              controller.selectTool(DrawingTool.none);
              _closeAllPanels();
            },
          ),
          _ToolButton(
            icon: Icons.edit,
            isSelected: controller.selectedTool == DrawingTool.pen,
            onPressed: () {
              controller.selectTool(DrawingTool.pen);
              _closeAllPanels();
            },
          ),
          _ToolButton(
            icon: Icons.highlight,
            isSelected: controller.selectedTool == DrawingTool.highlighter,
            onPressed: () {
              controller.selectTool(DrawingTool.highlighter);
              _closeAllPanels();
            },
          ),
          _ToolButton(
            icon: Icons.auto_fix_high,
            isSelected: controller.selectedTool == DrawingTool.eraser,
            onPressed: () {
              controller.selectTool(DrawingTool.eraser);
              _closeAllPanels();
            },
          ),

          _buildDivider(),

          // Renk butonu
          _ColorCircle(
            color: controller.selectedColor,
            size: 28,
            onTap: () => setState(() {
              _showColorPalette = !_showColorPalette;
              _showStrokeWidth = false;
            }),
            isSelected: _showColorPalette,
          ),

          const SizedBox(width: 4),

          // Kalınlık butonu
          _StrokeWidthCircle(
            width: controller.selectedTool == DrawingTool.highlighter
                ? controller.highlightWidth
                : controller.strokeWidth,
            onTap: () => setState(() {
              _showStrokeWidth = !_showStrokeWidth;
              _showColorPalette = false;
            }),
            isSelected: _showStrokeWidth,
          ),

          _buildDivider(),

          // Undo butonu
          _ToolButton(
            icon: Icons.undo,
            isSelected: false,
            onPressed: controller.canUndo ? () => controller.undo() : null,
            iconColor: controller.canUndo ? Colors.grey[600] : Colors.grey[300],
          ),

          // Redo butonu
          _ToolButton(
            icon: Icons.redo,
            isSelected: false,
            onPressed: controller.canRedo ? () => controller.redo() : null,
            iconColor: controller.canRedo ? Colors.grey[600] : Colors.grey[300],
          ),

          _buildDivider(),

          // Temizle butonu
          _ToolButton(
            icon: Icons.delete_outline,
            isSelected: false,
            onPressed: () => _confirmClearAll(controller),
            iconColor: Colors.red[400],
          ),

          // Küçült butonu
          _ToolButton(
            icon: Icons.keyboard_arrow_left,
            isSelected: false,
            onPressed: () => setState(() => _isExpanded = false),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedToolbar() {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = true),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.edit, size: 20, color: Colors.grey),
      ),
    );
  }

  Widget _buildColorPanel(DrawingController controller) {
    const colors = [
      Colors.black,
      Color(0xFF424242),
      Colors.red,
      Colors.orange,
      Colors.amber,
      Colors.green,
      Colors.teal,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
      Colors.pink,
      Colors.brown,
    ];

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: colors.map((color) {
          final isSelected = color.value == controller.selectedColor.value;
          return _ColorCircle(
            color: color,
            size: 28,
            isSelected: isSelected,
            showCheck: isSelected,
            onTap: () {
              controller.selectColor(color);
              setState(() => _showColorPalette = false);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStrokeWidthPanel(DrawingController controller) {
    final isHighlighter = controller.selectedTool == DrawingTool.highlighter;
    final widths = isHighlighter
        ? [10.0, 15.0, 20.0, 25.0, 30.0]
        : [1.0, 2.0, 4.0, 6.0, 10.0];
    final currentWidth = isHighlighter
        ? controller.highlightWidth
        : controller.strokeWidth;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: widths.map((width) {
          final isSelected = (currentWidth - width).abs() < 0.5;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                if (isHighlighter) {
                  controller.setHighlightWidth(width);
                } else {
                  controller.setStrokeWidth(width);
                }
                setState(() => _showStrokeWidth = false);
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey[300]!,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: width.clamp(3.0, 14.0),
                    height: width.clamp(3.0, 14.0),
                    decoration: BoxDecoration(
                      color: controller.selectedColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.grey[300],
    );
  }

  void _closeAllPanels() {
    setState(() {
      _showColorPalette = false;
      _showStrokeWidth = false;
    });
  }

  void _confirmClearAll(DrawingController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tümünü Sil'),
        content: const Text('Bu sayfadaki tüm çizimler silinecek. Emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.clearCurrentPage();
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onPressed;
  final Color? iconColor;

  const _ToolButton({
    required this.icon,
    required this.isSelected,
    required this.onPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: iconColor ?? (isSelected ? Colors.blue : Colors.grey[600]),
        ),
      ),
    );
  }
}

class _ColorCircle extends StatelessWidget {
  final Color color;
  final double size;
  final VoidCallback onTap;
  final bool isSelected;
  final bool showCheck;

  const _ColorCircle({
    required this.color,
    required this.size,
    required this.onTap,
    this.isSelected = false,
    this.showCheck = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: showCheck
            ? Icon(
                Icons.check,
                size: size * 0.6,
                color: color.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
              )
            : null,
      ),
    );
  }
}

class _StrokeWidthCircle extends StatelessWidget {
  final double width;
  final VoidCallback onTap;
  final bool isSelected;

  const _StrokeWidthCircle({
    required this.width,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Container(
            width: width.clamp(4.0, 12.0),
            height: width.clamp(4.0, 12.0),
            decoration: const BoxDecoration(
              color: Colors.black87,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
