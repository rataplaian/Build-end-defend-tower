import 'package:flutter/foundation.dart';

import '../game_config.dart';

class RunState extends ChangeNotifier {
  /// Resources stored safely at the tower and available for construction.
  int wood = 0;
  int stone = 0;
  int carriedWood = 0;
  int carriedStone = 0;
  int bagLevel = 1;
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

  int get carriedTotal => carriedWood + carriedStone;

  int get bagCapacity =>
      GameConfig.initialBagCapacity +
      (bagLevel - 1) * GameConfig.bagCapacityPerUpgrade;

  int get bagSpace => bagCapacity - carriedTotal;

  bool get bagFull => bagSpace <= 0;

  int get bagUpgradeWoodCost =>
      GameConfig.bagUpgradeBaseCost +
      (bagLevel - 1) * GameConfig.bagUpgradeCostIncrease;

  int get bagUpgradeStoneCost => bagUpgradeWoodCost;

  bool get hasBagUpgradeResources =>
      wood >= bagUpgradeWoodCost && stone >= bagUpgradeStoneCost;

  bool get canUpgradeBag => hasBagUpgradeResources && nearTower && !gameOver;

  void reset() {
    wood = 0;
    stone = 0;
    carriedWood = 0;
    carriedStone = 0;
    bagLevel = 1;
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

  /// Adds as much as possible to the carried bag and returns that amount.
  int collectResource(ResourceKind kind, int amount) {
    if (amount <= 0 || bagSpace <= 0 || gameOver) {
      return 0;
    }
    final int collected = amount < bagSpace ? amount : bagSpace;
    if (kind == ResourceKind.wood) {
      carriedWood += collected;
    } else {
      carriedStone += collected;
    }
    notifyListeners();
    return collected;
  }

  /// Moves the complete bag into the tower inventory.
  bool depositBag() {
    if (carriedTotal == 0 || gameOver) {
      return false;
    }
    wood += carriedWood;
    stone += carriedStone;
    carriedWood = 0;
    carriedStone = 0;
    notifyListeners();
    return true;
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

  bool spendBagUpgradeCost() {
    if (!hasBagUpgradeResources) {
      return false;
    }
    wood -= bagUpgradeWoodCost;
    stone -= bagUpgradeStoneCost;
    bagLevel += 1;
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
