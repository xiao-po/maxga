// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';


const Duration _kUnconfirmedSplashDuration = Duration(milliseconds: 200);
const Duration _kSplashFadeDuration = Duration(milliseconds: 500);

const double _kSplashInitialSize = 0.0; // logical pixels
const double _kSplashConfirmedVelocity = 2.5; // logical pixels per millisecond

RectCallback _getClipCallback(RenderBox referenceBox, bool containedInkWell, RectCallback rectCallback) {
  if (rectCallback != null) {
    assert(containedInkWell);
    return rectCallback;
  }
  if (containedInkWell)
    return () => Offset.zero & referenceBox.size;
  return null;
}

double _getTargetRadius(RenderBox referenceBox, bool containedInkWell, RectCallback rectCallback, Offset position) {
  if (containedInkWell) {
    final Size size = rectCallback != null ? rectCallback().size : referenceBox.size;
    return _getSplashRadiusForPositionInSize(size, position);
  }
  return Material.defaultSplashRadius;
}

double _getSplashRadiusForPositionInSize(Size bounds, Offset position) {
  final double d1 = (position - bounds.topLeft(Offset.zero)).distance;
  final double d2 = (position - bounds.topRight(Offset.zero)).distance;
  final double d3 = (position - bounds.bottomLeft(Offset.zero)).distance;
  final double d4 = (position - bounds.bottomRight(Offset.zero)).distance;
  return math.max(math.max(d1, d2), math.max(d3, d4)).ceilToDouble();
}

class _InkSplashFactory extends InteractiveInkFeatureFactory {
  const _InkSplashFactory();

  @override
  InteractiveInkFeature create({
    @required MaterialInkController controller,
    @required RenderBox referenceBox,
    @required Offset position,
    @required Color color,
    @required TextDirection textDirection,
    bool containedInkWell = false,
    RectCallback rectCallback,
    BorderRadius borderRadius,
    ShapeBorder customBorder,
    double radius,
    VoidCallback onRemoved,
  }) {
    return CustomInkSplash(
      controller: controller,
      referenceBox: referenceBox,
      position: position,
      color: color,
      containedInkWell: containedInkWell,
      rectCallback: rectCallback,
      borderRadius: borderRadius,
      customBorder: customBorder,
      radius: radius,
      onRemoved: onRemoved,
      textDirection: textDirection,
    );
  }
}

class CustomInkSplash extends InteractiveInkFeature {
  CustomInkSplash({
    @required MaterialInkController controller,
    @required RenderBox referenceBox,
    @required TextDirection textDirection,
    Offset position,
    Color color,
    bool containedInkWell = false,
    RectCallback rectCallback,
    BorderRadius borderRadius,
    ShapeBorder customBorder,
    double radius,
    VoidCallback onRemoved,
  }) : assert(textDirection != null),
        _position = position,
        _borderRadius = borderRadius ?? BorderRadius.zero,
        _customBorder = customBorder,
        _targetRadius = radius ?? _getTargetRadius(referenceBox, containedInkWell, rectCallback, position),
        _clipCallback = _getClipCallback(referenceBox, containedInkWell, rectCallback),
        _repositionToReferenceBox = !containedInkWell,
        _textDirection = textDirection,
        super(controller: controller, referenceBox: referenceBox, color: color, onRemoved: onRemoved) {
    assert(_borderRadius != null);
    _radiusController = AnimationController(duration: _kUnconfirmedSplashDuration, vsync: controller.vsync)
      ..addListener(controller.markNeedsPaint)
      ..forward();
    _radius = _radiusController.drive(Tween<double>(
      begin: _kSplashInitialSize,
      end: _targetRadius,
    ));
    _alphaController = AnimationController(duration: _kSplashFadeDuration, vsync: controller.vsync)
      ..addListener(controller.markNeedsPaint)
      ..addStatusListener(_handleAlphaStatusChanged);
    _alpha = _alphaController.drive(IntTween(
      begin: color.alpha,
      end: 0,
    ));

    controller.addInkFeature(this);
  }

  final Offset _position;
  final BorderRadius _borderRadius;
  final ShapeBorder _customBorder;
  final double _targetRadius;
  final RectCallback _clipCallback;
  final bool _repositionToReferenceBox;
  final TextDirection _textDirection;

  Animation<double> _radius;
  AnimationController _radiusController;

  Animation<int> _alpha;
  AnimationController _alphaController;

  /// Used to specify this type of ink splash for an [InkWell], [InkResponse]
  /// or material [Theme].
  static const InteractiveInkFeatureFactory splashFactory = _InkSplashFactory();

  @override
  void confirm() {
    final int duration = (_targetRadius / _kSplashConfirmedVelocity).floor();
    _radiusController
      ..duration = Duration(milliseconds: duration)
      ..forward();
    _alphaController.forward();
  }

  @override
  void cancel() {
    _alphaController?.forward();
  }

  void _handleAlphaStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed)
      dispose();
  }

  @override
  void dispose() {
    _radiusController.dispose();
    _alphaController.dispose();
    _alphaController = null;
    super.dispose();
  }

  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {
    final Paint paint = Paint()..color = color.withAlpha(_alpha.value);
    Offset center = _position;
    if (_repositionToReferenceBox)
      center = Offset.lerp(center, referenceBox.size.center(Offset.zero), _radiusController.value);
    final Offset originOffset = MatrixUtils.getAsTranslation(transform);
    canvas.save();
    if (originOffset == null) {
      canvas.transform(transform.storage);
    } else {
      canvas.translate(originOffset.dx, originOffset.dy);
    }
    if (_clipCallback != null) {
      final Rect rect = _clipCallback();
      if (_customBorder != null) {
        canvas.clipPath(_customBorder.getOuterPath(rect, textDirection: _textDirection));
      } else if (_borderRadius != BorderRadius.zero) {
        canvas.clipRRect(RRect.fromRectAndCorners(
          rect,
          topLeft: _borderRadius.topLeft, topRight: _borderRadius.topRight,
          bottomLeft: _borderRadius.bottomLeft, bottomRight: _borderRadius.bottomRight,
        ));
      } else {
        canvas.clipRect(rect);
      }
    }
    canvas.drawCircle(center, _radius.value, paint);
    canvas.restore();
  }
}
