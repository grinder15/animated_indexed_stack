library animated_indexed_stack;

import 'package:flutter/material.dart';

typedef IndexedStackTransitionBuilder = Widget Function(
    Widget child, Animation animation);

class AnimatedIndexedStack extends StatefulWidget {
  const AnimatedIndexedStack({
    Key key,
    @required this.index,
    @required this.children,
    @required this.transitionBuilder,
    this.duration = const Duration(
      milliseconds: 300,
    ),
    this.lazy = false,
  })  : assert(index != null),
        assert(children != null),
        assert(transitionBuilder != null),
        assert(duration != null),
        super(key: key);

  final int index;
  final List<Widget> children;
  final Duration duration;
  final IndexedStackTransitionBuilder transitionBuilder;
  final bool lazy;

  @override
  _AnimatedIndexedStackState createState() => _AnimatedIndexedStackState();
}

class _AnimatedIndexedStackState extends State<AnimatedIndexedStack>
    with TickerProviderStateMixin {
  List<_ChildEntry> _children;
  Set<int> _setIndexes = {};
  Set<int> _activeIndexes = {};

  @override
  void initState() {
    super.initState();
    _setNewChildrenList();
    assert(_children.isNotEmpty);
    // initial complete the animation.
    if (widget.index != null) {
      if (widget.lazy) _addIndexToSet(widget.index);
      _activeIndexes.add(widget.index);
      _children[widget.index].controller.value = 1.0;
    }
  }

  void _addIndexToSet(int index) {
    _setIndexes.add(index);
  }

  void _setNewChildrenList() {
    _children = widget.children
        .asMap()
        .map(
          (index, child) {
            // create animation controller
            final _controller = AnimationController(
              vsync: this,
              duration: widget.duration,
            );

            _controller.addStatusListener((status) {
              if (status == AnimationStatus.dismissed) {
                setState(() {
                  _activeIndexes.remove(index);
                });
              }
            });

            return MapEntry(
              index,
              _ChildEntry(
                index: index,
                controller: _controller,
                widgetChild: child,
              ),
            );
          },
        )
        .values
        .toList();
  }

  void _animateChild(_ChildEntry _childEntry, {bool exit = false}) {
    //print('Animating child entry ${_childEntry.index}, exit: $exit');
    // animate the child
    if (exit) {
      // play exit animation
      _childEntry.controller.reverse();
    } else {
      // play enter animation
      _childEntry.controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedIndexedStack oldWidget) {
    //print('didUpdateWidget called');
    assert(widget.lazy == oldWidget.lazy,
        "You can't change lazy parameter in rebuild.");
    super.didUpdateWidget(oldWidget);

    // recreate all children entries whenever the list length is different or
    // duration is different
    if (widget.children.length != _children.length ||
        widget.duration != oldWidget.duration) {
      //print('children length or duration change');

      // if lazy and there is a change, reset all indexes.
      if (widget.lazy) _setIndexes.clear();
      _activeIndexes.clear();

      // dispose children first.
      _disposeChildren();
      // update all children entries
      _setNewChildrenList();
      // play animation
      if (widget.index != null) {
        _activeIndexes.add(widget.index);
        _animateChild(_children[widget.index]);
      }
      // Note: we dont need to setState here cuz we will not perform exit animation
      // for the previous active index. save build cost.
      return;
    }

    assert(widget.children.length == oldWidget.children.length,
        "You changed the children but isn't refreshed");

    // update children.
    _updateChildren(widget.children);

    if (widget.index != oldWidget.index) {
      //print('index change');
      // animate!
      // if the new index is null dont animate in!
      if (widget.index != null) {
        // if lazy, cache that index
        if (widget.lazy) _addIndexToSet(widget.index);
        _activeIndexes.add(widget.index);
        _animateChild(_children[widget.index]);
      }
      if (oldWidget.index != null) {
        _activeIndexes.add(oldWidget.index);
        _animateChild(_children[oldWidget.index], exit: true);
      }
    }
  }

  void _disposeChildren() {
    //print('dispose all children');
    for (final _child in _children) {
      _child.dispose();
    }
  }

  void _updateChildren(List<Widget> newChildren) {
    for (int i = 0; i < newChildren.length; i++) {
      _children[i].widgetChild = newChildren[i];
    }
  }

  @override
  void dispose() {
    _disposeChildren();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _children.map(
        (child) {
          Widget transition;
          if (widget.lazy) {
            transition = widget.transitionBuilder(
              // check if it is already set index.
              _setIndexes.contains(child.index)
                  ? child.widgetChild
                  : Container(),
              child.controller,
            );
          } else {
            transition = widget.transitionBuilder(
              child.widgetChild,
              child.controller,
            );
          }
          assert(
            transition != null,
            'AnimatedIndexedStack.transitionBuilder must not return null.',
          );
          return Offstage(
            offstage: !_activeIndexes.contains(child.index),
            child: transition,
          );
        },
      ).toList(),
    );
  }
}

class _ChildEntry {
  _ChildEntry({
    @required this.index,
    @required this.controller,
    @required this.widgetChild,
  })  : assert(index != null),
        assert(controller != null),
        assert(widgetChild != null);

  final int index;

  final AnimationController controller;

  Widget widgetChild;

  void dispose() {
    controller.dispose();
  }
}
