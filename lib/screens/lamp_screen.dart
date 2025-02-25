// lamp_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import '../widgets/lamp_widget.dart';


class LampScreen extends StatefulWidget {
  const LampScreen({Key? key}) : super(key: key);

  @override
  State<LampScreen> createState() => _LampScreenState();
}

class _LampScreenState extends State<LampScreen> with SingleTickerProviderStateMixin {
  double _brightness = 0.7;
  bool _isLampOn = true;
  double _pullDownValue = 0.0;
  final double _toggleThreshold = 0.4;
  late AnimationController _controller;
  Timer? _autoOffTimer;
  bool _isAutoOffEnabled = false;
  int _autoOffDuration = 30; // minutes
  Color _currentColor = Colors.amber;
  bool _isColorPickerVisible = false;

  final List<Color> _predefinedColors = [
    Colors.amber,
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.pink,
    Colors.orange,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _autoOffTimer?.cancel();
    super.dispose();
  }

  void _handlePullUpdate(double val) {
    setState(() {
      _pullDownValue = val;
      if (_pullDownValue > _toggleThreshold && !_isLampOn) {
        _turnLampOn();
      } else if (_pullDownValue <= _toggleThreshold && _isLampOn && val < 0.1) {
        _turnLampOff();
      }
    });
  }

  void _turnLampOn() {
    setState(() {
      _isLampOn = true;
      _controller.forward();
      // Provide haptic feedback
      HapticFeedback.mediumImpact();
    });
    _startAutoOffTimer();
  }

  void _turnLampOff() {
    setState(() {
      _isLampOn = false;
      _controller.reverse();
      // Provide haptic feedback
      HapticFeedback.lightImpact();
    });
    _autoOffTimer?.cancel();
  }

  void _startAutoOffTimer() {
    if (_isAutoOffEnabled) {
      _autoOffTimer?.cancel();
      _autoOffTimer = Timer(Duration(minutes: _autoOffDuration), () {
        _turnLampOff();
      });
    }
  }

  void _showAutoOffDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Auto-off Timer', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Enable Auto-off', style: TextStyle(color: Colors.white70)),
              value: _isAutoOffEnabled,
              onChanged: (value) {
                setState(() {
                  _isAutoOffEnabled = value;
                  if (value) {
                    _startAutoOffTimer();
                  } else {
                    _autoOffTimer?.cancel();
                  }
                });
                Navigator.pop(context);
              },
            ),
            if (_isAutoOffEnabled) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Duration: $_autoOffDuration min', style: const TextStyle(color: Colors.white70)),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.white70),
                        onPressed: () {
                          setState(() {
                            if (_autoOffDuration > 5) _autoOffDuration -= 5;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white70),
                        onPressed: () {
                          setState(() {
                            _autoOffDuration += 5;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _isColorPickerVisible ? 120 : 0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _isColorPickerVisible ? 1.0 : 0.0,
        child: Container(
          margin: const EdgeInsets.only(top: 20),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _predefinedColors.map((color) {
                final isSelected = _currentColor == color;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentColor = color;
                        _isColorPickerVisible = false;
                      });
                      HapticFeedback.lightImpact();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isSelected ? 60 : 50,
                      height: isSelected ? 60 : 50,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.white24,
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.5),
                            blurRadius: isSelected ? 20 : 10,
                            spreadRadius: isSelected ? 4 : 2,
                          ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 24)
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E),
              const Color(0xFF0F3460),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Smart Pull Lamp',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.timer, color: Colors.white),
                      onPressed: _showAutoOffDialog,
                    ),
                  ],
                ),
              ),
              if (_isAutoOffEnabled)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Auto-off in $_autoOffDuration minutes',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                ),
              const Spacer(),
              Stack(
                alignment: Alignment.center,
                children: [
                  LampWidget(
                    isLampOn: _isLampOn,
                    brightness: _brightness,
                    pullDownValue: _pullDownValue,
                    onPullUpdate: _handlePullUpdate,
                    color: _currentColor,
                  ),
                  if (_pullDownValue == 0 && !_isLampOn)
                    Positioned(
                      bottom: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.arrow_downward, color: Colors.white70, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Pull to toggle lamp',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2746).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.wb_sunny_outlined,
                                color: _currentColor.withOpacity(0.9),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Brightness',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.palette_outlined,
                              color: _currentColor.withOpacity(0.9),
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _isColorPickerVisible = !_isColorPickerVisible;
                              });
                              HapticFeedback.lightImpact();
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: _currentColor,
                        inactiveTrackColor: Colors.grey.shade700,
                        thumbColor: _currentColor,
                        overlayColor: _currentColor.withOpacity(0.2),
                      ),
                      child: Slider(
                        min: 0.0,
                        max: 1.0,
                        value: _brightness,
                        onChanged: _isLampOn
                            ? (val) => setState(() => _brightness = val)
                            : null,
                      ),
                    ),
                    _buildColorPicker(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}