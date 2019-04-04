require 'erb'


introduction = ERB.new <<~EOF
  # Environment construction for ESP32 + mruby/c development-Introduction

  Convert mruby source code (extension ". rb") to intermediate byte code of extension ". c" by using  mrbc (mruby compiler).The basic flow of mruby/c application development is to operate it (and the mruby/c runtime program) from "main.c".

  To develop ESP32 firmware with mruby/c, you need to set up ESP-IDF and related tools provided by Espressif.
  
  ESP-IDF contains a library that can be used for ESP firmware development and supports the creation of executable files.

  In the following "ESP development environment" and its construction is explained
  "ESP development environment" : development environment in which ESP-IDF and related tools are setup
  
  ## Setting up Development Environment

  ### macOS
  You can build ESP development environment on macOS native environment.

  [Link]

  ### Windows
  The ESP development environment does not work in the native Windows environment,but using a quasi-Linux environment enables ESP development.
  There are two ways to do this:

  #### Windows10 (64 bit version)
  Use Windows Subsystem for Linux (WSL)

  [Link]

  #### Windows other than above
  Use MSYS2

  [Link]

  ### Linux Distributions
  Although we do not have environment configuration manual for Linux, it is not difficult for programmers who use Linux as a host OS.
  Linux用の環境構築マニュアルは用意しませんが、ホストOSとしてLinuxをお使いになるようなプログラマにとっては難しいことではありません。
  refer to Ubuntu startup in the WSL manual for Windows and  build the ESP development environment.

  ## About Virtual Environment, Docker
  About Virtual Box: It is possible to build ESP development environment in VirtualBox running on  Linux or Windows 10 .But there are reports that USB port is not always recognized properly. 

  Therefore, this manual assumes that you build an ESP development environment on the host OS.

  If you want to use a virtual environment, please create an ESP development environment on the guest OS after creating the environment on the host OS first in order to proceed the workshop smoothly. And please share information about how you can and can not do it well.

  Also, Docker seems to have problems with USB drivers in general, so please think that it can not be used (please try and let me know if you can use it).
EOF

about_ruby = ERB.new <<~EOF
  ## About Ruby

  You need CRuby (the most common Ruby implementation) to build mruby.

  <% if platform != "MSYS2" %>
    There are several ways to install Ruby, but it is recommended to use the tool "rbenv" to make multiple Ruby coexist in the system.

    **ワークショップの後半に時間があれば筆者作のmruby/c用便利ツール `mrubyc-utils` を使う予定があり、rbenvの環境のほうがスムーズに使用できます。
  <% end %>

EOF

mac_usb = ERB.new <<~EOF
  ## USB Driver Installation

  Install「USB to UART Bridge Driver」
  Download and install the one that is compatible with your OS from the following page.
  https://www.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers

  If the dialog "System Extension Blocked" is displayed during installation, open "System Preferences"-> "Security & Privacy"-> "General" and then click "Allow". (it does not appear to be blocked in all environments).

  ![](../images/mac-01.png)

EOF

mac_idf = ERB.new <<~EOF
  ## Setup related tools

  Download and unzip the ESP related tools.
  ```bash
  mkdir -p $HOME/esp
  cd $HOME/esp
  wget https://dl.espressif.com/dl/xtensa-esp32-elf-osx-1.22.0-80-g6c4433a-5.2.0.tar.gz
  tar -xzf xtensa-esp32-elf-osx-1.22.0-80-g6c4433a-5.2.0.tar.gz
  rm xtensa-esp32-elf-osx-1.22.0-80-g6c4433a-5.2.0.tar.gz
  ```

  If you use pyenv or any other for version control of python, you may want to fix the version to the system default python as follows.
  If you are not using pyenv or related, or using but you can handle the problem  by yourself then  you can skip this configuration.
  ```bash
  cd $HOME/esp
  echo 'system' > .python-version
  ```

  Set the environment variable in the .bash_profile file and enable it (read it as appropriate, for example, if you are using zsh instead of bash).
  ```bash
  echo 'export PATH="$HOME/esp/xtensa-esp32-elf/bin:$PATH"' >> $HOME/.bash_profile
  echo 'export IDF_PATH="$HOME/esp/esp-idf"' >> $HOME/.bash_profile
  source $HOME/.bash_profile
  ```

  Clone ESP-IDF repo
  ```bash
  cd $HOME/esp
  git clone --recursive https://github.com/espressif/esp-idf.git
  ```

  Install tools related to Python
  ```bash
  sudo easy_install pip
  python -m pip install --user -r $IDF_PATH/requirements.txt
  ```

EOF

wsl_usb = ERB.new <<~EOF
  ## About USB driver
  
  The ESP32 Development Kit [ESP32-DevKitC] (https://www.espressif.com/en/products/hardware/esp32-devkitc/overview) to be used in this workshop has a serial-to-USB converter chip called "CP2102N". This driver has to be installed on Windows
  If you can not enable the Pololu driver described below, give up the WSL and select the MSYS2 environment.
  Also, if your operating system is other than the 64-bit version of Windows 10, you will build an MSYS2 environment anyway, so you can use either USB driver.
  As of March 2019, the drivers provided by Silicon Labs can not communicate as expected by WSL and ESP32. It did not work at least in my environment. There is no problem if it is MSYS2.
   [Please note] The combination of the driver and WSL downloaded from the following page may not work as expected.
  （This is NG）https://jp.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers

  Instead, install the driver that can be downloaded from the Pololu page.

  https://www.pololu.com/docs/0J7/all#2

  （Direct link to driver file：https://www.pololu.com/file/0J14/pololu-cp2102-windows-121204.zip ）

  Please unzip the zip file and double click "pololu-cp2102-setup-x64.exe" to install it.

  ### What happens if the Silicon Labs driver is installed?

  You need to "completely" remove installed drivers.

  Uninstalling the device does not delete the driver file, and Windows automatically assigns a new date (by the plug and play function).
  The date of the Silicon Labs driver is newer than that of Polulu, so Windows will automatically select the Silicon Labs driver and can not enable the Pololu driver at the user's option.
  ### Check installed drivers

  Start Windows Powershell or Command Prompt (CMD), and enter the following command.
  ```bash
  pnputil -e
  ```
  copy and paste all into a text editor to find information about the driver.
  It looks like my environment where both drivers were installed.
  `oem9.inf` is a Silicon Labs system definition file, and` oem158.inf` is a Pololu system definition file.
  Notice the difference in the value of __Driver date and version__.
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

  
  In this situation, the newer Silicon Labs driver will be used and this should be removed.

  ### Remove the device driver completely

  [Caution] There is a risk that Windows will not operate properly by this procedure. Please do it at your own risk.

  Please uninstall the driver using Device Manager first.

  ![](../images/uninstall_device.png)

  Then start Windows Powershell or Command Prompt (CMD) as __administrator __ and delete the system definition with the following command.
  Note that the file name `oem9.inf` depends on the __environment__.
  ```bash
  pnputil -d oem9.inf
  ```

  
  If you see `Driver package deleted successfully.`, the deletion is successful.

  
If you can not delete for some reason, or if you are not sure what drivers are already installed, please select MSYS2 environment construction instead of WSL. Or I think it is better to build both and use the one that can be used on the day of the workshop.

EOF

msys2_usb = ERB.new <<~EOF
  ## Install USB driver

  The ESP32 development kit used in this workshop uses a serial-to-USB converter chip called "CP2102N", and this driver needs to be installed on Windows.

  Download and install the appropriate driver for your operating system from either of the following pages. If there is a possibility of using WSL together, please use the latter (Pololu) driver. For the reason, refer to the WSL environment configuration manual.

  https://jp.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers

  https://www.pololu.com/docs/0J7/all#2

EOF

msys2_intro = ERB.new <<~EOF
  ## Build ESP development environment on Windows "MSYS2"

  ※If your operating system is a 64-bit version of Windows 10 and you have enabled the Pololu USB driver, we recommend that you build a WSL environment.

  
  MSYS2 is an integrated package for emulating Unix command line environment on Windows. Since Espressif offers an all-in-one ZIP archive with MSYS2 with various necessary tools set up, using it as it is is the easiest development environment.

  
  If you would like to install dependent tools one by one on "raw MSYS2", you can find the information on the following page. However, I have not verified.

  https://docs.espressif.com/projects/esp-idf/en/latest/get-started/windows-setup-scratch.html

EOF

msys2_idf = ERB.new <<~EOF
  ## Environment

  ### Download and place MSYS2 (and tools)

  
  Download the all-in-one ZIP archive from the link below and unzip it.

  https://dl.espressif.com/dl/esp32_win32_msys2_environment_and_toolchain-20181001.zip

  You can unzip it to any location, but in general it seems to be somewhere in the C drive where Windows is installed.
  Decompression takes quite a while. It takes time to unzip and move the folder, so unzip it to the location you want from the beginning.

  There are things to be aware of when unpacking and placing. In the process, some anti-virus mechanism may delete some files automatically. If this happens, it can not be used properly.

  If the `msys32` directory looks like the image below when you unzip it, it's probably not a problem.

  ![](../images/msys2.png)

  At first, the etc directory etc. were deleted in my environment, so I unpacked and dealt with it on virtual Linux.

  However, after that, even if I tried to reproduce it for writing this article, I did not reproduce it, so I don't really know what caused it or how to avoid it.

  ### MSYS2 startup and setting

  Start `mingw32.exe` in the` msys32` directory. (NOT `mingw64.exe`).
  This doesn't matter if your Windows is a 64-bit or 32-bit version. ESP-IDF does not support mingw64.

  From now on, use `mingw32.exe` every time you start MSYS2.

  Set environment variables in the .bash_profile file and activate it.
  ```bash
  echo 'export IDF_PATH="$HOME/esp/esp-idf"' >> $HOME/.bash_profile
  source $HOME/.bash_profile
  ```

  Its easy with MacOs as related tools and WSL are already installed
  ```bash
  mkdir $HOME/esp && cd $HOME/esp
  git clone --recursive https://github.com/espressif/esp-idf.git
  ```

EOF


wsl_intro = ERB.new <<~EOF
  ## Build ESP development environment on Windows "Subsystem for Linux (WSL)"

  WSL is an environment that can execute Linux executables natively on 64-bit Windows 10 (or Windows Server).
  Use MSYS2 because WSL can not be used with Windows 8 or earlier or 32-bit version Windows 10.

  By installing ESP-IDF in WSL, you can build an environment equivalent to the ESP development environment on Linux.
  As the firmware build speed is much faster than MSYS2 (or rather MSYS2 is much slower), if you are going to build a new environment, try building a WSL environment first.

EOF

wsl_idf = ERB.new <<~EOF
  ## Environment

  ### Windows Update

  First, please update Windows 10 to the latest state provided by Microsoft. On Windows that has not been updated, it is possible that some of the features of WSL may not be available.

  ### Install WSL (Ubuntu)

  Click "Settings" → "Apps and Features" → "Programs and Features".
  ![](../images/wsl-01-en.png)

  Click "Turn Windows features on or off", check "Windows Subsystem for Linux" in the "Windows Features" dialog, and click "OK."
  ![](../images/wsl-02-en.png)

  Click "Restart now" as it will prompt you to reboot.
  ![](../images/wsl-03-en.png)

  After rebooting, search for "Ubuntu" in the "Microsoft Store" app and click to install.
  ![](../images/wsl-04.png)

  Launch the "Ubuntu" app (this is the Ubuntu version of WSL).
  ![](../images/wsl-05.png)

  The first time you start up, you need to set the Unix username and password.

  __ This username should be the same as your Windows login account. Otherwise, the shared directory between Windows and WSL will not be found. __

  ![](../images/wsl-06.png)

  ### Setup environment on Ubuntu

  Install related packages.
  ```bash
  sudo apt update
  sudo apt install tree gcc git wget make libncurses-dev flex bison \\
    gperf python python-pip python-setuptools python-serial \\
    python-cryptography python-future python-pyparsing
  ```

  Download, unzip, and install the tools provided by Espressif.
  ```bash
  mkdir $HOME/esp
  cd $HOME/esp
  wget https://dl.espressif.com/dl/xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz
  tar -xzf xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz
  rm xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz
  ```

  Set environment variables in .profile file and enable it.
  ```bash
  echo 'export PATH="$HOME/esp/xtensa-esp32-elf/bin:$PATH"' >> $HOME/.profile
  echo 'export IDF_PATH="$HOME/esp/esp-idf"' >> $HOME/.profile
  source $HOME/.profile
  ```

  Clone ESP-IDF repo
  ```bash
  cd $HOME/esp
  git clone --recursive https://github.com/espressif/esp-idf.git
  ```

  Install python related tools.
  ```bash
  python -m pip install --user -r $IDF_PATH/requirements.txt
  ```

  Since you need serial port privileges, add your own user to the dialout group.
  ```bash
  sudo usermod -a -G dialout $USER
  ```

  ### About program creation directory
  If you intend to write a program with an editor that starts separately on Windows, not Vim on Ubuntu, you may want to check about directory sharing between Windows and WSL.

  `/mnt/c/Users/[usename]/esp` on WSL matches` c:\Users\[Windows account name]/esp` on Windows.
  As mentioned earlier, `[usename]` and `[Windows account name]` must be the same. ie; the username created when you  started WSL (Ubuntu) initially should be same as the Windows account name.  Please be careful about that.
EOF

hello_world_posix = ERB.new <<~EOF
  ## Hello mruby/c World!

  mruby / c runs not only on microcomputers but also on personal computers (POSIX). Let's output Hello World.

  I have prepared a repository that already has Makefile, main.c, etc. Please git clone.

  ### git clone
  ```bash
  cd $HOME/esp
  git clone https://github.com/hasumikin/hello-mrubyc-world-posix
  cd hello-mrubyc-world-posix
  ```

  ### Writing a Ruby Program

  Open `mrblib/loops/master.rb` in a text editor and save it with the following content.

 <%= "For WSL users: If you want to use an editor on Windows without using the WSL CUI editor, check the shared directory described in the section on environment construction. Where is the shared directory? If you do not know, you can not proceed with the workshop, which is very important. "If platform ==" WSL "%>
  
  ```ruby:mrblib/loops/master.rb
  while true
    puts "Hello World!"
    sleep 1
  end
  ```

  ### Build & Run

  ```bash
  make && ./main
  ```

  If you get the following screen with the above command, it is successful! `Hello World!` Is output every second.

  This program can be terminated with `ctrl + C`.
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

  まずは、前回のプロジェクト（measuring-temperature）と同様に `MRBC_USE_MATH` を有効にしましょう。

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

measuring_temperature = ERB.new <<~EOF
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
  git clone https://github.com/hasumikin/mrubyc-template-esp32.git measuring-temperature
  cd measuring-temperature
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

  ![](../images/capture_measuring_temperature.png)

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

%w(led_blinking measuring_temperature multi_task).each_with_index do |handson, index|
  File.open("ja/doc_#{index + 7}_#{handson}.md", "w") do |f|
    f.puts "# ハンズ・オン - #{index + 3}\n\n"
    f.puts eval(handson).result(binding)
  end
end

