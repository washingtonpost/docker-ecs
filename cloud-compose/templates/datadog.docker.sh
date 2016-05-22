{%- if DATADOG_API_KEY is defined %}
# datadog.docker.sh 
sh -c "sed 's/api_key:.*/api_key: {{DATADOG_API_KEY}}/' /etc/dd-agent/datadog.conf.example > /etc/dd-agent/datadog.conf"
service datadog-agent restart
{%- endif %}