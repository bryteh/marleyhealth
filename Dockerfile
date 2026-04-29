FROM frappe/erpnext:v14

USER frappe
WORKDIR /home/frappe/frappe-bench

# 1. Bypass the Node.js version block for the frontend compiler
RUN yarn config set ignore-engines true

# 2. Create a dummy config file to satisfy the compiler's Redis check during build
RUN mkdir -p sites && \
    echo '{"redis_cache": "redis://redis", "redis_queue": "redis://redis", "redis_socketio": "redis://redis"}' > sites/common_site_config.json

# 3. Download Marley and automatically install its required dependencies (Healthcare module)
RUN bench get-app --resolve-deps https://github.com/earthians/marley.git

# 4. Force compile the frontend web assets
RUN bench build --app marley
