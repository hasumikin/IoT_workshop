require 'erb'


introduction = ERB.new <<~EOF
  # ESP32 + mruby/c開発のための環境構築 - 導入
  mrubyソースコード（拡張子「.rb」）をmrbc（mrubyコンパイラ）によって拡張子「.c」の中間バイトコードに変換し、それ（とmruby/cのランタイムプログラム）を「main.c」から参照することで動作させるのが、mruby/cアプリ開発の基本的なフローです。

  ESP32のファームウェアをmruby/cで開発するためには、Espressif社が提供しているESP-IDFおよび関連ツール群をセットアップする必要があります。
  ESP-IDFにはESPファームウェア開発に使用可能なライブラリが含まれ、実行ファイルの作成をサポートします。

  以下では、ESP-IDFや関連ツール群をセットアップした開発環境のことを「ESP開発環境」と呼び、その構築について説明します。

  ## 環境構築の選択肢

  ### macOS
  macOSのネイティブ環境にESP開発環境を構築することができます。

  [Link]

  ### Windows
  Windowsのネイティブ環境ではESP開発環境は動作しませんが、準Linux環境を使用することでESP開発が可能になります。
  その方法には、以下のように2通りあります。

  #### 64bit版のWindows10
  Windows Subsystem for Linux（WSL）をお使いください。

  [Link]

  #### 上記以外のWindows
  MSYS2をお使いください。

  [Link]

  ### Linux各種ディストリビューション
  Linux用の環境構築マニュアルは用意しませんが、ホストOSとしてLinuxをお使いになるようなプログラマにとっては難しいことではありません。
  WindowsのWSL用マニュアルのなかのUbuntu起動以降を参照し、ESP開発環境を構築してください。

  ## 仮想環境、Dockerについて

  例えば、Windows10 Professional上のVirtualBoxにインストールしたLinuxにESP開発環境を構築することは可能です。しかし、ホストOSにUSB接続されたESP32開発ボードをゲストOSから適切に参照できるかどうかを左右する要因のすべてが明らかではなく、期待どおりに動作しないとの報告があるようです。

  したがってこのマニュアルでは、ホストOS上にESP開発環境を構築することを前提としています。

  仮想環境を使用したい方も、ワークショップをスムーズに進めるためにホストOSの上の環境を先につくったうえで、ゲストOS上のESP開発環境をつくってみてください。そして、うまくできる方法やできない方法についての情報をぜひ共有してください。

  また、Dockerは一般にUSBドライバに問題があるようなので、使用できないとお考えください（もし挑戦してみて使用できたら教えてください）。

EOF

about_ruby = ERB.new <<~EOF
  ## Rubyについて

  mrubyのビルドにはCRuby（最も一般的なRuby実装）が必要です。

  <% if platform != "MSYS2" %>
    Rubyのインストールには複数の方法がありますが、複数のRubyをシステム内に共存させるためのツール「rbenv」を使用することを推奨します。

    ワークショップの後半に時間があれば筆者作のmruby/c用便利ツール `mrubyc-utils` を使う予定があり、rbenvの環境のほうがスムーズに使用できます。
  <% end %>

EOF

mac_usb = ERB.new <<~EOF
  ## USBドライバをインストール

  「USB to UART ブリッジドライバ」をインストールします。
  下記ページからお使いのOSに適合するものをダウンロードして、インストールしてください。
  https://www.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers

  インストールの中で「機能拡張がブロックされました（System Extension Blocked）」というダイアログが表示された場合には、「システム環境設定」->「セキュリティとプライバシー」->「一般」を開き、「許可」をクリックしてください（すべての環境でブロックされるわけではないようです）。

  ![](../images/mac-01.png)

EOF

mac_idf = ERB.new <<~EOF
  ## 関連ツールのセットアップ

  ESP関連ツール群をダウンロードして解凍します。
  ```bash
  mkdir -p $HOME/esp
  cd $HOME/esp
  wget https://dl.espressif.com/dl/xtensa-esp32-elf-osx-1.22.0-80-g6c4433a-5.2.0.tar.gz
  tar -xzf xtensa-esp32-elf-osx-1.22.0-80-g6c4433a-5.2.0.tar.gz
  rm xtensa-esp32-elf-osx-1.22.0-80-g6c4433a-5.2.0.tar.gz
  ```

  pythonのバージョン管理にpyenvなどをお使いでしたら、以下のようにシステムデフォルトのpythonにバージョンを固定したほうがよいかもしれません。
  pyenv等を使用していない、またはpythonの利用に慣れており問題への対処が可能だと思う場合は、この設定はスキップして構いません。
  ```bash
  cd $HOME/esp
  echo 'system' > .python-version
  ```

  .bash_profileファイルに環境変数を設定し、有効化します（bashではなくzshを使用しているなどの場合は適宜読み替えてください）。
  ```bash
  echo 'export PATH="$HOME/esp/xtensa-esp32-elf/bin:$PATH"' >> $HOME/.bash_profile
  echo 'export IDF_PATH="$HOME/esp/esp-idf"' >> $HOME/.bash_profile
  source $HOME/.bash_profile
  ```

  ESP-IDFを配置します。
  ```bash
  cd $HOME/esp
  git clone --recursive https://github.com/espressif/esp-idf.git
  ```

  python製の関連ツールをインストールします。
  ```bash
  sudo easy_install pip
  python -m pip install --user -r $IDF_PATH/requirements.txt
  ```

EOF

wsl_usb = ERB.new <<~EOF
  ## USBドライバについて

  今回のワークショップで使用するESP32開発キット [ESP32-DevKitC](https://www.espressif.com/en/products/hardware/esp32-devkitc/overview) には、「CP2102N」というシリアル-USB変換チップが使用されており、このドライバをWindowsにインストールする必要があります。
  もしも以下で説明するPololu社のドライバを有効にできない場合は、WSLを諦めてMSYS2環境を選択してください。

  また、お使いのOSが64bit版のWindows10以外でしたらいずれにせよMSYS2の環境を構築することになるので、USBドライバはどちらでも構いません。

  2019年3月時点で、Silicon Labs社が提供するドライバではWSLとESP32が期待するように通信できません。少なくとも筆者の環境では動きませんでした。MSYS2ならば問題ありません。

  【ご注意ください】下記ページからダウンロードしたドライバとWSLの組み合わせでは期待どおりには動かないと思われます。

  （これはNGです）https://jp.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers

  代わりに、Pololu社のページからダウンロードできるドライバをインストールしてください。

  https://www.pololu.com/docs/0J7/all#2

  （ドライバファイルへの直リンク：https://www.pololu.com/file/0J14/pololu-cp2102-windows-121204.zip ）

  ZIPファイルを解凍し、「pololu-cp2102-setup-x64.exe」をダブルクリックしてインストールしてください。

  ### Silicon Labs社のドライバがインストール済みだとどうなるのか

  インストール済みのドライバを「完全に」削除する必要があります。

  「デバイスのアンインストール」の操作だけではドライバファイルが削除されず、Windowsが（プラグ・アンド・プレイ機能によって）自動的に日付の新しいものを割り当ててしまいます。
  Silicon Labs社のドライバの日付のほうがPolulu社より新しいため、Windowsが自動的にSilicon Labs社のものを選択してしまい、ユーザの任意によってPololu社のドライバを有効にはできないのです。

  ### インストールされているドライバを調べる

  Windows PowershellまたはCommand Prompt(CMD)を起動し、下記のコマンドを入力してください。
  ```bash
  pnputil -e
  ```

  非常に多くの行が出力されますが、すべてテキストエディタにコピー＆ペーストするなどして、ドライバの情報を探します。
  両方のドライバをインストールした筆者の環境では、このように表示されました。
  `oem9.inf` がSilicon Labs社のシステム定義ファイル、 `oem158.inf` がPololu社のシステム定義ファイルです。
  __Driver date and version__ の値の違いに注目してください。
  ```bash
  Published name :            oem9.inf
  Driver package provider :   Silicon Laboratories Inc.
  Class :                     Ports (COM & LPT)
  Driver date and version :   11/26/2018 10.1.4.2290
  Signer name :               Microsoft Windows Hardware Compatibility Publisher

  Published name :            oem158.inf
  Driver package provider :   Silicon Laboratories
  Class :                     Ports (COM & LPT)
  Driver date and version :   10/05/2012 6.6.0.0
  Signer name :               Microsoft Windows Hardware Compatibility Publisher
  ```

  この状態では、より新しいSilicon Labs社のドライバが使用されてしまうため、これを削除しなければなりません。

  ### デバイスドライバを完全に削除する

  【ご注意ください】この手順によりWindowsが正常に動作しなくなる危険があります。自己責任において実施してください。

  最初にデバイスマネージャーを使用してドライバをアンインストールしてください。

  ![](../images/uninstall_device.png)

  つぎにWindows PowershellまたはCommand Prompt(CMD)を __administratorとして起動__ し、下記のコマンドでシステム定義を削除します。
  ファイル名 `oem9.inf` は __環境によって異なります__ のでご注意ください。
  ```bash
  pnputil -d oem9.inf
  ```

  `Driver package deleted successfully.` と表示されれば削除成功です。

  何らかの理由で削除できない場合や、すでにインストールされているドライバがなんであるかよくわからない場合などは、WSLではなくMSYS2の環境構築をお選びください。あるいは両方を構築しておいて、ワークショップ当日に使える方を使う、というのもよいと思います。

EOF

msys2_usb = ERB.new <<~EOF
  ## USBドライバをインストール

  今回のワークショップで使用するESP32開発キットには、「CP2102N」というシリアル-USB変換チップが使用されており、このドライバをWindowsにインストールする必要があります。

  以下のうちどちらか一方のページからお使いのOSに該当するドライバをダウンロードし、インストールしてください。もしもWSLを併用する可能性がある場合は、後者（Pololu社）のドライバをお使いください。理由はWSLの環境構築マニュアルを参照してください。

  https://jp.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers

  https://www.pololu.com/docs/0J7/all#2

EOF

msys2_intro = ERB.new <<~EOF
  ## Windowsの「MSYS2」にESP開発環境を構築

  ※あなたのOSが64bit版のWindows10で、かつPololu社のUSBドライバを有効化できているなら、WSLの環境構築をおすすめします。

  MSYS2は、Windows上にUnixコマンドライン環境をエミュレートするための統合パッケージです。Espressif社はMSYS2に各種の必要ツールをセットアップしたオール・イン・ワンのZIPアーカイブを提供しているので、それをそのまま使用するのが最も簡単な開発環境構築です。

  もしも「素のMSYS2」に依存ツールを1つずつインストールしてみたい場合は、下記ページにそのための情報があります。ただし筆者は未検証です。

  https://docs.espressif.com/projects/esp-idf/en/latest/get-started/windows-setup-scratch.html

EOF

msys2_idf = ERB.new <<~EOF
  ## 環境構築

  ### MSYS2（およびツール群）のダウンロードと配置

  下記リンクからオール・イン・ワンのZIPアーカイブをダウンロードして、解凍してください。

  https://dl.espressif.com/dl/esp32_win32_msys2_environment_and_toolchain-20181001.zip

  任意の場所に解凍して構いませんが、一般的にはWindowsがインストールされているCドライブ内のどこかがよいと思われます。
  解凍にはかなり時間がかかります。解凍してからフォルダを移動するのにも時間がかかるので、最初から配置したい場所に解凍しましょう。

  解凍・配置時に注意すべきことがあります。その過程でなんらかのアンチウィルスの仕組みが一部のファイルを自動削除してしまうかもしれません。これが発生すると、正しく使用できなくなります。

  解凍すると現れる `msys32` ディレクトリ内が下の画像のようになっていれば、概ね問題ないと思われます。

  ![](../images/msys2.png)

  筆者の環境では当初、etcディレクトリなどが削除されてしまったので、仮想のLinux上で解凍して対処しました。

  しかしその後、本稿執筆のために再現させようとしても再現しなかったため、本当はなにが原因だったのかわからないし回避方法も不明です。

  ### MSYS2の起動と設定

  `msys32` ディレクトリ内の `mingw32.exe` を起動してください。 `mingw64.exe` ではダメです。
  これはあなたのWindowsが64bit版であるか32bit版であるかにかかわりません。ESP-IDFがmingw64に対応していません。

  以降、MSYS2を起動するときは毎回 `mingw32.exe` を使用してください。

  .bash_profileファイルに環境変数を設定し、有効化します。
  ```bash
  echo 'export IDF_PATH="$HOME/esp/esp-idf"' >> $HOME/.bash_profile
  source $HOME/.bash_profile
  ```

  ESP-IDFを配置します。macOSやWSLでインストールが必要だった関連ツール群はすでにインストールされているため、簡単です。
  ```bash
  mkdir $HOME/esp && cd $HOME/esp
  git clone --recursive https://github.com/espressif/esp-idf.git
  ```

EOF


wsl_intro = ERB.new <<~EOF
  ## Windowsの「Subsystem for Linux (WSL) 」にESP開発環境を構築

  WSLは、64bit版のWindows10（またはWindows Server）上でLinuxの実行ファイルをネイティブ実行できる環境です。
  Windows8以前または32bit版Windows10ではWSLを利用できないため、MSYS2をお使いください。

  WSLにESP-IDFをインストールすることでLinux上のESP開発環境と同等の環境を構築できます。
  ファームウェアのビルド速度がMSYS2より大幅に速いため（というよりもMSYS2がかなり遅いのです）、これから新たに環境構築する方はWSL環境の構築を先に試してみてください。

EOF

wsl_idf = ERB.new <<~EOF
  ## 環境構築

  ### Windows Update

  まず、Windows10をMicrosoftが提供している最新の状態に更新してください。更新されていないWindowsでは、WSLの機能のうちわれわれが必要とするものを利用できない可能性があります。

  ### WSL (Ubuntu) のインストール

  「設定」→「アプリと機能」→「プログラムと機能」をクリックします。
  ![](../images/wsl-01-ja.png)

  「Windowsの機能の有効化または無効化」をクリックし、「Windowsの機能」ダイアログ内の「Windows Subsystem for Linux」にチェックを入れ、「OK」をクリックします。
  ![](../images/wsl-02-ja.png)

  再起動を促されるので「今すぐ再起動」をクリックします。
  ![](../images/wsl-03-ja.png)

  再起動後、「Microsoft Store」アプリで「Ubuntu」を検索、クリックしてインストールします。
  ![](../images/wsl-04.png)

  「Ubuntu」アプリ（これがWSLのUbuntu版です）を起動します。
  ![](../images/wsl-05.png)

  初回の起動時にはUnixユーザ名とパスワードの設定が必要です。

  __このユーザ名は、Windowsのログインアカウントと同じものにしてください。そうしないと、WindowsとWSL間の共有ディレクトリが見つからなくなります。__

  ![](../images/wsl-06.png)

  ### Ubuntu上での環境構築

  関連パッケージをインストールします。
  ```bash
  sudo apt update
  sudo apt install tree gcc git wget make libncurses-dev flex bison \\
    gperf python python-pip python-setuptools python-serial \\
    python-cryptography python-future python-pyparsing
  ```

  Espressif社が提供しているツール群をダウンロードし、解凍、配置します。
  ```bash
  mkdir $HOME/esp
  cd $HOME/esp
  wget https://dl.espressif.com/dl/xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz
  tar -xzf xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz
  rm xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz
  ```

  .profileファイルに環境変数を設定し、有効化します。
  ```bash
  echo 'export PATH="$HOME/esp/xtensa-esp32-elf/bin:$PATH"' >> $HOME/.profile
  echo 'export IDF_PATH="$HOME/esp/esp-idf"' >> $HOME/.profile
  source $HOME/.profile
  ```

  ESP-IDFを配置します。
  ```bash
  cd $HOME/esp
  git clone --recursive https://github.com/espressif/esp-idf.git
  ```

  python製の関連ツールをインストールします。
  ```bash
  python -m pip install --user -r $IDF_PATH/requirements.txt
  ```

  シリアルポートの権限が必要なので、自ユーザをdialoutグループに追加します。
  ```bash
  sudo usermod -a -G dialout $USER
  ```

  ### プログラム作成ディレクトリについて
  Ubuntu上のVimなどではなく、Windows上に別途起動するエディタでプログラムを書くつもりでしたら、WindowsとWSLのディレクトリ共有について確認しておくとよいでしょう。

  WSL上の `/mnt/c/Users/[usename]/esp` がWindows上の `c:¥Users¥[Windows account name]/esp` に一致します。
  先述のとおり、 `[usename]` と `[Windows account name]` は同じ文字列でなければなりませんので、最初にWSL（Ubuntu）を起動したときに作成するusernameをWindowsアカウント名と同じものにするよう注意してください。

EOF

hello_world_posix = ERB.new <<~EOF
  ## Hello mruby/c World!

  mruby/cはマイコンだけでなく、パソコン（POSIX）でも動きます。Hello Worldを出力させてみましょう。

  Makefileやmain.cなどがすでにできているリポジトリを用意しました。git cloneしてください。

  ### git clone
  ```bash
  cd $HOME/esp
  git clone https://github.com/hasumikin/hello-mrubyc-world-posix
  cd hello-mrubyc-world-posix
  ```

  ### Rubyプログラムを書く

  `mrblib/loops/master.rb` をテキストエディタで開き、以下の内容にして保存します。

  <%= "WSLをお使いの方へ：WSLのCUIエディタを使わず、Windows上のエディタを使いたい場合は、環境構築編で説明した共有ディレクトリについて確認してください。共有ディレクトリがどこにあるかわからないと、ワークショップを進めることができません。非常に重要です。" if platform == "WSL" %>

  ```ruby:mrblib/loops/master.rb
  while true
    puts "Hello World!"
    sleep 1
  end
  ```

  ### ビルド、実行

  ```bash
  make && ./main
  ```

  上記コマンドで以下のような画面になれば成功です！　1秒ごとに `Hello World!` が出力されます。

  このプログラムは `ctrl + C` で終了できます。
  ![](../images/hello_world.png)

EOF

mac_ruby = ERB.new <<~EOF
  ### Rubyのインストール

  homebrewが導入済みであることを想定し、手順を説明します。homebrewを使用せずにrbenvをインストールしたい場合は、WSLの環境構築マニュアルの該当部分を参考にしてください。

  rbenvとruby-buildをインストールし、パスを通すなどします。
  ```bash
  brew install openssl readline zlib rbenv ruby-build
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
  echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.bash_profile
  source $HOME/.bash_profile
  ```

  macOSにはRubyがインストールされていますが、せっかくなので新しいバージョンをインストールしましょう。
  ```bash
  rbenv install <%= cruby_version %>
  ```
  このときに `The Ruby zlib extension was not compiled.` などのエラーが出てしまうときは、以下のようにすることでインストールできるかもしれません。
  ```bash
  RUBY_CONFIGURE_OPTS="--with-zlib-dir=$(brew --prefix zlib)" rbenv install <%= cruby_version %>
  ```

  `zlib` のところが `readline` など別のライブラリかもしれません。適宜読み替えて対処してください。

  最後にmrubyをインストールします。mruby2.xはまだmruby/cと統合されていないので、1.4.1を使用します。
  ```bash
  rbenv install mruby-1.4.1
  ```

EOF

msys2_ruby = ERB.new <<~EOF
  ### Rubyインストール（Rubyinstaller2を使用）

  ※MSYS2にrbenvをインストールするのも可能なようですが、簡単ではなさそうです。挑戦してみたい方はネットで調べてみてください。

  最初にCRubyをインストールします。mrubyのビルドにはCRubyが必要なためです。

  MSYS2上ではなく、WindowsのGUI上で行ってください。WindowsでRubyを使用するための専用インストーラをダウンロードします。

  https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-<%= cruby_version %>-1/rubyinstaller-<%= cruby_version %>-1-x86.exe

  32bit版のRubyインストーラをダウンロードします。MSYS2でESP-IDFを使用するために `mingw32.exe` をPOSIXエミュレータとして使用するので、これにあわせています。

  ホストOSが64bit版のWindows8などである場合は、64bit用のRubyインストーラ（rubyinstaller-<%= cruby_version %>-1-x64.exe）でもよいかもしれませんが、未検証です。一般的に、64bit版のWindowsでは32bit版の実行ファイルが動作します。逆は動作しません。

  ダウンロードしたをダブルクリックし、「I accept the license」を選択してから「NEXT」を押します。
  ![](../images/rubyinstaller2-01.png)

  「Use UTF-8 as default external encoding.」のチェックが外れているでしょうから、チェックして、「Install」を押します（エンコーディングは今回のワークショップには関係ありませんが、他の用途に使用するときにこのほうがよさそうです）。
  ![](../images/rubyinstaller2-02.png)

  「Run 'ridk...」にチェックが入っていることを確認して、「Finish」を押します。
  ![](../images/rubyinstaller2-03.png)

  CRubyのインストールが完了すると、関連ツールをインストールするためのこの画面になるので「3」を入力してエンター（リターン）キーを押します。
  ![](../images/rubyinstaller2-04.png)

  この画面では何も入力せず、エンターキーだけを押してRubyのインストールを終了します。
  ![](../images/rubyinstaller2-05.png)

  MSYS2のコマンドラインにパスを通します。
  ```bash
  cd $HOME
  echo 'export PATH="/c/Ruby26/bin:$PATH"' >> $HOME/.bash_profile
  source $HOME/.bash_profile
  ```

  確認します。
  ```bash
  ruby --version
  ```

  上のコマンドで `ruby <%= cruby_version %>pXX (2019-XX-XX revision XXXXX) [i386-mingw32]` のように出力されればOKです。

  つぎにmrubyをインストールします。mruby2.xはまだmruby/cと統合されていないので、1.4.1を使用します。
  ```bash
  cd $HOME
  wget https://github.com/mruby/mruby/archive/1.4.1.zip
  unzip 1.4.1.zip
  cd mruby-1.4.1
  ruby minirake
  ```

  パスを通します。
  ```bash
  echo 'export PATH="$HOME/mruby-1.4.1/build/host/bin:$PATH"' >> $HOME/.bash_profile
  source $HOME/.bash_profile
  ```

  確認します。
  ```bash
  mrbc --version
  ```

  上のコマンドで `mruby 1.4.1 (2018-4-27)` と出力されればOKです。

EOF

wsl_ruby = ERB.new <<~EOF
  ### Rubyをインストール

  rbenvをインストールします。
  ```bash
  cd $HOME
  git clone https://github.com/rbenv/rbenv.git $HOME/.rbenv
  ```

  パスを通すなどします。
  ```bash
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> $HOME/.profile
  echo 'eval "$(rbenv init -)"' >> $HOME/.profile
  source .profile
  ```

  ruby-buildをインストールします。
  ```bash
  mkdir -p "$(rbenv root)"/plugins
  git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
  ```

  WSLにはシステムデフォルトのRubyがありません。mrubyのビルドにはCRubyが必要なので、まずはCRubyをインストールします。
  非常に時間がかかりますので気長に実行してください。
  ```bash
  sudo apt-get install -y libssl-dev libreadline-dev zlib1g-dev
  rbenv install <%= cruby_version %>
  ```

  たったいまインストールしたCRubyをグローバルデフォルトに設定します。
  ```bash
  rbenv global <%= cruby_version %>
  ruby --version
  ```

  上のコマンドで、 `ruby <%= cruby_version %>pXX (2019-XX-XX revision XXXXXX) [x86_64-linux]` のように出力されればOKです。

  mrubyをインストールします。現状、mruby-2.xはmruby/cには使えないので、1.4.1をインストールしてください。
  ```bash
  rbenv install mruby-1.4.1
  ```

EOF

hello_world_esp = ERB.new <<~EOF
  ## Hello ESP32 World!

  ESP32上で動作する Hello World プログラムをつくります。

  ESP32 & mruby/c用のアプリケーションテンプレートをGitHubからcloneします。

  ```bash
  cd $HOME/esp
  git clone https://github.com/hasumikin/mrubyc-template-esp32.git hello-mrubyc-world-esp32
  cd hello-mrubyc-world-esp32
  ```

  ディレクトリ構成を見てみましょう。 `mrblib/` の中にわれわれのRubyソースコードを書きます。 `main/` の中にはC言語のソースコードを書きます。

  ```bash
  ~/esp/hello-mrubyc-world-esp32$ tree -L 3
  .
  ├── Makefile
  ├── components
  │   └── mrubyc
  │       ├── component.mk
  │       ├── mrubyc_mrblib
  │       └── mrubyc_src
  ├── main
  │   ├── component.mk
  │   └── main.c
  └── mrblib
      ├── loops
      └── models

          8 directories, 4 files
  ```

  3つのソースコードを以下のような内容に編集します。
  すでに存在するファイルは上書きし、存在しないファイルは新規作成してください。

  `main/main.c`
  ```c
  #include "mrubyc.h"

  #include "models/greeter.h"
  #include "loops/master.h"

  #define MEMORY_SIZE (1024*40)

  static uint8_t memory_pool[MEMORY_SIZE];

  void app_main(void) {
    mrbc_init(memory_pool, MEMORY_SIZE);

    mrbc_create_task( greeter, 0 );
    mrbc_create_task( master, 0 );
    mrbc_run();
  }
  ```

  `mrblib/loops/master.rb`
  ```ruby
  greeter = Greeter.new

  while true
    greeter.greet
    sleep 1
  end
  ```

  `mrblib/models/greeter.rb`
  ```ruby
  class Greeter
    def greet
      puts "Hello World!"
    end
  end
  ```

  ### ビルド

  `make` コマンドを入力すると、ビルドが始まります。

  ESPプロジェクトの初回の make 時には下の画像のような `make menuconfig` 相当の画面になります。エスケープキーを2回押すか、&lt;Exit&gt;を選択すればmenuconfigを終了できます。menuconfigは、プロジェクト（アプリケーション）ごとに毎回設定する必要があります。

  ターミナル（ウインドウ）のサイズが小さすぎると「menuconfig画面をつくれない」という意味のエラーがでます。
  ウインドウサイズを大きくして再度 `make` してください。

  ![](../images/menuconfig-01.png)

  設定ファイルが自動で生成され（これによって次回の `make` コマンドでは設定画面が表示されなくなります。明示的に表示するためのコマンドが `make menuconfig` です）、プロジェクトのビルドが始まるはずです。下の画像のような出力で終了すれば正常です。

  ![](../images/hello_world_build.png)

  正常終了しなかった場合は、これまでの手順のどこかを抜かしたか、入力ミスなどで正しく手順を踏めていなくてエラーメッセージに気づかず進んでしまったことが考えられます。

  次はついにESP32へのプログラム書き込みですが、その前にUSB接続を確認し、シリアルポートを設定しましょう。
  WindowsとmacOSそれぞれについて説明します。

### USB接続の確認とシリアルポート設定

EOF

win_usb_confirm = ERB.new <<~EOF
  #### Windowsの場合：COMポート番号を確認

  「デバイスマネージャー」アプリを開き、その状態のままUSBケーブルのマイクロコネクタ側をESP32開発ボードに、タイプAコネクタをWindowsパソコンに接続します。

  「USB to UART ブリッジドライバ」がインストール済みなので、画像のように「ポート（COMとLPT）」内に「Silicon Labs CP210x USB to UART Bridge (COM5)」のような項目が現れるはずです。名称は環境によって異なる可能性があります。

  ![](../images/device_manager-ja.png)

  「(COM5)」の __最後の数字「5」__ が、みなさんの環境では異なる可能性があります。
  この数字を覚えておいてください。

EOF

mac_usb_confirm = ERB.new <<~EOF
  #### macOSの場合：シリアルポートのデバイスファイル名を確認

  USBポートにESP32開発ボードを接続していない状態で、 `ls -l /dev/cu.*` と打ってみてください。
  つぎに、ESP32開発ボードをmacに接続した状態で、同じコマンドを打ってください。「USB to UART ブリッジドライバ」が正しくインストールできていれば、出力がひとつ増えるはずです。そしてそのデバイスファイルは「/dev/cu.SLAB_USBtoUART」のような名前であるはずです。

  この文字列をメモしておいてください。

EOF

hello_world_esp_run = ERB.new <<~EOF
  ### WindowsとmacOS共通：シリアルポートを設定
  ```bash
  make menuconfig
  ```
  上記コマンドで設定画面を起動し、カーソルキーとエンターキーで「Serial flasher config」→「(/dev/ttyUSB0) Default serial port」と選択し、ポートを **下で説明する値** に変更してエンターキーで確定し、何度かエスケープキーを押すと保存するか確認されるので「&lt;Yes&gt;」を選択してください。

  - macOS：先ほどメモをとった「/dev/cu.SLAB_USBtoUART」のような文字列
  - WSL：「/dev/ttyS5」（最後の数字を先ほど確認したCOM番号と同じものに変更してください）
  - MSYS2：「COM5」（先ほど確認した「COM名」と同じ文字列にする。WSLと異なり、 `/dev/` の部分は不要です）

  ![](../images/menuconfig-01.png)
  ![](../images/menuconfig-02.png)
  ![](../images/menuconfig-03.png)
  ![](../images/menuconfig-04.png)

  ### プロジェクトを書き込み、実行

  このコマンドでプロジェクトが書き込まれます。makeコマンドの一般的な動作と同様、プログラムファイルの更新日時から計算される依存関係上必要な場合は、ビルドが先に実行されます。
  ```bash
  make flash
  ```

  このコマンドでESP32がリブートしてファームウェアが先頭から実行され、実行中のデバッグ情報などが標準出力に書き出されます。
  ```bash
  make monitor
  ```

  どうでしょうか？　hello-mrubyc-world-posix（PC上のHello World）と同じように、1秒ごとに `Hello World!` が出力されたでしょうか？　うまく行かない場合は手順を再度見なおしてください。

  ESP-IDFのコンソールモニタ（make monitor）は、 `ctrl + ]` で終了できます。

  ちなみに上の2つのコマンドは以下のように一度に実行できます。
  ```bash
  make flash monitor
  ```

EOF


multi_task = ERB.new <<~EOF
  ## mruby/cでマルチタスク

  前回まではマイコンや周辺機器の基礎的な使い方をみてきました。
  最終回は、mruby/cの特長のひとつであるマルチタスク機能を利用するプロジェクトをつくります。

  ### 使用パーツ
  - 赤色LED
  - サーミスタ（103AT）
  - 抵抗器330Ω
  - 抵抗器10kΩ
  - ジャンパーピン
  - ブレッドボード

  ### タスクとは

  LinuxやWindowsで言うところの「スレッド」とほぼ同じ意味です。
  OSがスレッドごとにCPU時間の割り当てをコントロールし、複数のスレッド（処理のまとまり）を同時的に進行させる機能またはその動作状態のことをマルチスレッドと呼びます。

  RTOS（リアルタイムOS）が載っているマイコンでもOSがマルチタスクをコントロールしますが、mruby/cにはOSなしでマルチタスクを実現する仕組みが含まれており、このことによって省メモリでありながら実用性の高いファームウェアを開発しやすくなっています。

  ※本記事のプログラムはESPのリアルタイムOSを使用しています。ただし、マルチタスクはmruby/cの機能によって実現しています。

  ### ブレッドボードに配線する

  ![](../images/breadboard_multi_tasks.png)

  前回までのLED回路とサーミスタ回路を組み合わせたものです。

  ### プログラムを書く

  ```bash
  cd $HOME/esp
  git clone https://github.com/hasumikin/mrubyc-template-esp32.git multi-tasks
  cd multi-tasks
  ```

  まずは、前回のプロジェクト（taking-temperature）と同様に `MRBC_USE_MATH` を有効にしましょう。

  `main/main.c`
  ```c
  #include "driver/gpio.h"
  #include "driver/adc.h"
  #include "esp_adc_cal.h"

  #include "mrubyc.h"

  #include "models/thermistor.h"
  #include "models/led.h"
  #include "loops/master.h"
  #include "loops/slave.h"

  #define DEFAULT_VREF    1100
  #define NO_OF_SAMPLES   64
  #define MEMORY_SIZE (1024*40)

  static esp_adc_cal_characteristics_t *adc_chars;
  static const adc_channel_t channel = ADC_CHANNEL_0; //GPIO4
  static const adc_atten_t atten = ADC_ATTEN_DB_11;
  static const adc_unit_t unit = ADC_UNIT_2;

  static uint8_t memory_pool[MEMORY_SIZE];

  static void c_gpio_init_output(mrb_vm *vm, mrb_value *v, int argc) {
    int pin = GET_INT_ARG(1);
    console_printf("init pin %d\\n", pin);
    gpio_set_direction(pin, GPIO_MODE_OUTPUT);
  }

  static void c_gpio_set_level(mrb_vm *vm, mrb_value *v, int argc){
    int pin = GET_INT_ARG(1);
    int level = GET_INT_ARG(2);
    gpio_set_level(pin, level);
  }

  static void c_init_adc(mrb_vm *vm, mrb_value *v, int argc){
    adc2_config_channel_atten((adc2_channel_t)channel, atten);
    adc_chars = calloc(1, sizeof(esp_adc_cal_characteristics_t));
    esp_adc_cal_characterize(unit, atten, ADC_WIDTH_BIT_12, DEFAULT_VREF, adc_chars);
  }

  static void c_read_adc(mrb_vm *vm, mrb_value *v, int argc){
    uint32_t adc_reading = 0;
    for (int i = 0; i < NO_OF_SAMPLES; i++) {
      int raw;
      adc2_get_raw((adc2_channel_t)channel, ADC_WIDTH_BIT_12, &raw);
      adc_reading += raw;
    }
    adc_reading /= NO_OF_SAMPLES;
    uint32_t millivolts = esp_adc_cal_raw_to_voltage(adc_reading, adc_chars);
    SET_INT_RETURN(millivolts);
  }

  void app_main(void) {
    mrbc_init(memory_pool, MEMORY_SIZE);

    mrbc_define_method(0, mrbc_class_object, "gpio_init_output", c_gpio_init_output);
    mrbc_define_method(0, mrbc_class_object, "gpio_set_level", c_gpio_set_level);
    mrbc_define_method(0, mrbc_class_object, "init_adc", c_init_adc);
    mrbc_define_method(0, mrbc_class_object, "read_adc", c_read_adc);

    mrbc_create_task( thermistor, 0 );
    mrbc_create_task( led, 0 );
    mrbc_create_task( master, 0 );
    mrbc_create_task( slave, 0 );
    mrbc_run();
  }
  ```

  `mrblib/loops/master.rb`
  ```ruby
  $status = "COLD"

  led = Led.new(19)

  while true
    case $status
    when "COLD"
      # do nothing
    when "HOT"
     led.turn_on
     sleep 0.1
     led.turn_off
    end
     sleep 0.1
  end
  ```

  `mrblib/loops/slave.rb`
  ```ruby
  thermistor = Thermistor.new

  while true
    temperature = thermistor.temperature
    puts "temperature: \#{temperature}"
    $status = if temperature > 30
      "HOT"
    else
      "COLD"
    end
    sleep 1
  end
  ```

  `mrblib/models/thermistor.rb`
  ```ruby
  B = 3435
  To = 25
  V = 3300 # mV
  Rref = 10_000 # Ohm

  class Thermistor
    def initialize
      gpio_init_output(0)
      gpio_set_level(0, 1)
      init_adc
    end

    def temperature
      vref = read_adc
      r = (V - vref).to_f / (vref.to_f/ Rref)
      1.to_f / ( 1.to_f / B * Math.log(r / Rref) + 1.to_f / (To + 273) ) - 273
    end
  end
  ```

  `mrblib/models/led.rb`
  ```ruby
  class Led
    def initialize(pin)
      @pin = pin
      gpio_init_output(@pin)
      turn_off
    end

    def turn_on
      gpio_set_level(@pin, 1)
      puts "turned on"
    end

    def turn_off
      gpio_set_level(@pin, 0)
      puts "turned off"
    end
  end
  ```

  ### 解説

  うまく実行できたでしょうか？　サーミスタを指で触って温度が30℃を超えると、LEDが点滅します。

  ![](../images/capture_multi_tasks.png)

  今回のプロジェクトには2つの無限ループ（master.rbとslave.rb）があり、それらがグローバル変数 `$status` を通して連携しています。

  このように複数のタスクがユーザからの入力を待ち受けたり、表示器をコントロールしたり、ネットワークの接続状況やリクエストを監視したりして相互に連携するのが、ファームウェア開発の面白さです。
  mruby/cを使えばこのようなマルチタスクを容易につくることができ、さらにRubyという言語の高い生産性を組み合わせられることがおわかりいただけたのではないかと思います。

  本記事はこれにて終了です。お付き合いありがとうございました。

EOF

taking_temperature = ERB.new <<~EOF
  ## 温度測定

  今回は、サーミスタを使用して温度を測定します。

  ### 使用パーツ
  - サーミスタ（103AT）
  - 抵抗器10kΩ
  - ブレッドボード

  ### サーミスタとは

  温度によって抵抗値が変動する素子です。その抵抗値と温度の関係は下のような近似式で表現できます。

  ![](../images/thermistor_approximation_1.png)

  これをTについて解くとこうなります。

  ![](../images/thermistor_approximation_2.png)

  下図はデータシートの一部です。値BはB定数と呼ばれ、サーミスタ素子ごとに決まった値があります。
  Toは25℃です。
  Rrefは回路ごとに任意に決めてよく、ここでは10kΩとします。

  ![](../images/thermistor_datasheet.png)

  _出典 http://akizukidenshi.com/download/ds/semitec/at-thms.pdf_

  あとはRつまりサーミスタの抵抗値がわかれば、温度Tを求めることができます。
  ではどうやってRを測定するのでしょうか？　下図をご覧ください。

  ![](../images/thermistor_circuit_resistance.png)

  この図の電圧値Vrefがわかればよいことを示しています。よく見ると、これもオームの法則ですね。

  ESP32には（そして他の多くのワンチップマイコンにも）、ADC（アナログ・デジタル・コンバータ）が搭載されており、Vrefの値を測定できます。
  ちなみにラズパイにはADCが搭載されていませんので、別途ADCチップを買ってきて回路を組む必要があります。

  ### ブレッドボードに配線する

  ESP32開発ボードと抵抗器、サーミスタをブレッドボードで接続しましょう。青い素子がサーミスタで、方向の決まりはありません。

  ![](../images/breadboard_thermistor.png)

  回路図と見比べることで、「IO0」ピンを3.3Vに固定し、「IO4」ピンがVrefを計測するということを理解できると思います。

  ### プログラムを書く

  いままでのハンズ・オンと同様にテンプレートをcloneします。

  ```bash
  cd $HOME/esp
  git clone https://github.com/hasumikin/mrubyc-template-esp32.git taking-temperature
  cd taking-temperature
  ```

  `main/main.c`
  ```c
  #include "driver/gpio.h"
  #include "driver/adc.h"
  #include "esp_adc_cal.h"

  #include "mrubyc.h"

  #include "models/thermistor.h"
  #include "loops/master.h"

  #define DEFAULT_VREF    1100
  #define NO_OF_SAMPLES   64
  #define MEMORY_SIZE (1024*40)

  static esp_adc_cal_characteristics_t *adc_chars;
  static const adc_channel_t channel = ADC_CHANNEL_0; //GPIO4
  static const adc_atten_t atten = ADC_ATTEN_DB_11;
  static const adc_unit_t unit = ADC_UNIT_2;

  static uint8_t memory_pool[MEMORY_SIZE];

  static void c_gpio_init_output(mrb_vm *vm, mrb_value *v, int argc) {
    int pin = GET_INT_ARG(1);
    console_printf("init pin %d\\n", pin);
    gpio_set_direction(pin, GPIO_MODE_OUTPUT);
  }

  static void c_gpio_set_level(mrb_vm *vm, mrb_value *v, int argc){
    int pin = GET_INT_ARG(1);
    int level = GET_INT_ARG(2);
    gpio_set_level(pin, level);
  }

  static void c_init_adc(mrb_vm *vm, mrb_value *v, int argc){
    adc2_config_channel_atten((adc2_channel_t)channel, atten);
    adc_chars = calloc(1, sizeof(esp_adc_cal_characteristics_t));
    esp_adc_cal_characterize(unit, atten, ADC_WIDTH_BIT_12, DEFAULT_VREF, adc_chars);
  }

  static void c_read_adc(mrb_vm *vm, mrb_value *v, int argc){
    uint32_t adc_reading = 0;
    for (int i = 0; i < NO_OF_SAMPLES; i++) {
      int raw;
      adc2_get_raw((adc2_channel_t)channel, ADC_WIDTH_BIT_12, &raw);
      adc_reading += raw;
    }
    adc_reading /= NO_OF_SAMPLES;
    uint32_t millivolts = esp_adc_cal_raw_to_voltage(adc_reading, adc_chars);
    SET_INT_RETURN(millivolts);
  }

  void app_main(void) {
    mrbc_init(memory_pool, MEMORY_SIZE);

    mrbc_define_method(0, mrbc_class_object, "gpio_init_output", c_gpio_init_output);
    mrbc_define_method(0, mrbc_class_object, "gpio_set_level", c_gpio_set_level);
    mrbc_define_method(0, mrbc_class_object, "init_adc", c_init_adc);
    mrbc_define_method(0, mrbc_class_object, "read_adc", c_read_adc);

    mrbc_create_task( thermistor, 0 );
    mrbc_create_task( master, 0 );
    mrbc_run();
  }
  ```

  `mrblib/loops/master.rb`
  ```ruby
  thermistor = Thermistor.new

  while true
    puts "temperature: \#{thermistor.temperature}"
    sleep 1
  end
  ```

  `mrblib/models/thermistor.rb`
  ```ruby
  B = 3435
  To = 25
  V = 3300 # mV
  Rref = 10_000 # Ohm

  class Thermistor
    def initialize
      gpio_init_output(0)
      gpio_set_level(0, 1)
      init_adc
    end

    def temperature
      vref = read_adc
      r = (V - vref).to_f / (vref.to_f/ Rref)
      1.to_f / ( 1.to_f / B * Math.log(r / Rref) + 1.to_f / (To + 273) ) - 273
    end
  end
  ```

  ### Mathクラスを有効化

  対数を計算するために、mruby/cのMathクラス（数学計算のためのライブラリ）を有効にしなければなりません。デフォルトではオフになっているためです。

  `components/mrubyc/mrubyc_src/vm_config.h` を開き、この行を探し、

  ```c
  #define MRBC_USE_MATH 0
  ```

  以下のように修正してください。0を1にするだけです。

  ```c
  #define MRBC_USE_MATH 1
  ```

  ### ビルド、実行

  もちろん `make flash monitor` で実行できます（menuconfig画面のシリアルポート設定もお忘れなく）。

  うまくいけば、1秒ごとに温度が表示されるはずです。

  ![](../images/capture_taking_temperature.png)

EOF

led_blinking = ERB.new <<~EOF
  ## Lチカ（発光ダイオード点滅）

  マイコン界におけるLチカは、ソフトウェア界におけるHello Worldのようなものです。LEDを光らせることができれば、あなたも立派なマイコン刑事（デカ）です。

  ### 使用パーツ
  - 赤色LED
  - 抵抗器330Ω
  - ジャンパーピン
  - ブレッドボード

  ### オームの法則

  LEDを光らせるためには基礎的な電気知識が必要です。下の写真を見てください。

  ![](../images/resistor.jpg)

  10キロオーム（=10000オーム）の抵抗（R）の両端に3ボルトの電位差（V）があるとき、流れる電流（I）は0.3ミリアンペアです。
  これはオームの法則の基本式 `V = I * R` を変形して得られる `I = V / R` から計算できます。

  次に、LEDのデータシートの一部を見てみましょう。
  Vfというのが、LEDの両端に発生する電位差です。ここではVfが2.1Vの赤色LEDを使います。

  ![](../images/led_datasheet.png)

  _出典 http://akizukidenshi.com/download/ds/optosupply/OSXXXX3Z74A_VER_A1.pdf_

  このLEDと330Ωの抵抗器を直列に接続し、回路全体に3.3Vの電圧をかけます。

  ![](../images/led_circuit.png)

  LEDは常に2.1Vの電位差を生む（←細かい議論を省略していることはおわかりいただけると思います）ので、抵抗器には1.2Vの電圧がかかります。
  オームの法則 (3.3 - 2.1) / 330 = 0.0036 より、電流は3.6mAになることがわかります。

  ### ブレッドボードに配線する

  ESP32開発ボードと抵抗器、LED、ジャンパワイヤをブレッドボードで接続しましょう。
  LEDは一般的に、長いピンがアノード（陽極）なので、長いピンにプラスの電位がかかるように接続してください。

  上の回路図では、アノードが2番ピン、カソードが1番ピンです。
  今回の回路の場合は間違えて逆に挿しても壊れませんので、光らなければ逆にしてみるというくらいの気楽さでOKです。

  ![](../images/LED.png)

  このブレッドボード図の場合、右にアノード（陽極）、左にカソード（陰極）を挿します。

  ![](../images/blinking_led_breadboard.png)

  上の配線図と下の写真は、おなじ接続を表現しています。

  ![](../images/photo_led_blinking.jpg)

  ESP32の「IO19」ピンに3.3Vが印加されます。
  となりの「GND」ピンはグランドつまり常に0Vになるピンです。ほかにもいくつかGNDピンがあることや、3V3（3.3Vのことです）や5Vと書かれたピンがあることも確認しておきましょう。
  USBケーブルから供給される電源電圧は5Vです。
  開発ボード内の降圧回路がESP32の標準動作電圧である3.3Vに降圧しています。

  ### プログラムを書く

  いままでのハンズ・オンと同様にテンプレートをcloneします。

  ```bash
  cd $HOME/esp
  git clone https://github.com/hasumikin/mrubyc-template-esp32.git led-blinking
  cd led-blinking
  ```

  `main/main.c`
  ```c
  #include "driver/gpio.h"

  #include "mrubyc.h"

  #include "models/led.h"
  #include "loops/master.h"

  #define MEMORY_SIZE (1024*40)

  static uint8_t memory_pool[MEMORY_SIZE];

  static void c_gpio_init_output(mrb_vm *vm, mrb_value *v, int argc) {
    int pin = GET_INT_ARG(1);
    console_printf("init pin %d\\n", pin);
    gpio_set_direction(pin, GPIO_MODE_OUTPUT);
  }

  static void c_gpio_set_level(mrb_vm *vm, mrb_value *v, int argc){
    int pin = GET_INT_ARG(1);
    int level = GET_INT_ARG(2);
    gpio_set_level(pin, level);
  }

  void app_main(void) {
    mrbc_init(memory_pool, MEMORY_SIZE);

    mrbc_define_method(0, mrbc_class_object, "gpio_init_output", c_gpio_init_output);
    mrbc_define_method(0, mrbc_class_object, "gpio_set_level", c_gpio_set_level);

    mrbc_create_task( led, 0 );
    mrbc_create_task( master, 0 );
    mrbc_run();
  }
  ```

  `mrblib/loops/master.rb`
  ```ruby
  led = Led.new(19)

  while true
    led.turn_on
    sleep 1
    led.turn_off
    sleep 1
  end
  ```

  `mrblib/models/led.rb`
  ```ruby
  class Led
    def initialize(pin)
      @pin = pin
      gpio_init_output(@pin)
      turn_off
    end

    def turn_on
      gpio_set_level(@pin, 1)
      puts "turned on"
    end

    def turn_off
      gpio_set_level(@pin, 0)
      puts "turned off"
    end
  end
  ```

  ### ビルド、実行

  お馴染みの `make flash monitor` で実行できます（menuconfig画面のシリアルポート設定もお忘れなく）。

  うまくいけば、1秒点灯し、1秒消灯する、という動作を繰り返します。

EOF


mac = String.new
wsl = String.new
msys2 = String.new

title = ERB.new("# ESP32 + mruby/c開発のための環境構築 - <%= platform %>\n\n")

cruby_version = "2.6.2"

platform = "macOS"
mac << title.result(binding)
mac << mac_usb.result(binding)
mac << mac_idf.result(binding)
mac << about_ruby.result(binding)
mac << mac_ruby.result(binding)

platform = "MSYS2"
msys2 << title.result(binding)
msys2 << msys2_intro.result(binding)
msys2 << msys2_usb.result(binding)
msys2 << msys2_idf.result(binding)
msys2 << about_ruby.result(binding)
msys2 << msys2_ruby.result(binding)


platform = "WSL"
wsl << title.result(binding)
wsl << wsl_intro.result(binding)
wsl << wsl_usb.result(binding)
wsl << wsl_idf.result(binding)
wsl << about_ruby.result(binding)
wsl << wsl_ruby.result(binding)

File.open("ja/doc_1_introduction.md", "w") do |f|
  f.puts introduction.result(binding)
end

%w(mac wsl msys2).each_with_index do |platform, index|
  File.open("ja/doc_#{index + 2}_#{platform}.md", "w") do |f|
    f.puts(eval(platform))
  end
end

platform = "WSL"
File.open("ja/doc_5_hello_world_posix.md", "w") do |f|
  f.puts "# ハンズ・オン - 1\n\n"
  f.puts hello_world_posix.result(binding)
end

File.open("ja/doc_6_hello_world_esp.md", "w") do |f|
  f.puts "# ハンズ・オン - 2\n\n"
  f.puts hello_world_esp.result(binding)
  f.puts win_usb_confirm.result(binding)
  f.puts mac_usb_confirm.result(binding)
  f.puts hello_world_esp_run.result(binding)
end

%w(led_blinking taking_temperature multi_task).each_with_index do |handson, index|
  File.open("ja/doc_#{index + 7}_#{handson}.md", "w") do |f|
    f.puts "# ハンズ・オン - #{index + 3}\n\n"
    f.puts eval(handson).result(binding)
  end
end

