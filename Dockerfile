# Build stage: export the web build with headless Godot (no Godot needed on the host).
FROM ubuntu:24.04 AS builder
RUN apt-get update && apt-get install -y --no-install-recommends curl unzip ca-certificates file \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /game
COPY . .
RUN chmod +x scripts/build_web.sh && GODOT_VERSION=4.3 scripts/build_web.sh

# Runtime stage: tiny static server with gzip (wasm shrinks ~35MB -> ~10MB over the wire).
FROM nginx:1.27-alpine
COPY --from=builder /game/build/web /usr/share/nginx/html
RUN printf 'server {\n\
    listen 80;\n\
    server_name _;\n\
    root /usr/share/nginx/html;\n\
    gzip on;\n\
    gzip_comp_level 6;\n\
    gzip_types application/wasm application/javascript application/octet-stream text/html;\n\
    gzip_min_length 1024;\n\
    location / {\n\
        add_header Cache-Control "no-cache";\n\
        try_files $uri $uri/ =404;\n\
    }\n\
    location ~* \\.wasm$ {\n\
        add_header Cache-Control "public, max-age=604800";\n\
        types { application/wasm wasm; }\n\
    }\n\
}\n' > /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
