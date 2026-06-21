# pdfpc_docker_ws

Docker だけで LaTeX スライドを作成し、コンパイルし、そのまま `pdfpc` で発表するためのワークスペースです。ローカルに LaTeX や `pdfpc` をインストールする必要はありません。

## 構成

```text
pdfpc_docker_ws/
├── Makefile
├── README.md
├── docker/
│   ├── Dockerfile
│   └── docker-compose.yml
└── projects/
    └── .gitkeep
```

`projects/` の下に、スライドごとのディレクトリを作成して使います。

## 前提

- Docker
- Docker Compose
- Linux の場合は `make`

GUI を表示するため、Linux では X11 を使います。`make up` / `make down` は `xhost` を自動で切り替えます。

## クイックスタート

```bash
# 1. イメージを作成
make build

# 2. 作業用コンテナを起動
make up

# 3. スライドを置く
mkdir -p projects/demo
cp /path/to/your/slides.tex projects/demo/main.tex

# 4. コンパイル
make compile PROJECT=demo

# 5. 発表用ビューアを起動
make present PROJECT=demo
```

`main.tex` 以外のファイル名を使う場合は `TEXFILE` で指定できます。

```bash
make compile PROJECT=demo TEXFILE=slides.tex
make present PROJECT=demo TEXFILE=slides.tex
make present PROJECT=demo TEXFILE=slides.tex PDFPC_NOTES_POSITION=right
make present-windowed PROJECT=demo TEXFILE=slides.tex
make present-dual-screen PROJECT=demo TEXFILE=slides.tex
```

## よく使うコマンド

| 目的 | コマンド |
|---|---|
| イメージをビルド | `make build` |
| コンテナを起動 | `make up` |
| コンテナを停止 | `make down` |
| シェルを開く | `make shell` |
| 1 回だけコンパイル | `make compile PROJECT=demo` |
| 自動再コンパイル | `make watch PROJECT=demo` |
| コンパイルして `pdfpc` を開く | `make present PROJECT=demo` |
| 2 ウィンドウで `pdfpc` を開く | `make present-windowed PROJECT=demo` |
| 2 画面で全画面表示 | `make present-dual-screen PROJECT=demo` |
| 中間生成物を削除 | `make clean PROJECT=demo` |

## 使い方の流れ

1. `projects/<talk-name>/` を作る。
2. `main.tex` を置く。
3. `make compile PROJECT=<talk-name>` で PDF を作る。
4. `make present PROJECT=<talk-name>` で `pdfpc` を開く。
5. 1 画面内で 2 ウィンドウ表示にしたい場合は `make present-windowed PROJECT=<talk-name>` を使う。
6. 2 画面構成で PDF を大きく表示したい場合は `make present-dual-screen PROJECT=<talk-name>` を使う。


## VS Code での作業

`.vscode/tasks.json` を入れてあるので、VS Code の `Tasks: Run Task` からそのまま実行できます。

- `make: watch`
  - 保存のたびに自動再コンパイルします。
  - 生成された `projects/<talk-name>/main.pdf` を VS Code の PDF ビューアで開いておけば、更新を見ながら作業できます。
- `make: compile`
  - 1 回だけコンパイルします。
- `make: present`
  - `pdfpc` を起動します。
- `make: present windowed`
  - 1 画面内の 2 ウィンドウ表示です。
- `make: present dual screen`
  - 2 画面構成で使います。

最初に `project` と `texfile` を入力します。`main.tex` を使うなら既定値のままで構いません。

LaTeX Workshop の forward sync は `docker/synctex.sh` 経由でコンテナ内の `synctex` を使います。

このワークスペースは、コンテナ内の作業パスをホストと同じ絶対パスに揃える設計です。そのため、`make: watch` か `make: compile` で作った PDF を開くと、追加のファイル同期なしでソースと PDF の相互ジャンプが使えます。

- ソース -> PDF: `Ctrl+Shift+Q`
  - このショートカットは VS Code のユーザー keybindings で 1 回だけ割り当ててください。ワークスペース内の `.vscode/keybindings.json` は VS Code では反映されません。
- PDF -> ソース: PDF タブ上で `Ctrl+クリック` (macOS は `Cmd+クリック`)

それでも飛ばないときは、PDF を一度閉じて `LaTeX Workshop: View LaTeX PDF file` で開き直してください。

## 補足

- 既定の LaTeX エンジンは `lualatex` です。
- 必要なら `LATEX_ENGINE=pdflatex` または `LATEX_ENGINE=xelatex` を指定できます。
- `watch` は `latexmk -pvc` を使うので、保存のたびに自動で再コンパイルされます。
- `pdfpc` の speaker notes は既定では無効です。必要なら `PDFPC_NOTES_POSITION=right` を指定してください。
- ALSA/JACK の音声バックエンド警告を抑えるため、コンテナでは `ALSOFT_DRIVERS=null` を設定しています。
- 動画付きスライドを使う場合は、Docker イメージに GStreamer のプラグイン群と `gstreamer1.0-gtk3` が入っている必要があります。
- `pdfpc` を 2 ウィンドウで開きたい場合は `make present-windowed` を使います。これは 1 画面内の分割表示です。
- 2 画面構成で PDF をフルサイズにしたい場合は `make present-dual-screen` を使います。`PDFPC_PRESENTER_SCREEN` と `PDFPC_PRESENTATION_SCREEN` で画面番号を指定できます。
- speaker notes を使う場合は `PDFPC_NOTES_POSITION=right` を付けます。

## 例

```bash
make compile PROJECT=demo
make watch PROJECT=demo
make present PROJECT=demo
```

## 注意点

- Linux 以外の環境では、X11 を表示するための追加設定が必要になる場合があります。
- コンテナ内で生成された PDF や補助ファイルは `projects/` 配下に保存されます。
