abstract final class GameConfig {
  static const double logicalWidth = 420;
  static const double logicalHeight = 760;

  static const double arenaSize = 1320;
  static const double arenaWallThickness = 28;
  static const double playerRadius = 18;
  static const double playerMaxHealth = 100;
  static const double playerSpeed = 190;
  static const double playerAttackDamage = 35;
  static const double playerAttackRange = 68;
  static const double playerAttackCooldown = 0.42;
  static const double shieldMaxDuration = 0.5;
  static const double shieldCooldown = 1.0;

  static const double towerBaseHealth = 300;
  static const double towerHealthPerSegment = 75;
  static const double towerCollisionRadius = 48;
  static const double towerInteractionRange = 145;
  static const int buildWoodCost = 3;
  static const int buildStoneCost = 3;

  static const int initialBagCapacity = 6;
  static const int bagCapacityPerUpgrade = 4;
  static const int bagUpgradeBaseCost = 4;
  static const int bagUpgradeCostIncrease = 2;

  static const double enemyHealth = 70;
  static const double enemySpeed = 72;
  static const double enemyDamage = 12;
  static const double enemyAttackRange = 38;
  static const double enemyAttackCooldown = 0.9;
  static const double enemyTargetSwitchCooldown = 0.75;
  static const double enemyInitialSpawnInterval = 4.5;
  static const double enemyMinimumSpawnInterval = 1.2;
  static const double enemySpawnRampSeconds = 180;
  static const int maxEnemies = 24;

  static const double resourceSpawnInterval = 3.5;
  static const double resourceMinTowerDistance = 310;
  static const int maxResources = 18;
  static const int initialResourceCount = 10;
}
