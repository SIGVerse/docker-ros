# docker-ros

SIGVerse用のVNC接続可能なUbuntuデスクトップDockerコンテナを作成するためのリポジトリです。  
デスクトップはLXDEという軽量なものです。

SIGVerse管理者用であり、ユーザが実行する必要はありません。  
次のイメージをベースにしています。  
https://github.com/Tiryoh/docker-ros-desktop-vnc

Windowsでイメージのビルドを行う例を以降に示します。

## DockerfileからDockerイメージを作成する

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

## Dockerイメージからコンテナを起動する（初回起動）

1. Docker Desktopをインストールします（未インストールの場合）  
https://www.docker.com/products/docker-desktop/
1. Docker Desktopを起動して正常に起動することを確認してください。
1. Windows PowerShell を起動します。（以降のコマンドはWindows PowerShell で実行します）
1. Dockerイメージをダウンロードし、Dockerコンテナを作成・起動します。  
`> docker run -p 6080:80 -p 9090:9090 -p 50001:50001 inamuralab/sigverse-ros-noetic`
1. 起動完了するまで待ちます。以下のような状態であれば起動完了しています。
![create-container](images/create-container.png "Create Container")  
Docker DesktopのImagesには以下のようなImageが追加されています。  
![docker-desktop-images](images/docker-desktop-images.png "Docker Desktop Images")  
Docker DesktopのContainersには以下のようなコンテナが起動します。コンテナ名は適当に決定されます。  
![docker-desktop-containers](images/docker-desktop-containers.png "Docker Desktop Containers")  
1. ブラウザを起動し、以下にアクセスします。  
http://127.0.0.1:6080/
1. 以下のようなLXDEのUbuntuデスクトップ画面が表示されます。  
![vnc-desktop1](images/vnc-desktop1.png "上側")  
![vnc-desktop1](images/vnc-desktop2.png "下側")
