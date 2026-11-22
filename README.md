# Flipclock

パステル調のフリップ時計アプリ。時計・ポモドーロ・タイマーの 3 画面と、
着せ替え（スキン）を備える。Flutter 製で、web / Android / iOS に対応する。

- web 版: <https://azs4n10.github.io/flipclock/>
- プライバシーポリシー: <https://azs4n10.github.io/flipclock/privacy.html>
- アプリ ID: `io.github.azs4n10.flipclock`
- 設計の全体像: [docs/architecture.md](docs/architecture.md)

## 機能

- **Clock** — 12 / 24 時間表示、秒と日付の表示切り替え、署名テキスト。
- **Pomodoro** — 集中・短い休憩・長い休憩の長さと、長い休憩までの回数を設定できる。
  終了時刻を保存するので、アプリを閉じても続きから再開する。
- **Timer** — Count Up / Count Down / Target の 3 モード。動作中・一時停止中の
  どちらの状態も保存し、次回起動時に復元する。
- **完了通知** — カウントダウンやポモドーロの区切りがアプリを閉じている間に
  終わると、Android / iOS ではローカル通知で知らせる。許可は最初にタイマーを
  開始したときに求める。web はタブを開いている間だけブラウザ通知を出す。
- **着せ替え** — 10 種類のスキンとカスタム配色、数字用フォント 8 種、
  文字用フォント、文字サイズ、手持ちの写真を背景にする機能、季節の演出。
- **BGM** — ノイズや環境音をループ再生する。選んだ曲は次回起動時にも流れる
  （web は自動再生が止められるので、最初の操作で始まる）。
- 画面の常時点灯、縦横どちらの向きにも対応、タップで操作部を隠す全画面表示。

アカウントも利用状況の計測も無く、設定はすべて端末内に保存する。

## 開発

Flutter（stable、Dart 3.12 以上）が必要。

```sh
flutter pub get

# 実行
flutter run -d chrome        # web
flutter run                  # 接続中の Android / iOS 端末

# 検査
flutter analyze
flutter test

# ビルド
flutter build web --release --base-href /flipclock/
flutter build apk --release
flutter build ios --release --no-codesign   # macOS のみ
```

Git Bash で web をビルドするときは、`/flipclock/` が Windows のパスに
書き換えられないよう `MSYS_NO_PATHCONV=1` を付ける。

### テスト

`test/` にユニットテストとウィジェットテストがある。通知・BGM・背景写真の
保存先は `AppState.create()` の引数で偽物（`test/support/fakes.dart`）に
差し替えられる。

ゴールデン画像（`test/goldens/`）は Windows で生成したもので、Linux の CI では
アンチエイリアスの差で 0.2% ほど画素が変わる。そのため
`test/flutter_test_config.dart` が 0.5% までの差を許す比較器を入れている。
見た目を意図して変えたときは次のコマンドで更新する。

```sh
flutter test --update-goldens test/golden_showcase_test.dart
```

### Android の署名

リリース用の署名は `android/key.properties` と、そこから参照するキーストアを
読む。どちらもリポジトリには含めない。`key.properties` が無い環境では
リリースビルドがデバッグ鍵で署名されるので、ストアへ出すビルドは必ず
鍵のある環境で作る。

## デプロイ

`main` へ push すると `.github/workflows/ci.yml` が動く。

1. `analyze-test-web` — `flutter analyze`、`flutter test`、
   `flutter build web --release --base-href /flipclock/` を順に実行する。
2. `deploy-web` — 1 が通った `main` への push に限り、そのビルドに空の
   `.nojekyll` を足して `gh-pages` ブランチへコミットする。
3. GitHub Pages が `gh-pages` ブランチを配信する（従来と同じ設定）。
4. `build-ios` — 署名なしの iOS ビルドが通ることを確かめる。

プルリクエストでは 1 と 4 だけが動き、デプロイはしない。`web/privacy.html` も
ビルドに含まれるので、ポリシーの更新も同じ流れで公開される。

Android / iOS のストア向けビルドは手元で作成して提出する。

## どこに何があるか

| 内容 | 場所 |
|---|---|
| スキンの定義（配色） | `lib/theme/skins.dart`（型は `lib/theme/skin.dart`） |
| スキンから Material テーマとシステムバーの色を決める処理 | `lib/theme/skin_theme.dart` |
| フォントの定義 | `lib/theme/fonts.dart` |
| 同梱フォントのファイルとライセンス | `assets/google_fonts/`（`OFL.txt`） |
| BGM・チャイムの音源 | `assets/bgm/`、`assets/sounds/` |
| アイコン・起動画面の素材 | `assets/icon/`、検討時の画像は `design/icons/` |
| 状態と保存 | `lib/state/app_state.dart` |
| 画面 | `lib/screens/` |
| 通知・BGM・背景写真などのサービス | `lib/services/` |
| 素材を生成するスクリプト | `tool/`（Python） |

フォントは実行時にダウンロードしない。新しい書体を足すときは、ファイルを
`assets/google_fonts/` に置いてから `lib/theme/fonts.dart` に登録する
（`test/bundled_fonts_test.dart` が同梱漏れを検出する）。
