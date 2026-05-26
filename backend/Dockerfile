FROM python:3.12-slim

WORKDIR /app

COPY pyproject.toml ./
RUN pip install --no-cache-dir uv && \
    # 先固定 passlib 和 bcrypt 兼容版本，再安装其他依赖
    uv pip install --system "passlib[bcrypt]==1.7.4" "bcrypt==4.3.0" && \
    uv pip install --system .

COPY app ./app

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]