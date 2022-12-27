# docker-ros

SIGVerse用のVNC接続可能なUbuntuデスクトップDockerコンテナを使用するためのリポジトリです。  
デスクトップはLXDEという軽量なものです。

次のイメージをベースにしています。  
https://github.com/Tiryoh/docker-ros-desktop-vnc

Windowsでイメージのビルドを行う例を以降に示します。

## DockerfileからDockerイメージを作成する

**この作業はSIGVerse管理者用が行う作業であり、ユーザが実行する必要はありません。**

1. Docker Desktopをインストールします。  
https://www.docker.com/products/docker-desktop/
1. Windows PowerShell を起動します。（以降のコマンドはWindows PowerShell で実行します）
1. バージョン確認コマンドを実行してDockerコマンドが動くことを確認してください。  
`> docker --version`
1. docker loginコマンドで稲邑研のDocker Hubアカウントにログインします。（ID/Passwordは別途確認してください）  
`> docker login`
1. 本リポジトリをダウンロードし、ローカルに解凍します。
1. 本リポジトリのDockerfileが存在するディレクトリに移動します。
1. Dockerイメージをビルドします。  
`> docker build . -t inamuralab/sigverse-ros-noetic`
1. DockerイメージをDocker Hubに送信します。  
`>  docker push inamuralab/sigverse-ros-noetic`

## DockerイメージからDockerコンテナを起動する（初回起動）

1. Docker Desktopをインストールします（未インストールの場合）  
https://www.docker.com/products/docker-desktop/
1. Docker Desktopを起動して正常に起動することを確認してください。
1. Windows PowerShell を起動します。（以降のコマンドはWindows PowerShell で実行します）
1. Dockerイメージをダウンロードし、Dockerコンテナを作成・起動します。  
解像度オプション（-e RESOLUTION=1920x1080）を付ければ解像度を変更可能です。  
`> docker run -p 6080:80 -p 5900:5900 -p 9090:9090 -p 50001:50001 inamuralab/sigverse-ros-noetic`
1. 起動完了するまで待ちます。以下のような状態であれば起動完了しています。
![create-container](images/create-container.png "Create Container")  
Docker DesktopのImagesには以下のようなImageが追加されています。  
![docker-desktop-images](images/docker-desktop-images.png "Docker Desktop Images")  
Docker DesktopのContainersには以下のようなコンテナが起動します。コンテナ名は適当に決定されます。  
![docker-desktop-containers](images/docker-desktop-containers.png "Docker Desktop Containers")  
1. ブラウザを起動し、以下にアクセスします。  
http://127.0.0.1:6080/  
またTigerVNCなどのVNCクライアントを使用してアクセスすることも可能です。その場合ポート番号は5900です。
1. 以下のようなLXDEのUbuntuデスクトップ画面が表示されます。  
画面左側にはVNCツールがありVNCに関わる機能が使用可能です。  
![vnc-desktop](images/vnc-desktop.png "VNC Window")  

## Dockerコンテナを使用する

+ デスクトップに sigverse_commands.txt が置いてあり、参考となるROSコマンドが書かれています。
+ 画面左側のVNCツールで Clipboard が使用可能です。
+ 画面左側のVNCツールの設定で、Scaling Modeを"Local Scaling"にするとブラウザサイズに合わせて画面が伸縮します。

## Dockerコンテナを停止する
1. 画面左側のVNCツールで Disconnect をクリックして切断します。
1. Docker Desktopのコンテナ一覧から当該コンテナを停止します。

## Dockerコンテナの起動（２回目以降）

既にコンテナが存在しているのでDocker Desktopのコンテナ一覧から起動できます。  
Windows PowerShell は使用しません。

## 補足

### GPUを使用する方法

SIGVerseにはYOLOを使用した物体認識のチュートリアルがありますが、DockerでGPUを使用できることも確認しています。

##### 前提条件
GPUを使用するには条件があると思われます。当方で確認できた一例を示します。以下が最小構成という訳ではありません（2022年12月現在）
+ Windows 10 Pro 22H2
+ Docker Desktop 4.15.0
+ GeForce RTX 3070 laptop
+ GeForce Game Ready Driver 527.56
+ CUDA Toolkit 12.0.0_525.60.13

##### 手順（一例）
1. 解像度とgpusオプションを付けてコンテナを作成します。  
docker run --gpus all -p 6080:80 -p 5900:5900 -p 9090:9090 -p 50001:50001 -e RESOLUTION=1920x1080 inamuralab/sigverse-ros-noetic
1. Dockerコンテナ内で Ubuntu20.04用の CUDA Toolkit をインストールします。
1. darknet_ros/darknet/Makefile を修正して、GPUとCUDNNのフラグを立てます。（GPU=1、CUDNN=1）
1. darknet_ros/darknet_ros/CMakeLists.txt を修正して、compute_30 と compute_35 の行をコメントアウトします。
1. catkin_makeします。

### Dockerイメージのファイル保存

Windows PowerShellでコマンドを実行します。

##### ファイル保存

`> docker save inamuralab/sigverse-ros-noetic:latest -o docker-image-sigverse-noetic.tar`

##### ファイル読み込み
`> docker load -i docker-image-sigverse-noetic.tar`
