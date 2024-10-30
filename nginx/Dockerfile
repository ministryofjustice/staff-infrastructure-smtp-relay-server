FROM nginx:1.27.2-alpine

# Upgrade the OS and update all packages, including NGINX dependencies
RUN apk update && \
    apk upgrade --no-cache && \
    apk add --no-cache bash

CMD ["nginx", "-g", "daemon off;"]
