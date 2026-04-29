FROM frappe/erpnext:v14

USER root

WORKDIR /home/frappe/frappe-bench

ENV YARN_IGNORE_ENGINES=true
ENV npm_config_engine_strict=false
ENV PYTHONUNBUFFERED=1

# Yarn engine fix
RUN yarn config set ignore-engines true

# Temporary config for build stage
RUN mkdir -p sites && \
    printf '{"db_host":"mariadb","db_port":3306,"redis_cache":"redis://redis:6379","redis_queue":"redis://redis:6379","redis_socketio":"redis://redis:6379","socketio_port":9000,"webserver_port":8000}\n' > sites/common_site_config.json && \
    chown -R frappe:frappe sites

# Replace existing healthcare app folder with your GitHub fork content
RUN rm -rf apps/healthcare

COPY --chown=frappe:frappe . apps/healthcare

USER frappe

RUN yarn config set ignore-engines true

# Install your forked healthcare app
RUN /home/frappe/frappe-bench/env/bin/pip install -e apps/healthcare

# Install frontend dependencies if available
RUN cd apps/healthcare && yarn install --check-files || true

RUN if [ -d "apps/healthcare/patient_portal" ]; then \
      cd apps/healthcare/patient_portal && yarn install --check-files; \
    fi

# Build healthcare assets only
RUN bench build --app healthcare

EXPOSE 8000

# Runtime config is generated from Coolify environment variables
CMD ["bash", "-lc", "cd /home/frappe/frappe-bench && python - <<'PY'\nimport os, json\nconf = {\n  'db_host': os.environ.get('DB_HOST', 'mariadb'),\n  'db_port': int(os.environ.get('DB_PORT', '3306')),\n  'redis_cache': os.environ.get('REDIS_CACHE', 'redis://redis:6379'),\n  'redis_queue': os.environ.get('REDIS_QUEUE', os.environ.get('REDIS_CACHE', 'redis://redis:6379')),\n  'redis_socketio': os.environ.get('REDIS_SOCKETIO', os.environ.get('REDIS_CACHE', 'redis://redis:6379')),\n  'socketio_port': 9000,\n  'webserver_port': 8000\n}\nos.makedirs('sites', exist_ok=True)\nwith open('sites/common_site_config.json', 'w') as f:\n    json.dump(conf, f)\nPY\nbench serve --host 0.0.0.0 --port 8000 --noreload"]
