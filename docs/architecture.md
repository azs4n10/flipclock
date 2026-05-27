# flipclock アーキテクチャ

ゆめかわ系フリップ時計アプリ（Clock / Pomodoro / Timer + 着せ替え）。
Flutter（web / iOS / Android）製。状態管理は `provider`、永続化は
`shared_preferences`。

## レイヤー構成と依存

```mermaid
flowchart TD
    main["main.dart<br/>FlipclockApp / MaterialApp<br/>theme: Quicksand + Playfair"]

    subgraph State["状態 (ChangeNotifier)"]
        appState["AppState<br/>skin / font / fontScale<br/>表示設定 / BGM / 季節 / カスタム色<br/>Pomodoro 永続化"]
    end

    subgraph Screens["画面 (screens/)"]
        home["HomeScreen<br/>PageView + 上部バー"]
        clock["ClockScreen"]
        pomo["PomodoroScreen"]
        timer["TimerScreen"]
        settings["PomodoroSettingsSheet<br/>(設定シート)"]
        skinPick["SkinPickerScreen<br/>(着せ替え)"]
        custom["CustomColorScreen<br/>(カスタム配色)"]
    end

    subgraph Widgets["部品 (widgets/)"]
        flipRow["FlipCardRow"]
        flip["flip_card.dart<br/>FlipGroup / FlipDigit / StaticFlipCard"]
        tabs["SegmentedTabs"]
        pill["PillButton"]
        seasonal["SeasonalOverlay"]
        flash["CompletionFlash"]
    end

    subgraph Theme["テーマ (theme/)"]
        skin["Skin"]
        skins["skins.dart<br/>10種 + custom"]
        fonts["DigitFont (fonts.dart)<br/>GoogleFonts 8種 + centerBias"]
    end

    subgraph Services["サービス (services/)"]
        alerts["Alerts<br/>音 + 振動"]
        bgm["BgmController<br/>ループ再生 (audioplayers)"]
        actions["AppActions<br/>share / feedback / rate"]
    end

    prefs[("shared_preferences")]
    assets[["assets/<br/>bgm/*.wav, sounds/chime.wav,<br/>icon/*"]]

    main --> appState
    main --> home
    home --> clock & pomo & timer
    home --> tabs
    home --> seasonal
    home -. 設定を開く .-> settings
    home -. 着せ替えを開く .-> skinPick
    skinPick --> custom

    clock --> flipRow
    pomo --> flipRow & flash
    timer --> flipRow & flash & flip
    flipRow --> flip
    pomo --> pill
    timer --> pill & tabs
    settings --> bgm & actions

    clock & pomo & timer & settings & skinPick & custom --> appState
    appState --> skins --> skin
    appState --> fonts
    appState --> bgm
    flip --> fonts
    pomo --> alerts
    timer --> alerts

    appState <--> prefs
    bgm --> assets
    alerts --> assets
```

## 状態とデータの流れ

```mermaid
flowchart LR
    user(("ユーザー操作")) -->|タップ/設定変更| screens["各画面 / 設定シート"]
    screens -->|setXxx| appState["AppState"]
    appState -->|set → persist| prefs[("shared_preferences")]
    appState -->|notifyListeners| rebuild["Consumer / context.watch 再構築"]
    rebuild --> screens
    appState -->|setBgm| bgm["BgmController.play"]
    appState -. "skin / font / fontScale<br/>等を提供" .-> screens
```

- 設定はすべて `AppState` の `setXxx()` 経由で `shared_preferences` に保存され、
  `notifyListeners()` で全画面が再描画される。
- Pomodoro は終了時刻を絶対時刻で保存（`savePomodoro`）し、アプリを閉じても
  復元・経過反映できる。

## フリップ描画の構造

```mermaid
flowchart TD
    row["FlipCardRow<br/>幅+高さからカードサイズを算出<br/>(レスポンシブ)"]
    row --> group["FlipGroup (1枚の札)"]
    row -. 末尾に小さく .-> staticCard["StaticFlipCard<br/>(センチ秒・非アニメ)"]
    group --> digit["FlipDigit (桁ごと)"]
    digit --> splitflap["_SplitFlap<br/>上下リーフ + rotateX"]
    digit -->|"Ticker + Stopwatch で reduce-motion 回避"| anim["実時間アニメ"]
    splitflap --> leaf["_Leaf<br/>(centerBias で上下中心補正)"]
```

## 外部パッケージ

| 用途 | パッケージ |
|---|---|
| 状態管理 | provider |
| 永続化 | shared_preferences |
| フォント | google_fonts |
| 音 / BGM | audioplayers |
| 日付整形 | intl |
| 共有 | share_plus |
| メール/URL | url_launcher |
| レビュー | in_app_review |
| 配色ピッカー | flutter_colorpicker |
| アイコン生成(dev) | flutter_launcher_icons |
| 起動画面生成(dev) | flutter_native_splash |

## ビルド & デプロイ

```mermaid
flowchart LR
    src["lib/ + assets/"] -->|flutter build web| webbuild["build/web"]
    webbuild -->|"--base-href /flipclock/"| ghp["gh-pages ブランチ<br/>(手動 push, Actions 不使用)"]
    ghp --> pages["GitHub Pages<br/>azs4n10.github.io/flipclock/"]
    src -->|flutter build| native["iOS / Android<br/>(ネイティブ, 要 Mac for iOS)"]
    tool["tool/*.py (PIL/numpy)"] -. 生成 .-> assetsgen["icon / splash / bgm"]
```

- web は `gh-pages` ブランチへ手動デプロイ（支払い状況に依存しないよう Actions 非使用）。
- アイコン・起動画面・BGM 音源は `tool/` の Python スクリプトで生成。
