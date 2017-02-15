# datadog.docker.sh
{%- if secrets is defined and secrets.DATADOG_API_KEY is defined %}
sh -c "sed 's/api_key:.*/api_key: $DATADOG_API_KEY/' /etc/dd-agent/datadog.conf.example > /etc/dd-agent/datadog.conf"
{%- else %}
sh -c "sed 's/api_key:.*/api_key: {{DATADOG_API_KEY}}/' /etc/dd-agent/datadog.conf.example > /etc/dd-agent/datadog.conf"
{%- endif %}
# Note 'bind_host: 0.0.0.0' will break the built in JMX collector on the host, but it is required for sending metrics directly from Docker containers to the dd-agent
echo 'bind_host: 0.0.0.0' >> /etc/dd-agent/datadog.conf
service datadog-agent restart
