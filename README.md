# Docker Image For Laravel

## 构建你自己的laravel镜像

将 docker 文件夹 和 Dockerfile 放于你的laravel框架根目录，并进行构建。

`entrypoint.sh` 可以配置一些个性化的启动命令。

### Docker image

```shellscript
docker build -t your_image_name:latest .
```

