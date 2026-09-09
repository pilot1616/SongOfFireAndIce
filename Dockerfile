FROM ubuntu:24.04 AS builder
RUN apt-get update && apt-get install -y --no-install-recommends curl unzip ca-certificates python3 && rm -rf /var/lib/apt/lists/*
WORKDIR /game
COPY . .
RUN chmod +x scripts/build_web.sh run_web.sh && GODOT_VERSION=4.3 scripts/build_web.sh

FROM python:3.12-alpine
WORKDIR /srv
COPY --from=builder /game/build/web ./web
EXPOSE 8080
CMD ["python3", "-m", "http.server", "8080", "--bind", "0.0.0.0", "--directory", "/srv/web"]
