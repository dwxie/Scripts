# mac安装git及git图形化工具sourcetree


本文介绍如何在mac系统安装和配置git以及git图形化工具sourcetree。

## 安装git

---

系统偏好设置-安全与隐私中，允许任何来源安装。

![此处输入图片的描述][1]

点击下载[git][2]安装包。

双击下载的dmg文件，再双击pkg，弹出安装窗口，一路默认安装。

![此处输入图片的描述][3]


## 生成ssh key

---

打开终端，运行ssh-keygen命令生成ssh密钥，-C后面填写aigongzuo邮箱。

``` 
ssh-keygen -C 'username@aigongzuo.com'
```

一路回车，各种提示按默认不要改，等待执行完毕。

```
Generating public/private rsa key pair.
Enter file in which to save the key (/Users/ks/.ssh/id_rsa): 
Created directory '/Users/ks/.ssh'.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /Users/ks/.ssh/id_rsa.
Your public key has been saved in /Users/ks/.ssh/id_rsa.pub.
The key fingerprint is:
SHA256:SmMl+p+cEZMve4Q9ZKaFHSVHMScZkkv+LR6OL9jWq7g username@aigongzuo.com
The key's randomart image is:
+---[RSA 2048]----+
|          o+O+.  |
|          ++.+   |
|      . .= o     |
|     . o..O      |
|    . + SO . .   |
|     + oo++ + .  |
|      o o+.* o   |
|       o.B* +    |
|        E+.+o.   |
+----[SHA256]-----+
```

第7行输出显示public key已经保存到了/Users/ks/.ssh/id_rsa.pub。使用cat命令查看此文件：

```
ksdeMac:~ ks$ cat /Users/ks/.ssh/id_rsa.pub
```

将文件内容复制到剪贴板。

```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDZkLNrHohT5A/9KkFObkONetq4QOjnbGHfepFmOHtwMXrvbhV2jQ9q2NRJxe/otb0CjaRMShmoALTgTgqcZo2ClDkPNer1fiEpeMHY5qUlSPAZB5bg8uvkyCrDwucse4N7vL4rQ1SMqK4DwzJSVVuYM+ZXmfuQj8mzRAUf3VOz8hjk1sDtBYCnQw7yFZ2uog+LY1yuseXzNPHuUac3QIy1rLmsfCVPrPFn1kjitGR9fhTIBcz3QcmLjpg944oUGpq5ZGO78jH8UDC7f651x7qBH1rRhgWeh1a8keo2JaKsb/LAa+5DgGBYPkYIDOcTYvTHrpx/hnaeUtVQjgRRfsCf username@aigongzuo.com
``` 

## 注册gitlab并配置ssh key信任

---

配置ssh key以后，在每次向远程仓库push时免去输入用户名密码。

访问[gitlab][4]，申请账号。
- name：真实姓名
- username: aigongzuo邮箱的用户名部分
- Email: aigongzuo邮箱

![gitlab帐号注册][5]

登录以后点击Profile Settings

![登录后进入profile][6]

点击SSH Keys，讲刚才生成的ssh key复制到Key文本框中，Title使用默认值。

![添加ssh key][7]

## 安装sourcetree

---

下载[sourcetree][8]安装包，双击安装。

![sourcetree安装][9]

sourcetree需要使用google或者Atlaasian的帐号登录。如没有，点击`转到我的Atlassian`注册帐号（可能需要翻墙）。

![sourcetree帐号注册][10]

注册后点击`使用已有账户`登录。登录完成后点击`转到我的Atlassian`。

![登录后跳转][11]

点击`跳过设置`

![跳过设置][12]

点击`+新仓库`配置远程库，选择`从URL克隆`。

![添加新仓库][13]

源URL中填入git仓库的地址，点击`克隆`。

![源URL克隆][14]

可以看到文件已经下载到了本地。

![此处输入图片的描述][15]


  [1]: http://ww1.sinaimg.cn/mw690/67a64e8cgw1f8bmwenr04j20il0f6q4p.jpg
  [2]: ftp://ftp.demo.com/%E5%85%B1%E4%BA%AB%E4%B8%AD%E5%BF%83/%E5%BC%80%E5%8F%91%E5%B7%A5%E5%85%B7/%E9%A1%B9%E7%9B%AE%E7%AE%A1%E7%90%86/Git/git-1.9.2-intel-universal-snow-leopard.dmg
  [3]: http://ww4.sinaimg.cn/mw690/67a64e8cgw1f8bmzmmhwuj20m70hidi9.jpg
  [4]: http://192.168.1.173
  [5]: http://ww3.sinaimg.cn/mw690/67a64e8cgw1f8afvhnlqrj20q70g1n1w.jpg
  [6]: http://ww2.sinaimg.cn/mw690/67a64e8cgw1f8bm9ygmgqj20w60eljv4.jpg
  [7]: http://ww4.sinaimg.cn/mw690/67a64e8cgw1f8bm9ywlb8j210r0fwn1v.jpg
  [8]: ftp://ftp.demo.com/%E5%85%B1%E4%BA%AB%E4%B8%AD%E5%BF%83/%E5%BC%80%E5%8F%91%E5%B7%A5%E5%85%B7/%E9%A1%B9%E7%9B%AE%E7%AE%A1%E7%90%86/Git/SourceTree_2.3.1.zip
  [9]: http://ww4.sinaimg.cn/mw690/67a64e8cgw1f8bna9isa0j20k90fhgp9.jpg
  [10]: http://ww3.sinaimg.cn/mw690/67a64e8cgw1f8bnda0t7yj20jy0brdhc.jpg
  [11]: http://ww4.sinaimg.cn/mw690/67a64e8cgw1f8bntjn8dvj20jy0bt0u8.jpg
  [12]: http://ww2.sinaimg.cn/mw690/67a64e8cgw1f8bnvyaehgj20k20brgnc.jpg
  [13]: http://ww4.sinaimg.cn/mw690/67a64e8cgw1f8bo0qbb7ij20de07l3z8.jpg
  [14]: http://ww3.sinaimg.cn/mw690/67a64e8cgw1f8bo55qzqfj20ef073aaz.jpg
  [15]: http://ww1.sinaimg.cn/mw690/67a64e8cgw1f8bo8ferdzj20q707vtc1.jpg