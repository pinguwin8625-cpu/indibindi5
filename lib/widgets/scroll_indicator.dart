import 'package:flutter/material.dart';

class ScrollIndicator extends StatefulWidget {
  final Widget child;
  final ScrollController? scrollController;

  const ScrollIndicator({
    super.key,
    required this.child,
    this.scrollController,
  });

  @override
  State<ScrollIndicator> createState() => _ScrollIndicatorState();
}

class _ScrollIndicatorState extends State<ScrollIndicator> {
  bool _showIndicator = false;

  @override
  void initState() {
    super.initState();
    // Check scroll state after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInitialScroll();
    });
  }

  void _checkInitialScroll() {
    final controller = widget.scrollController;
    if (controller != null && controller.hasClients) {
      _updateIndicatorVisibility(controller.position);
    }
  }

  void _updateIndicatorVisibility(ScrollMetrics metrics) {
    if (!mounted) return;

    final maxScroll = metrics.maxScrollExtent;
    final currentScroll = metrics.pixels;
    
    // Only show indicator if:
    // 1. There's actually scrollable content (maxScroll > 0)
    // 2. We're not at the bottom (currentScroll < maxScroll - 50)
    final shouldShow = maxScroll > 0 && currentScroll < maxScroll - 50;
    
    if (shouldShow != _showIndicator) {
      setState(() {
        _showIndicator = shouldShow;
      });
    }
  }

  void _scrollDown() {
    final controller = widget.scrollController;
    
    if (controller != null && controller.hasClients) {
      final currentPosition = controller.offset;
      final maxScroll = controller.position.maxScrollExtent;
      final screenHeight = MediaQuery.of(context).size.height;
      
      // Scroll down by screen height or to the bottom
      final targetPosition = (currentPosition + screenHeight).clamp(0.0, maxScroll);
      
      controller.animateTo(
        targetPosition,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        if (notification is ScrollUpdateNotification || 
            notification is ScrollEndNotification) {
          _updateIndicatorVisibility(notification.metrics);
        }
        return false;
      },
      child: Stack(
        children: [
          widget.child,
          if (_showIndicator)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: IgnorePointer(
                ignoring: false,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _showIndicator ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 300),
                    child: GestureDetector(
                      onTap: _scrollDown,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
