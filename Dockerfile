FROM frappe/erpnext:v14

# Switch to the frappe user to ensure file permissions stay secure
USER frappe
WORKDIR /home/frappe/frappe-bench

# Download and inject the Marley EMR interface into your server
RUN bench get-app https://github.com/earthians/marley.git

# Recompile the frontend web assets so the new UI loads properly
RUN bench build --app marley
