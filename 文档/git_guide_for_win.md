# Git使用说明

本文介绍如何在windows系统安装和配置git客户端，以及基本的git使用方法。

## 安装git客户端

所有软件采用默认安装即可！

### 1. 安装git支撑软件

下载软件请点击，[这里](http://git-scm.com/download/)。

安装本软件后，即可通过git bash使用git的全部功能。但是，命令行的方式不太适合普通用户使用，所以可以下载并安装TortoiseGit，将大部分git功能集成进windows右键菜单。

### 2. 安装TortoiseGit

你可以在[这里](http://tortoisegit.org/download/)下载到TortoiseGit的安装程序和汉化包。

## 配置TortoiseGit

### 1. 配置为中文界面

![中文界面][1]

### 2. 配置git客户端软件的路径

![git路径][2]

### 3. 配置git用户名

![git用户][3]

### 4. 配置ssh客户端路径

![ssh路径][4]

### 5. 添加自己的ssh key到GitLab

为了开森、舒畅的工作，你是否想在每次push代码到GitLab服务器时，都省去输入用户名和密码的繁琐步骤！？
OK，木有问题。这时，你只需要生成一个ssh key，并上传到GitLab服务器，即可实现你的愿望！Bingo。。。

* 打开git bash
* 设置git的username和email    
    ```
    $ git config --global user.name "user"
    $ git config --global user.email "user@email.com"
    $ git config --list
    ```
* 生成密钥
    ```
    $ ssh-keygen.exe -t rsa -C "user@email.com"
    Generating public/private rsa key pair.
    Enter file in which to save the key (/c/Users/Administrator/.ssh/id_rsa):
    Enter passphrase (empty for no passphrase):
    Enter same passphrase again:
    Your identification has been saved in /c/Users/Administrator/.ssh/id_rsa.
    Your public key has been saved in /c/Users/Administrator/.ssh/id_rsa.pub.
    The key fingerprint is:
    56:8f:86:35:eb:2b:f3:3b:df:1b:bf:08:d2:d0:09:52 user@email.com
    The key's randomart image is:
    +--[ RSA 2048]----+
    |         E       |
    |        .        |
    |       . .+      |
    |        .+o=.    |
    |        S.+o.    |
    |       . oo      |
    |         ..o  .  |
    |        o o....o |
    |         +++..ooo|
    +-----------------+
    ```
* 复制ssh密钥信息

	上面生成的ssh密钥文件路径为`C:\Users\Administrator\.ssh\id_rsa.pub`，用记事本打开，复制里面的信息。

* 上传ssh key到GitLab上

	使用user@email.com登录GitLab，然后上传刚才生成的ssh key。

	![上传sshkey][6]

	![新建sshkey][7]
[6]:http://ww1.sinaimg.cn/large/eb6d7930gw1ewi2xauy9cj20qo0f9776.jpg
[7]:http://ww3.sinaimg.cn/large/eb6d7930gw1ewi2xgpbe9j20qo0h7dl7.jpg

至此，配置完成。

[1]:http://ww4.sinaimg.cn/large/eb6d7930gw1ewdoy8aj8rj20lh066jt3.jpg
[2]:http://ww4.sinaimg.cn/large/eb6d7930gw1ewdoydwnpgj20lh0asmzk.jpg
[3]:http://ww2.sinaimg.cn/large/eb6d7930gw1ewdoyky0b5j20lh09fjtq.jpg
[4]:http://ww4.sinaimg.cn/large/eb6d7930gw1ewdoyowv78j20lh066jsh.jpg

## 使用git

### 1. 从GitLab克隆远程repository到本地

* 鼠标右键选择`Git克隆`
* 在Git克隆窗口中，输入`URL`和`目录`，然后点击`确定`。
 
	![Git克隆][5]

[5]:http://ww4.sinaimg.cn/large/eb6d7930gw1ewi34wrfbhj20f107ft9q.jpg

### 2. 本地数据仓库的操作

数据仓库clone到本地以后，你可以随意对它进行操作。对于大多数常规的操作，其方法类似svn，这里就不再赘述。如果你要用到的git操作，没有在本文里介绍，还是建议你去问[度娘](http://www.baidu.com)和[谷哥](http://www.google.com.hk)。

唯一需要强调的是，git是一个分布式的版本控制系统，所以当你commit以后，仅仅是在你本地的版本库中提交了更改。如果你要使远程版本库（比如gitlab）中的代码与你本地的代码库同步，还需要进行一个push操作，将你本地的代码push到remote repository。

## 常见问题

### 1. 为何我上传了ssh key到GitLab，但是仍然会提示我输入用户名密码？

GitLab支持两种传输协议，分别是ssh和http。

![上传sshkey][8]

只有当本地repository与远端repository通讯时，使用的是ssh协议时，才能通过ssh密钥的验证，免去输密码的步骤。也就是说，你的远端repository的URL必须是以git开头的形式，如：`git@git.ht.com:hongtoo/notice.git`

[8]:http://ww2.sinaimg.cn/large/eb6d7930gw1ewi3lonxhbj20ie0ahdhd.jpg