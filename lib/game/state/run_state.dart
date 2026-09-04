import 'package:flutter/foundation.dart';

import '../game_config.dart';

class RunState extends ChangeNotifier {
  int wood = 0;
  int stone = 0;
  int currentHeight = 1;
  int peakHeight = 1;
  int enemiesKilled = 0;

  double timeSurvived = 0;
  double playerHealth = GameConfig.playerMaxHealth;
  double towerHealth = GameConfig.towerBaseHealth;
  double towerMaxHealth = GameConfig.towerBaseHealth;
  double shieldCooldownRemaining = 0;
  bool shieldActive = false;
  bool nearTower = false;
  bool gameOver = false;

  bool get hasBuildResources =>
      wood >= GameConfig.buildWoodCost && stone >= GameConfig.buildStoneCost;

  bool get canBuild => hasBuildResources && nearTower && !gameOver;

  void reset() {
    wood = 0;
    stone = 0;
    currentHeight = 1;
    peakHeight = 1;
    enemiesKilled = 0;
    timeSurvived = 0;
    playerHealth = GameConfig.playerMaxHealth;
    towerHealth = GameConfig.towerBaseHealth;
    towerMaxHealth = GameConfig.towerBaseHealth;
    shieldCooldownRemaining = 0;
    shieldActive = false;
    nearTower = false;
    gameOver = false;
    notifyListeners();
  }

  void tick(double dt) {
    if (gameOver) {
      return;
    }
    timeSurvived += dt;
  }

  void addResource(ResourceKind kind, int amount) {
    if (kind == ResourceKind.wood) {
      wood += amount;
    } else {
      stone += amount;
    }
    notifyListeners();
  }

  bool spendBuildCost() {
    if (!hasBuildResources) {
      return false;
    }
    wood -= GameConfig.buildWoodCost;
    stone -= GameConfig.buildStoneCost;
    notifyListeners();
    return true;
  }

  void recordBuild(double healthAdded) {
    currentHeight += 1;
    if (currentHeight > peakHeight) {
      peakHeight = currentHeight;
    }
    towerMaxHealth += healthAdded;
    towerHealth = (towerHealth + healthAdded)
        .clamp(0, towerMaxHealth)
        .toDouble();
    notifyListeners();
  }

  void setPlayerHealth(double value) {
    playerHealth = value.clamp(0, GameConfig.playerMaxHealth).toDouble();
    notifyListeners();
  }

  void setTowerHealth(double value) {
    towerHealth = value.clamp(0, towerMaxHealth).toDouble();
    notifyListeners();
  }

  void setNearTower(bool value) {
    if (nearTower == value) {
      return;
    }
    nearTower = value;
    notifyListeners();
  }

  void setShieldStatus({required bool active, required double cooldown}) {
    final double roundedCooldown = (cooldown * 20).ceil() / 20;
    if (shieldActive == active && shieldCooldownRemaining == roundedCooldown) {
      return;
    }
    shieldActive = active;
    shieldCooldownRemaining = roundedCooldown;
    notifyListeners();
  }

  void recordKill() {
    enemiesKilled += 1;
    notifyListeners();
  }

  void finishRun() {
    if (gameOver) {
      return;
    }
    gameOver = true;
    notifyListeners();
  }
}

enum ResourceKind { wood, stone }
