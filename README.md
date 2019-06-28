### 连麦直播 macOS

#### 准备工作
1. 在三体云官网SDK下载页 [http://3ttech.cn/index.php?menu=53](http://3ttech.cn/index.php?menu=53) 下载macOS平台的连麦直播SDK，放在**TTTRtcEngineKit**目录下。
2. 登录三体云官网 [http://dashboard.3ttech.cn/index/login](http://dashboard.3ttech.cn/index/login) 注册体验账号，进入控制台新建自己的应用并获取APPID。


#### SDK使用

1. 添加系统库：
> 1. libc++.tbd
> 2. libxml2.tbd
> 3. libiconv.2.tbd
> 4. libresolv.tbd
> 5. libz.tbd
> 6. libbz2.tbd
> 7. SystemConfiguration.framework
> 8. VideoDecodeAcceleration.framework

2. 添加ffmpeg库：
> 1. libavcodec.a
> 2. libavdevice.a
> 3. libavfilter.a
> 4. libavformat.a
> 5. libavutil.a
> 6. libswresample.a
> 7. libswscale.a

3. 添加TTTRtcEngineKit.framework
4. 在Framework Search Paths中添加TTTRtcEngineKit的路径 
5. 在Library Search Paths中添加ffmpeg的路径
