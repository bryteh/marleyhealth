FROM frappe/erpnext:v14

USER root

WORKDIR /home/frappe/frappe-bench

ENV YARN_IGNORE_ENGINES=true
ENV npm_config_engine_strict=false
ENV PYTHONUNBUFFERED=1

RUN yarn config set ignore-engines true

# Prepare sites folder only.
# Runtime CMD will overwrite common_site_config.json using Coolify env variables.
RUN mkdir -p sites && \
    chown -R frappe:frappe sites

# Replace existing healthcare app with your forked GitHub repo content
RUN rm -rf apps/healthcare

COPY --chown=frappe:frappe . apps/healthcare

USER frappe

RUN yarn config set ignore-engines true

# Install your forked healthcare app into the Python environment
RUN /home/frappe/frappe-bench/env/bin/pip install -e apps/healthcare

# Install frontend dependencies only. Do not run bench build here.
RUN cd apps/healthcare && yarn install --check-files || true

RUN if [ -d "apps/healthcare/patient_portal" ]; then \
      cd apps/healthcare/patient_portal && yarn install --check-files || true; \
    fi

# IMPORTANT:
# Do not run bench build here because your fork currently fails asset build.
# RUN bench build --app healthcare

EXPOSE 8000

CMD ["bash", "-lc", "cd /home/frappe/frappe-bench && python - <<'PY'\nimport os, json\nconf = {\n  'db_host': os.environ.get('DB_HOST'),\n  'db_port': int(os.environ.get('DB_PORT', '3306')),\n  'redis_cache': os.environ.get('REDIS_CACHE'),\n  'redis_queue': os.environ.get('REDIS_QUEUE'),\n  'redis_socketio': os.environ.get('REDIS_SOCKETIO'),\n  'socketio_port': 9000,\n  'webserver_port': 8000\n}\nconf = {k:v for k,v in conf.items() if v is not None}\nos.makedirs('sites', exist_ok=True)\nwith open('sites/common_site_config.json', 'w') as f:\n    json.dump(conf, f)\nPY\nbench serve --host 0.0.0.0 --port 8000 --noreload"]
