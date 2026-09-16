FROM nginx:1.31-alpine

COPY index.html /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD wget -q0 http://localhost:80/ > /dev/null || exit 1 

CMD ["nginx", "-g", "daemon off;"]