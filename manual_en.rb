require 'erb'


introduction = ERB.new <<~EOF
  # Environment construction for ESP32 + mruby/c development - Introduction

  Convert mruby source code (extension ".rb") to intermediate byte code of extension ".c" by using  mrbc (mruby compiler).The basic flow of mruby/c application development is to operate it (and the mruby/c runtime program) from "main.c".

  To develop ESP32 firmware with mruby/c, you need to set up ESP-IDF and related tools provided by Espressif.

  ESP-IDF contains a library that can be used for ESP firmware development and supports the creation of executable files.

  The followings are instructions how to construct "ESP development environment"*.
  *"ESP development environment" : development environment in which ESP-IDF and related tools are setup.

  ## Setting up Development Environment

  ### macOS
  You can build ESP development environment on macOS native environment.

  See [manual for macOS](https://hackmd.io/s/HkVNLyh54)

  ### Windows
  The ESP development environment does not work in the native Windows environment,but using a semi Linux environment enables ESP development.
  There are two ways to do this:

  #### Windows10 (64 bit version)
  Use Windows Subsystem for Linux (WSL)

  See [manual for Windows10(64bit)](https://hackmd.io/s/S1sMdyn5E)

  #### Windows other than above
  Use MSYS2

  See [manual for other than Windows10(64bit)](https://hackmd.io/s/BkslFkn94)

  ### Linux Distributions
  Although we do not have environment configuration manual for Linux, it is not difficult for programmers who use Linux as a host OS.
  Refer to Ubuntu startup in the WSL manual for Windows and  build the ESP development environment.

  ## About Virtual Environment, Docker
  About Virtual Box: It is possible to build ESP development environment in VirtualBox running on Linux on Windows 10 Professional. But there are some reports that USB port is not always recognized properly.

  Therefore, this manual assumes that you build an ESP development environment on the host OS.

  If you want to use a virtual environment, please create an ESP development environment on the guest OS after creating the environment on the host OS first in order to proceed the workshop smoothly. And please share information about how you can and can not do it well.

  Also, Docker seems to have problems with USB drivers in general, so please think that it can not be used (but please try if you are interested in it and let me know if you can use it).
EOF

about_ruby = ERB.new <<~EOF
  ## About Ruby

  You need CRuby (the most common Ruby implementation) to build mruby.

  <% if platform != "MSYS2" %>
    There are several ways to install Ruby, but it is recommended to use the tool "rbenv" to make multiple Ruby coexist in the system.

    **if we have time after the workshop we will use a utility named `mrubyc-utils` which I made. It moves smoothly if you use rbenv
  <% end %>

EOF

mac_usb = ERB.new <<~EOF
  ## USB Driver Installation

  Install「USB to UART Bridge Driver」.
  Download and install the one that is compatible with your OS from the following page.
  https://www.silabs.com/products/development-tools/software/usb-to-uart-bridge-vcp-drivers

  If the dialog "System Extension Blocked" is displayed during installation, open "System Preferences"-> "Security & Privacy"-> "General" and then click "Allow". (it does not appear to be blocked in all environments).

  ![](<%= images_host %>images/mac-01.png)

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
  
  The ESP32 Development Kit [ESP32-DevKitC] (https://www.espressif.com/en/products/hardware/esp32-devkitc/overview) to be used in this workshop has a serial-to-USB converter chip called "CP2102N". This driver has to be installed on Windows.
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
  It looks as follows in my environment where both drivers were installed.
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

  
  In this situation, the newer Silicon Labs driver will be used, so this should be removed.

  ### Remove the device driver completely

  [Caution] There is a risk that Windows will not operate properly by this procedure. Please do it at your own risk.

  Please uninstall the driver using Device Manager first.

  ![](<%= images_host %>images/uninstall_device.png)

  Then start Windows Powershell or Command Prompt (CMD) __as administrator__ and delete the system definition with the following command.
  Note that the file name `oem9.inf` would be different __depends on the environment__.
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

  
  MSYS2 is an integrated package for emulating Unix command line environment on Windows. Since Espressif offers an all-in-one ZIP archive with MSYS2 with various necessary tools set up, using it as it is is the easiest way to build the development environment.

  
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

  ![](<%= images_host %>images/msys2.png)

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
  ![](<%= images_host %>images/wsl-01-en.png)

  Click "Turn Windows features on or off", check "Windows Subsystem for Linux" in the "Windows Features" dialog, and click "OK."
  ![](<%= images_host %>images/wsl-02-en.png)

  Click "Restart now" as it will prompt you to reboot.
  ![](<%= images_host %>images/wsl-03-en.png)

  After rebooting, search for "Ubuntu" in the "Microsoft Store" app and click to install.
  ![](<%= images_host %>images/wsl-04.png)

  Launch the "Ubuntu" app (this is the Ubuntu version of WSL).
  ![](<%= images_host %>images/wsl-05.png)

  The first time you start up, you need to set the Unix username and password.

  __ This username should be the same as your Windows login account. Otherwise, the shared directory between Windows and WSL will not be found. __

  ![](<%= images_host %>images/wsl-06.png)

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

 <%= "For WSL users: If you want to use an editor on Windows without using the WSL CUI editor, check the shared directory described in the section on environment construction. Where is the shared directory? If you do not know, you can not proceed with the workshop, which is very important." if platform =="WSL" %>
  
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
  ![](<%= images_host %>images/hello_world.png)

EOF

mac_ruby = ERB.new <<~EOF
  ### Ruby Installation

  Assuming that homebrew has been installed, the procedure is explained. If you want to install rbenv without using homebrew, refer to the relevant part of the WSL environment configuration manual.

  Install rbenv and ruby-build, and pass the path.
  ```bash
  brew install openssl readline zlib rbenv ruby-build
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
  echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.bash_profile
  source $HOME/.bash_profile
  ```

  Ruby is installed on macOS, but please install a new version.
  ```bash
  rbenv install <%= cruby_version %>
  ```
  If you get an error such as `The Ruby zlib extension was not compiled.` at this time, you may be able to install it as follows.
  ```bash
  RUBY_CONFIGURE_OPTS="--with-zlib-dir=$(brew --prefix zlib)" rbenv install <%= cruby_version %>
  ```

  `zlib` may be another library such as` readline`. Please replace as appropriate and take action.

  Finally install mruby. Since mruby 2.x is not integrated with mruby / c, we use 1.4.1.
  ```bash
  rbenv install mruby-1.4.1
  ```

EOF

msys2_ruby = ERB.new <<~EOF
  ### Ruby installation (use Rubyinstaller2)

  ※ It seems to be possible to install rbenv in MSYS2, but it is not easy. If you want to try it, check it out on the net.

  First install CRuby. This is because you need CRuby to build mruby.

  Please do it on the GUI of Windows, not on MSYS2. Download a dedicated installer for using Ruby on Windows.

  https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-<%= cruby_version %>-1/rubyinstaller-<%= cruby_version %>-1-x86.exe

  Download the 32-bit Ruby installer. We use `mingw32.exe` as a POSIX emulator in order to use ESP-IDF with MSYS2, so it is adapted to this.

  If the host OS is a 64-bit version of Windows 8 etc., it may be a Ruby installer for 64-bit (rubyinstaller-<%= cruby_version %>-1-x64.exe), but it has not been verified. Generally, 32-bit executable files work on 64-bit versions of Windows. The reverse does not work.
  Double-click the downloaded file, select "I accept the license" and press "NEXT".
  ![](<%= images_host %>images/rubyinstaller2-01.png)

  Since "Use UTF-8 as default external encoding." would be unchecked, check it and press "Install" (Encoding is not related to this workshop, but used for other purposes Sometimes this looks better).
  ![](<%= images_host %>images/rubyinstaller2-02.png)

  Confirm that "Run 'ridk ..." is checked, and press "Finish".
  ![](<%= images_host %>images/rubyinstaller2-03.png)

  When the installation of CRuby is completed, this screen for installing the related tools will be displayed. Enter "3" and press the enter (return) key.
  ![](<%= images_host %>images/rubyinstaller2-04.png)

  Do not enter anything on this screen, just press the Enter key to finish installing Ruby.
  ![](<%= images_host %>images/rubyinstaller2-05.png)

  Pass the path to the MSYS2 command line.
  ```bash
  cd $HOME
  echo 'export PATH="/c/Ruby26/bin:$PATH"' >> $HOME/.bash_profile
  source $HOME/.bash_profile
  ```

  confirm
  ```bash
  ruby --version
  ```

  it is ok if you output like `ruby <%= cruby_version %>pXX (2019-XX-XX revision XXXXX) [i386-mingw32]` this command

  Next install mruby. Since mruby 2.x is not integrated with mruby / c, we use 1.4.1.
  ```bash
  cd $HOME
  wget https://github.com/mruby/mruby/archive/1.4.1.zip
  unzip 1.4.1.zip
  cd mruby-1.4.1
  ruby minirake
  ```

  Pass the path
  ```bash
  echo 'export PATH="$HOME/mruby-1.4.1/build/host/bin:$PATH"' >> $HOME/.bash_profile
  source $HOME/.bash_profile
  ```

  Confirm
  ```bash
  mrbc --version
  ```

  If you output `mruby 1.4.1 (2018-4-27)` by the above command, it is OK.

EOF

wsl_ruby = ERB.new <<~EOF
  ### Ruby Installation

  Install rbenv
  ```bash
  cd $HOME
  git clone https://github.com/rbenv/rbenv.git $HOME/.rbenv
  ```

  Pass the path
  ```bash
  echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> $HOME/.profile
  echo 'eval "$(rbenv init -)"' >> $HOME/.profile
  source .profile
  ```

  Install ruby-build
  ```bash
  mkdir -p "$(rbenv root)"/plugins
  git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
  ```

  There is no system default Ruby in WSL. Since you need CRuby to build mruby, first install CRuby.
  It takes a very long time, so please do not worry.
  ```bash
  sudo apt-get install -y libssl-dev libreadline-dev zlib1g-dev
  rbenv install <%= cruby_version %>
  ```

  Set CRuby installed just now as global default.
  ```bash
  rbenv global <%= cruby_version %>
  ruby --version
  ```

  上のコマンドで、 ruby 2.6.2pXX (2019-XX-XX revision XXXXXX) [x86_64-linux] のように出力されればOKです。

  Install mruby. As of now, mruby-2.x can not be used for mruby/c, so please install 1.4.1.
  ```bash
  rbenv install mruby-1.4.1
  ```

EOF

hello_world_esp = ERB.new <<~EOF
  ## Hello ESP32 World!

  Create a Hello World program that works on ESP32.

  Clone the application template for ESP32 & mruby / c from GitHub.

  ```bash
  cd $HOME/esp
  git clone https://github.com/hasumikin/mrubyc-template-esp32.git hello-mrubyc-world-esp32
  cd hello-mrubyc-world-esp32
  ```

  Let's look at the directory structure. Write our Ruby source code in `mrblib/`. Write the C source code in `main/`.

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

  
  Edit the three source code as follows.
  Overwrite existing files and create new files that do not exist.

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

  ### Build

  The build starts when you enter the `make` command.

  The first make of the ESP project will be a screen similar to `make menuconfig`, as shown in the image below. You can exit menuconfig by pressing the Escape key twice or selecting <Exit>. You need to set menuconfig for each project (application) every time.
  If the size of the terminal (window) is too small, you will get an error saying "Can't create menuconfig screen".
  Increase the window size and `make` again.

  ![](<%= images_host %>images/menuconfig-01.png)

  The configuration file should be generated automatically (this will cause the configuration screen to disappear on the next `make` command. The command to display explicitly is` make menuconfig`), and the project should begin to build. It is normal if it ends with the output like the following image.

  ![](<%= images_host %>images/hello_world_build.png)

  If it did not end normally, it is possible that you skipped some part of the previous procedure or did not follow the procedure correctly due to a typo and proceed without noticing the error message.

  The next step is to write the program to ESP32, but before that, check the USB connection and set the serial port.
  We will explain Windows and macOS respectively.

### USB connection check and serial port setting

EOF

win_usb_confirm = ERB.new <<~EOF
  #### For Windows: Check the COM port number

   Open the "Device Manager" application and connect the micro connector side of the USB cable to the ESP32 development board and the type A connector to a Windows PC in that state.
   Since "USB to UART bridge driver" is installed, items like "Silicon Labs CP210x USB to UART Bridge (COM5)" should appear in "Port (COM and LPT)" as shown in the image. The name may differ depending on the environment.
  ![](<%= images_host %>images/device_manager-en.png)

  The last digit "5" of "(COM5)" may be different in your environment.
  Please remember this number.

EOF

mac_usb_confirm = ERB.new <<~EOF
  #### For macOS：Check the serial port device file name

  With the ESP32 development board not connected to the USB port, try typing `ls -l /dev/cu.*`.
  Next, with the ESP32 development board connected to mac, type the same command. If "USB to UART bridge driver" is correctly installed, one more output should be added. And the device file should be named something like "/dev/cu.SLAB_USBtoUART".

  Make a note of this string.

EOF

hello_world_esp_run = ERB.new <<~EOF
  ### Windows & macOS common：Set Serial port
  ```bash
  make menuconfig
  ```
 Start the setting screen with the above command, select "Serial flasher config" → "(/dev/ttyUSB0) Default serial port" with the cursor key and the enter key, change the port to the value ** described below ** Confirm with the Enter key, and then press the Escape key several times to confirm if you want to save. Select "<Yes>".
  - macOS：a string like 「/dev/cu.SLAB_USBtoUART」you took note of earlier
  - WSL：「/dev/ttyS5」（Please change the last number to the same one as the COM number checked earlier）
  - MSYS2：「COM5」（The same string as the "COM name" confirmed above. Unlike WSL, `/dev/` part is unnecessary）

  ![](<%= images_host %>images/menuconfig-01.png)
  ![](<%= images_host %>images/menuconfig-02.png)
  ![](<%= images_host %>images/menuconfig-03.png)
  ![](<%= images_host %>images/menuconfig-04.png)

  ### Write a project and execute

  The project is written by this command. As with the general behavior of the make command, the build is executed first if necessary because of the dependencies calculated from the modification time of the program file.
  ```bash
  make flash
  ```

  This command reboots ESP32 and executes the firmware from the beginning, and writes in-process debug information etc. to standard output.
  ```bash
  make monitor
  ```

  How about that? Did you output `Hello World!` Every second as you did hello-mrubyc-world-posix (Hello World on PC)? If you are having trouble, please reconsider the procedure.
  The console monitor (make monitor) of ESP-IDF can be terminated with `ctrl +]`.

  By the way, the above two commands can be executed at one time as follows.
  ```bash
  make flash monitor
  ```

EOF


multi_task = ERB.new <<~EOF
  ## Multitasking with mruby/c

  Until the last time, I have seen basic usage of microcontrollers and peripherals.
  The final session will create a project that uses the multitasking function that is one of the features of mruby/c.

  ### Used parts
  - Red LED
  - Thermistor（103AT）
  - Resistor 330Ω
  - Resistor 10kΩ
  - Jumper pin
  - bread board

  ### What is a task?

  It has almost the same meaning as "thread" in Linux and Windows.
  The function that controls the allocation of CPU time for each thread and allows multiple threads (processing blocks) to proceed simultaneously is called multithreading.

  Although the OS controls multitasking even on microcomputers that have RTOS (real-time OS), mruby / c includes a mechanism to realize multitasking without an OS, which makes it possible to save memory while using it It is easy to develop high quality firmware.


  ※The program in this article uses ESP's real time OS. However, multitasking is realized by the mruby/c function.

  ### Wire to the breadboard

  ![](<%= images_host %>images/breadboard_multi_tasks.png)

  
  It combines the LED circuit and thermistor circuit up to the previous time.

  ### Write a program

  ```bash
  cd $HOME/esp
  git clone https://github.com/hasumikin/mrubyc-template-esp32.git multi-tasks
  cd multi-tasks
  ```

  First, let's enable `MRBC_USE_MATH` as in the previous project (taking-temperature).

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

  ### Comments

  Were you able to do it well? When the temperature exceeds 30°C by touching the thermistor with a finger, the LED blinks

  ![](<%= images_host %>images/capture_multi_tasks.png)

  There are two infinite loops (master.rb and slave.rb) in this project, which are linked through the global variable `$ status`.

  It is the fun of firmware development that multiple tasks wait for input from the user, control the display, monitor the network connection status and requests, and cooperate with each other.
  If you use mruby / c, you can easily create such multitasks, and you may also know that you can combine the high productivity of the Ruby language.
  
  This article is the end of this. thank you for your company.

EOF

taking_temperature = ERB.new <<~EOF
  ## Taking temperature

  This time, the temperature is took using a thermistor.

  ### Used parts
  - Thermistor（103AT）
  - Resistor 10kΩ
  - bread board

  ### What is a thermistor?

  It is an element whose resistance varies with temperature. The relation between the resistance value and the temperature can be expressed by the following approximate expression.

  ![](<%= images_host %>images/thermistor_approximation_1.png)

  This is solved for T.

  ![](<%= images_host %>images/thermistor_approximation_2.png)

  The figure below is a part of the data sheet. The value B is called the B constant and has a fixed value for each thermistor element.
  To is 25℃
  Rref may be arbitrarily determined for each circuit, and here is 10kΩ.

  ![](<%= images_host %>images/thermistor_datasheet.png)

  Source: http://akizukidenshi.com/download/ds/semitec/at-thms.pdf_

  After that, if you know the resistance value of R, that is, the thermistor, you can find the temperature T.
  So how do you measure R? Please see the figure below.

  ![](<%= images_host %>images/thermistor_circuit_resistance.png)

  It indicates that the voltage value Vref in this figure should be known. If you look closely, this is also Ohm's law.


  The ESP32 (and many other one-chip microcontrollers) has an ADC (analog-to-digital converter) that can measure the value of Vref.
  By the way, as there is no ADC installed in Las Paz, it is necessary to buy a separate ADC chip and build a circuit.

  ### Wire to the breadboard

  Connect the ESP32 development board with resistors and thermistors on a breadboard. The blue element is a thermistor, and there is no rule of direction.

  ![](<%= images_host %>images/breadboard_thermistor.png)

  By comparing with the circuit diagram, you can understand that the “IO0” pin is fixed at 3.3 V and the “IO4” pin measures Vref.

  ### Write a program

  The template is cloned in the same way as the previous hands-on.

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

  ### Enable Math class

  In order to calculate the logarithm, you need to activate the mruby/c Math class (library for mathematical calculations). It is off by default.

  Open`components/mrubyc/mrubyc_src/vm_config.h` and find the following line

  ```c
  #define MRBC_USE_MATH 0
  ```

  please correct as follows. Set 0 to 1

  ```c
  #define MRBC_USE_MATH 1
  ```

  ### Build, Run

  Of course you can do this with `make flash monitor` (and don't forget to set the serial port on the menuconfig screen).


  Hopefully, the temperature should be displayed every second.

  ![](<%= images_host %>images/capture_taking_temperature.png)

EOF

led_blinking = ERB.new <<~EOF
  ## blink LED (light emitting diode blinks)

  Blinking LED in the microcontroller world is like Hello World in the software world. If you can light the LED, you are also a good microcomputer detective.

  ### Used parts
  - Red LED
  - 330Ω resistor
  - Jumper pin
  - bread board

  ### Ohm's Law

  Basic electrical knowledge is required to make the LED glow. Look at the picture below.


  ![](<%= images_host %>images/resistor.jpg)

  When there is a potential difference (V) of 3 volts across a 10 kiloohm (= 10000 ohm) resistance (R), the current (I) flowing is 0.3 milliamps.
  This can be calculated from `I = V / R` which is obtained by transforming the basic equation `V = I * R` of Ohm's law.

  Next, let's look at part of the LED data sheet.
  Vf is the potential difference generated at both ends of the LED. Here, Vf uses a 2.1V red LED.

  ![](<%= images_host %>images/led_datasheet.png)

  Source: http://akizukidenshi.com/download/ds/optosupply/OSXXXX3Z74A_VER_A1.pdf_

  Connect this LED and a 330Ω resistor in series, and apply 3.3V across the circuit.

  ![](<%= images_host %>images/led_circuit.png)

  Since the LED always produces a potential difference of 2.1 V (I think you can see that we have omitted the detailed discussion), the resistor is charged with a voltage of 1.2 V.
  According to Ohm's law (3.3-2.1) / 330 = 0.0036, the current is 3.6 mA.

  ### Wire to the breadboard

  Connect the ESP32 development board with resistors, LEDs and jumpers with a breadboard.
  Since LEDs generally have the long pin as the anode, connect the long pin to a positive potential.

  In the schematic above, the anode is pin 2 and the cathode is pin 1.
  In the case of this circuit, it will not be broken even if you make a mistake and insert it in reverse.

  ![](<%= images_host %>images/LED.png)

  In the case of this breadboard diagram, insert the anode on the right and the cathode on the left.

  ![](<%= images_host %>images/blinking_led_breadboard.png)

  The upper wiring diagram and the lower photo represent the same connection.

  ![](<%= images_host %>images/photo_led_blinking.jpg)

  3.3V is applied to ESP32's "IO19" pin.
  The power supply voltage supplied from the USB cable is 5V.
  The buck circuit in the development board is bucked to 3.3 V which is the standard operating voltage of ESP32.

  ### Write a program

  The template is cloned in the same way as the previous hands-on.

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

  ### Build, Run

  You can run it with the familiar `make flash monitor` (and don't forget to set the serial port on the menuconfig screen).

  Hopefully, it will light up for 1 second and turn off for 1 second.

EOF


mac = String.new
wsl = String.new
msys2 = String.new

title = ERB.new("# Setup environment for ESP32 + mruby/c development - <%= platform %>\n\n")

cruby_version = "2.6.2"

images_host = "https://raw.githubusercontent.com/hasumikin/IoT_workshop/master/"

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

File.open("en/doc_1_introduction.md", "w") do |f|
  f.puts introduction.result(binding)
end

%w(mac wsl msys2).each_with_index do |platform, index|
  File.open("en/doc_#{index + 2}_#{platform}.md", "w") do |f|
    f.puts(eval(platform))
  end
end

platform = "WSL"
File.open("en/doc_5_hello_world_posix.md", "w") do |f|
  f.puts "# hands-on - 1\n\n"
  f.puts hello_world_posix.result(binding)
end

File.open("en/doc_6_hello_world_esp.md", "w") do |f|
  f.puts "# hands-on - 2\n\n"
  f.puts hello_world_esp.result(binding)
  f.puts win_usb_confirm.result(binding)
  f.puts mac_usb_confirm.result(binding)
  f.puts hello_world_esp_run.result(binding)
end

%w(led_blinking taking_temperature multi_task).each_with_index do |handson, index|
  File.open("en/doc_#{index + 7}_#{handson}.md", "w") do |f|
    f.puts "# hands-on - #{index + 3}\n\n"
    f.puts eval(handson).result(binding)
  end
end

