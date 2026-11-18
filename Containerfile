# 1. usar uma imagem base leve de um servidor web (Nginx)
FROM nginx:alpine
COPY index.html styles.css /usr/share/nginx/html/
EXPOSE 80