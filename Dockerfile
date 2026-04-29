FROM frappe/erpnext:v14

USER frappe
WORKDIR /home/frappe/frappe-bench

# 1. Bypass the Node.js version block for the frontend compiler
RUN yarn config set ignore-engines true

# 2. Inject the correct Redis URL formats into the build environment so the engine doesn't crash
ENV REDIS_CACHE="redis://redis-cache:6379"
ENV REDIS_QUEUE="redis://redis-queue:6379"
ENV REDIS_SOCKETIO="redis://redis-socketio:6379"

# 3. Download Marley and automatically install its required dependencies (like the Healthcare module)
RUN bench get-app --resolve-deps https://github.com/earthians/marley.git

# 4. Force compile the frontend web assets
RUN bench build --app marley
