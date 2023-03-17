import 'package:flutter/material.dart';
import 'package:scala_editor/filter_item.dart';

class FilterSelector extends StatefulWidget {
  const FilterSelector({
    Key? key,
    required this.onFilterChange,
    required this.filters,
    this.padding = const EdgeInsets.symmetric(vertical: 24.0),
  }) : super(key: key);
  final EdgeInsets padding;
  final Function onFilterChange;
  final List<Color> filters;
  @override
  State<FilterSelector> createState() => _FilterSelectorState();
}

class _FilterSelectorState extends State<FilterSelector> {
  static const _filtersPerScreen = 5;
  static const _viewPortFractionPerItem = 1 / _filtersPerScreen;
  late final PageController _controller;

  @override
  void initState() {
    _controller = PageController(viewportFraction: _viewPortFractionPerItem);
    _controller.addListener(_onPageChanged);
    super.initState();
  }

  void _onPageChanged() {
    int page = (_controller.page ?? 0).round();
    widget.onFilterChange(widget.filters[page]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // getting the size for each filter
        final itemSize = constraints.maxWidth * _viewPortFractionPerItem;
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _buildShadowGradient(itemSize),
            _buildCarousel(itemSize),
            _buildSelectionRing(itemSize),
          ],
        );
      },
    );
  }

  Widget _buildCarousel(double itemSize) {
    return Container(
      height: itemSize,
      margin: widget.padding,
      child: PageView.builder(
        controller: _controller,
        itemCount: 7,
        itemBuilder: (_, position) {
          return AnimatedBuilder(
            animation: _controller,
            builder: (_, child) {
              if (!_controller.hasClients ||
                  !_controller.position.hasContentDimensions) {
                // The PageViewController isn’t connected to the
                // PageView widget yet. Return an empty box.
                return const SizedBox();
              }
              // The integer index of the current page,
              // 0, 1, 2, 3, and so on
              final selectedIndex = _controller.page!.roundToDouble();
              // The fractional amount that the current filter
              // is dragged to the left or right, for example, 0.25 when
              // the current filter is dragged 25% to the left.
              final pageScrollAmount = _controller.page! - selectedIndex;
              // The page-distance of a filter just before it
              // moves off-screen.
              const maxScrollDistance = _filtersPerScreen / 2;
              // The page-distance of this filter item from the
              // currently selected filter item.
              final pageDistanceFromSelected =
              (selectedIndex - position + pageScrollAmount).abs();
              // The distance of this filter item from the
              // center of the carousel as a percentage, that is, where the selector
              // ring sits.
              final percentFromCenter =
                  1.0 - pageDistanceFromSelected / maxScrollDistance;

              final itemScale = 0.5 + (percentFromCenter * 0.5);
              final opacity = 0.25 + (percentFromCenter * 0.75);
              return Transform.scale(
                scale: itemScale,
                child: Opacity(
                  opacity: opacity ?? 0,
                  child: FilterItem(
                    color: widget.filters[position],
                    onFilterSelected: () => _onFilterTapped,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _onFilterTapped(int index) {
    _controller.animateToPage(
      index,
      duration: kThemeAnimationDuration,
      curve: Curves.ease,
    );
  }

  Widget _buildShadowGradient(double itemSize) {
    return SizedBox(
      height: itemSize * 2 + widget.padding.vertical,
      child: const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.transparent, Colors.black],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: SizedBox.expand(),
      ),
    );
  }

  Widget _buildSelectionRing(double itemSize) {
    return IgnorePointer(
      child: Padding(
        padding: widget.padding,
        child: SizedBox(
          height: itemSize,
          width: itemSize,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.fromBorderSide(
                BorderSide(
                  color: Colors.white,
                  width: 6,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
