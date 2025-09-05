# k8s/trae-agent-chart/templates/_helpers.tpl
{{- define "trae-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "trae-agent.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "trae-agent.labels" -}}
helm.sh/chart: {{ include "trae-agent.chart" . }}
{{ include "trae-agent.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "trae-agent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "trae-agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}
