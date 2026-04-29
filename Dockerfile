FROM frappe/erpnext:v14

USER frappe
WORKDIR /home/frappe/frappe-bench

# Tell yarn to ignore the strict Node version requirement
RUN yarn config set ignore-engines true

# Download and inject the Marley EMR interface into your server
RUN bench get-app https://github.com/earthians/marley.git

# Recompile the frontend web assets so the new UI loads properly
RUN bench build --app marley
