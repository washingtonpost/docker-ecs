# environment.sh
# Secrets
{%- if secrets is defined %}
AWS_REGION="{{ AWS_REGION }}"
{%- for key, val in secrets.iteritems() %}
{{ key }}=$(aws kms decrypt --region $AWS_REGION --ciphertext-blob fileb://<(echo '{{ val }}' | base64 -d) --output text | cut -f 2 -d $'\t' | base64 -d)
{%- endfor %}
{%- endif %}

# Environment
{%- if environment is defined %}
{%- for key, val in environment.iteritems() %}
{{ key }}={{ val }}
{%- endfor %}
{%- endif %}