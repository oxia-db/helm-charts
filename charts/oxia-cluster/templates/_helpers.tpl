# Copyright 2023 StreamNative, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

{{/*
Coordinator labels
*/}}
{{- define "oxia-cluster.coordinator.labels" -}}
{{ include "oxia-cluster.coordinator.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/part-of: oxia
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Coordinator selector labels
*/}}
{{- define "oxia-cluster.coordinator.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/component: coordinator
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Server labels
*/}}
{{- define "oxia-cluster.server.labels" -}}
{{ include "oxia-cluster.server.selectorLabels" . }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Server selector labels
*/}}
{{- define "oxia-cluster.server.selectorLabels" -}}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/component: server
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Extract port number from bind address (e.g., "0.0.0.0:6648" -> "6648")
*/}}
{{- define "oxia-cluster.port" -}}
{{- (splitList ":" .) | last -}}
{{- end -}}

{{/*
Default public bootstrap authority advertised to clients
*/}}
{{- define "oxia-cluster.bootstrapAuthority" -}}
{{- printf "%s.%s.svc.cluster.local:%s" .Release.Name .Release.Namespace (include "oxia-cluster.port" .Values.server.config.server.public.bindAddress) -}}
{{- end -}}

{{/*
Oxia TLS options (common/security/tls.go) for the certificate Secret mounted
at /etc/oxia/tls. Takes a dict: "ca" trusts ca.crt, "clientAuth" requires
client certificates.
*/}}
{{- define "oxia-cluster.tlsOptions" -}}
enabled: true
certFile: /etc/oxia/tls/tls.crt
keyFile: /etc/oxia/tls/tls.key
{{- if .ca }}
trustedCaFile: /etc/oxia/tls/ca.crt
{{- end }}
{{- if .clientAuth }}
clientAuth: true
{{- end }}
{{- end }}

{{/*
Data server config: server.config with the settings from .Values.tls merged
in. Keys set explicitly in server.config take precedence.
*/}}
{{- define "oxia-cluster.server.config" -}}
{{- $config := deepCopy .Values.server.config -}}
{{- with .Values.tls.public }}
{{- if .enabled }}
{{- $_ := required "tls.secretName must be set when tls.public.enabled is true" $.Values.tls.secretName }}
{{- $tls := include "oxia-cluster.tlsOptions" (dict "ca" .clientAuth "clientAuth" .clientAuth) | fromYaml }}
{{- $_ := merge $config.server.public (dict "tls" $tls) }}
{{- end }}
{{- end }}
{{- with .Values.tls.internal }}
{{- if .enabled }}
{{- $_ := required "tls.secretName must be set when tls.internal.enabled is true" $.Values.tls.secretName }}
{{- $serverTls := include "oxia-cluster.tlsOptions" (dict "ca" true "clientAuth" .clientAuth) | fromYaml }}
{{- $_ := merge $config.server.internal (dict "tls" $serverTls) }}
{{- /* Leaders replicate to the followers' internal endpoint */}}
{{- $clientTls := include "oxia-cluster.tlsOptions" (dict "ca" true) | fromYaml }}
{{- $_ := set $config "replication" (merge (default (dict) $config.replication) (dict "tls" $clientTls)) }}
{{- end }}
{{- end }}
{{- toYaml $config }}
{{- end }}

{{/*
Coordinator config: coordinator.config with the settings from .Values.tls
merged in. Keys set explicitly in coordinator.config take precedence.
*/}}
{{- define "oxia-cluster.coordinator.config" -}}
{{- $config := deepCopy .Values.coordinator.config -}}
{{- if .Values.tls.internal.enabled }}
{{- /* The coordinator calls the data servers' internal endpoint */}}
{{- $tls := include "oxia-cluster.tlsOptions" (dict "ca" true) | fromYaml }}
{{- $_ := set $config "controller" (merge (default (dict) $config.controller) (dict "tls" $tls)) }}
{{- end }}
{{- toYaml $config }}
{{- end }}

{{/*
Port for the data server probes. "oxia health" only speaks plaintext, so use
the internal endpoint, or the public one when only the internal endpoint has
TLS (both serve the same health service). Empty when both have TLS.
*/}}
{{- define "oxia-cluster.server.probePort" -}}
{{- if not .Values.tls.internal.enabled -}}
{{- include "oxia-cluster.port" .Values.server.config.server.internal.bindAddress -}}
{{- else if not .Values.tls.public.enabled -}}
{{- include "oxia-cluster.port" .Values.server.config.server.public.bindAddress -}}
{{- end -}}
{{- end -}}

{{/*
Probe
*/}}
{{- define "oxia-cluster.probe" -}}
exec:
  command: ["oxia", "health", "--port={{ . }}"]
initialDelaySeconds: 10
timeoutSeconds: 10
{{- end }}


{{/*
Probe
*/}}
{{- define "oxia-cluster.readiness-probe" -}}
exec:
  command: ["oxia", "health", "--port={{ . }}", "--service=oxia-readiness"]
initialDelaySeconds: 10
timeoutSeconds: 10
{{- end }}

{{/*
Probe
*/}}
{{- define "oxia-cluster.startup-probe" -}}
exec:
  command: ["oxia", "health", "--port={{ . }}"]
initialDelaySeconds: 60
timeoutSeconds: 10
{{- end }}
