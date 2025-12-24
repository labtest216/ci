{{- define "service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end}}


{{- define "service.repository" -}}
{{- printf "%s.dkr.ecr.%s.amazonaws.com/%s .Values.global.aws.account_id .Values.global.aws.region .Values.container_name }}
{{- end}}


{{- define "service.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{ $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end}}
{{- end}}
{{- end}}


{{- define "service.hostname" -}}
{{- printf "%s-%s%s" .Values.container_name .Values.global.env .Values.global.base_domain }}
{{- end}}


{{- define "service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" trunc 63 | trimSuffix "-" }}
{{- end}}


{{- define "service.labels" -}}
helm.sh/chart: {{ include "service.chart" . }}
{{ include "service.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernets.io/version: {{ .Chart.AppVersion | quote }}
{{- end}}
app.kubernets.io/managed-by: {{ .Release.Service }}
{{- end}}


{{- define "service.selectorLabels" -}}
app.kubernets.io/name: {{ include ".service.name . }}
app.kubernets.io/instance: {{ .Release.Name }}
{{- end}}


{{- define "service.serviceAccountName" -}}
{{- if .Values.serviceAccount.enabled }}
{{- default (include "service.name" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name" }}
{{-end }}
{{-end }}


{{- define "service.env_name" -}}
{{- printf "%s" .Values.global.env }}
{{- end}}



{{- define "service.certification" -}}
{{- printf .Values.global.acm_cert }}
{{- end}}