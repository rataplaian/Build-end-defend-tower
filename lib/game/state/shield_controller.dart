class ShieldController {
  ShieldController({required this.maxDuration, required this.cooldownDuration});

  final double maxDuration;
  final double cooldownDuration;

  bool isActive = false;
  double activeTime = 0;
  double cooldownRemaining = 0;

  bool tryActivate() {
    if (isActive || cooldownRemaining > 0) {
      return false;
    }
    isActive = true;
    activeTime = 0;
    return true;
  }

  void lower() {
    if (!isActive) {
      return;
    }
    isActive = false;
    activeTime = 0;
    cooldownRemaining = cooldownDuration;
  }

  void update(double dt) {
    if (cooldownRemaining > 0) {
      final double remaining = cooldownRemaining - dt;
      cooldownRemaining = remaining <= 0.000001
          ? 0
          : remaining.clamp(0, cooldownDuration).toDouble();
    }
    if (!isActive) {
      return;
    }
    activeTime += dt;
    if (activeTime >= maxDuration) {
      lower();
    }
  }

  void reset() {
    isActive = false;
    activeTime = 0;
    cooldownRemaining = 0;
  }
}
