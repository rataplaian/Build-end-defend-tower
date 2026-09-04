# Build & Defend Tower

A small mobile game prototype built with Flutter and Flame. It uses only basic
shapes plus one original enemy sprite. It contains no backend, networking,
accounts, ads, or external services.

## Gameplay loop

Explore beyond the tower's green deposit zone, collect wood and stone in a
limited bag, then return to deposit everything. Deposited resources can add a
tower segment or permanently increase bag capacity for the current run. Melee
creeps continuously enter through the outer walls and attack whichever is
closer: the player or the tower.

## Run

1. Install a recent stable Flutter SDK.
2. Generate the standard mobile runner files once with
   `flutter create --platforms=android,ios .`.
3. Run `flutter pub get`.
4. Connect a phone/emulator and run `flutter run`.

The app locks itself to portrait orientation. On mobile, the left pad moves the
player and the right-side buttons attack and raise the directional shield.

On desktop/web:

- `WASD`: move
- Mouse: aim
- Left mouse button: sword attack
- Right mouse button: hold the directional shield

## Play online

The GitHub Actions workflow analyzes and tests the project, builds Flutter Web,
and deploys it to GitHub Pages:

https://rataplaian.github.io/Build-end-defend-tower/

For the first deployment, select **Settings > Pages > Source: GitHub Actions**
in the repository.

## Verify

Run:

```sh
flutter analyze
flutter test
```
