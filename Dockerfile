# 使用官方 Python 3.10-slim 作为基础镜像
FROM python:3.10-slim as base

# 设置环境变量
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    TZ=Asia/Shanghai

# 安装系统依赖和 Python 环境依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 复制依赖文件
COPY requirements.txt .

# 安装 Python 依赖和 Playwright（多阶段减少临时文件）
RUN pip install --no-cache-dir -r requirements.txt -i https://mirrors.aliyun.com/pypi/simple/ \
    && playwright install chromium \
    && playwright install-deps \
    && apt-get remove -y tzdata && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# 复制应用文件
COPY . .

# 启动主程序
CMD ["python", "schedule_main.py"]
