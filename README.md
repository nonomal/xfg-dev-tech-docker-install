# Docker 环境配置 + 软件（一键安装）v3.0

作者：小傅哥
<br/>博客：[https://bugstack.cn](https://bugstack.cn)

> 沉淀、分享、成长，让自己和他人都能有所收获！😄

大家好，我是技术UP主小傅哥。

说实话，做项目不上线，等于吃面不配蒜🧄，效果少一半！面试官也说：“所有做Java编程项目，没有上线云服务器的，一律当玩具看！” 是呀，做完项目不上线，是不你做的项目没法运行，是个小卡拉米练手的？🤔 那怎么办？

其实，上线云服务器非常非常简单，而且云服务器价格也非常非常便宜！干嘛不上车！

<div align="center">
    <img src="https://bugstack.cn/images/system/zsxq/xingqiu-231018-00.png" width="200px">
</div>

**啥是云服务器？**

云服务器，就等同于自己的另外一个电脑💻，在另外一台电脑部署 redis、mysql、mq等，本地电脑连接过去使用。尤其是 Windows 电脑用户，真心建议搞个云服务器，否则你会浪费非常多的时间这套 Windows 适配问题。

<div align="center">
    <img src="https://bugstack.cn/images/roadmap/tutorial/road-map-docker-install-06.png" width="650px">
</div>

这样有了云服务器，就可以不用嚯嚯本地电脑了，安装了卸，卸了安装，把自己本机电脑环境弄的乱码起糟，全是费时费力的事。有这精力，不如用一台云服务器部署环境，开发完成项目后，再上线云服务器。既节省本地电脑资源，又锻炼了云服务器操作，起步一举两得！

<div align="center">
    <img src="https://bugstack.cn/images/roadmap/tutorial/road-map-docker-idea-00.png" width="150px">
</div>

不过，放心！别担心你不会用云服务器，因为小傅哥已经给你准备了一件安装云服务器环境的脚本，和各类部署环境和构建项目的视频。**即使是小卡拉米，也能跟着学习下来。**

> 🧧小傅哥还提供了非常多的编程实战项目，包括；业务的、组件的、AI的、源码的、轮子的，可以关注公众号「bugstack虫洞栈」回复「星球」加入。

## 🌱 目录

- 一、优惠云服务器地址
- 二、一键部署脚本
   1. 脚本权限设置
   2. JDK 安装脚本
   3. Docker 安装脚本
   4. 软件安装脚本
   5. 常见问题
   6. 执行顺序建议

## 一、优惠云服务器地址

- 购买地址：[https://618.gaga.plus](https://618.gaga.plus)
- 购买地址：[https://618.gaga.plus](https://618.gaga.plus)
- 购买地址：[https://618.gaga.plus](https://618.gaga.plus)

**我适合买哪个服务器？**

- 2c4g 1年+送3个月（腾讯云），可部署一套 docker、mysql、redis、rabbitmq、xxl-job、SpringBoot 分布式微服务项目。 
- 2c4g 3年，528￥，适合部署小傅哥星球社群[大部分项目](https://bugstack.cn/md/zsxq/material/student-learn-advanced.html)，可以完成多个微服务项目部署。
- 温馨提示，2c2g 基本不够做什么用的，4c4g 大部分都是共用资源，可能有卡顿，跑不到4c4g。

注意📢：购买选择系统时，推荐系统镜像，**Ubuntu 24+**、**centos 7.9** SSH 链接工具：[SSH Tool](https://bugstack.cn/md/road-map/tool.html)

>如果自己账号不是新人身份，可以自己注册个新账号，用家里人扫码认证一下即可。

## 二、一键部署脚本

小傅哥，这里为你准备一键安装 Docker 环境的脚本文件，你可以非常省心的完成 Docker 部署。使用方式如下。

<div align="center">
    <img src="https://bugstack.cn/images/roadmap/tutorial/road-map-docker-install-02.png" width="650px">
</div>

- **地址**：<https://github.com/fuzhengwei/xfg-dev-tech-docker-install>
- **地址**：<https://gitcode.com/Yao__Shun__Yu/xfg-dev-tech-docker-install>

本文档介绍如何执行项目中的各个脚本，包括权限设置和执行步骤。操作视频：[https://www.bilibili.com/video/BV1oaNazEEf5](https://www.bilibili.com/video/BV1oaNazEEf5)

📢 如果执行过程中没有权限，可以在命令前加一个 `sudo` 如 `sudo yum install git`

## 1. 安装Git

**Centos**

```java
# sudo yum install git
```

**Ubuntu**

```java
# sudo apt update
# sudo apt install nodejs npm
# node -v
# npm -v
# apt-get install git
```

### 2. 下载安装脚本（github\gitcode）

**注意**

```java
cd /
mkdir dev-ops
cd dev-ops
```

之后在执行 git clone 操作，不要在 ~ 目录下，会有 root 权限。

```java
$ git clone https://gitcode.com/Yao__Shun__Yu/xfg-dev-tech-docker-install.git
$ git clone https://github.com/fuzhengwei/xfg-dev-tech-docker-install.git
```
### 3. 为所有脚本添加可执行权限

```java
$ find . -name "*.sh" -type f -exec chmod +x {} \;
```

### 4. 安装 Docker (会自动选择对应系统)

```java
$ ./run_install_docker.sh # 支持 Ubuntu/CentOS
```

docker 常用命令；

- docker --version          # 查看Docker版本
- docker ps                 # 查看运行中的容器
- docker images             # 查看本地镜像
- docker pull hello-world   # 拉取测试镜像
- docker run hello-world    # 运行测试容器
- docker rm nginx           # 删除服务
- docker rmi nginx          # 删除镜像
- docker exec -it nginx /bin/bash # 进入服务

### 5. 安装开发软件 (MySQL, Redis, Nacos 等)

```java
$ ./run_install_software.sh
```

### 6. 安装 JDK (可选，支持 8/17) - 查看帮助文档，Ubuntu 使用 apt 命令安装

```java
$ ./environment/jdk/install-java.sh -v 8
```

### 7. 安装 Maven - 查看帮助文档，Ubuntu 使用 apt 命令安装

```java
$ ./environment/maven/install-maven.sh
```

### 8. 安装 Terminal AI 工具(安装时候，推荐使用 opencode)

```java
./terminal.sh
```

- https://github.com/sst/opencode
- https://github.com/BurntSushi/ripgrep/releases/

>terminal.sh 脚本安装，已将 opencode、ripgrep 所需内容做好了镜像。让你可以便捷安装。

---

关于如何使用 Docker 部署项目教程；[https://bugstack.cn/md/road-map/docker-deploy-project.html](https://bugstack.cn/md/road-map/docker-deploy-project.html)