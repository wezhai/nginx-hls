#### 使用说明
启动容器后，将mp4格式文件放入./media目录下，会自动切片，前提是已设置环境变量```CONVERT_TOOL=True```，你可以在启动容器时传入这个参数。
例如: 将demo.mp4文件放入./media目录下, 切片后的文件会保存在./media/hls/demo目录下，你可以通过```http://localhost/hls/demo/demo.m3u8```访问它。
#### 本镜像基于以下镜像构建
    docker.io/centos:7.6.1810

#### 使用以下命令构建一个Image
    docker build -t="nginx:hls" .

#### 使用以下命令运行容器
    docker run --name nginx-rtmp -d -p 1935:1935 -p 80:80 nginx:hls

#### 将当前目录下的nginx.conf和媒体目录挂载到容器内
    docker run --name nginx-hls \
        -d -p 1935:1935 -p 80:80 --restart=always \
        -v /usr/share/zoneinfo/Asia/Shanghai:/etc/localtime \
        -v ${PWD}/nginx.conf:/usr/local/nginx/conf/nginx.conf \
        -v ${PWD}/media:/opt/media \
        -v ${PWD}/hls:/opt/hls \
        -v ${PWD}/live:/opt/live \
        -v ${PWD}/demo:/usr/local/nginx/html/demo \
        nginx:hls
#### 示例(自动将.mp4格式文件转换为.m3u8)
将```demo.mp4```文件拷贝到```media```目录
```cp demo.mp4 ${PWD}/media```

#### 访问转换后的视频
通过以下路径访问转换后的视频```http://localhost/hls/demo/demo.m3u8```
