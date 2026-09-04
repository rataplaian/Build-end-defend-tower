# Central Tower

A small mobile game prototype built with Flutter and Flame. It uses only basic
shapes and contains no backend, networking, accounts, ads, or external services.

## Run

1. Install a recent stable Flutter SDK.
2. Generate the standard mobile runner files once with
   `flutter create --platforms=android,ios .`.
3. Run `flutter pub get`.
4. Connect a phone/emulator and run `flutter run`.

The app locks itself to portrait orientation. The left pad moves the player;
the right-side buttons attack and raise the directional shield.

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
