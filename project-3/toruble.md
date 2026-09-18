global:
scrape_interval: 30s
#external_labels:
#clusterArn: <REPLACE_ME>
scrape_configs:

- job_name: pod_exporter
  kubernetes_sd_configs:
  - role: pod
- job_name: cadvisor
  scheme: https
  authorization:
  type: Bearer
  credentials_file: /var/run/secrets/kubernetes.io/serviceaccount/token
  kubernetes_sd_configs:
  - role: node
    relabel_configs:
  - action: labelmap
    regex: \__meta_kubernetes_node_label_(.+)
  - replacement: kubernetes.default.svc:443
    target_label: **address**
  - source_labels: [__meta_kubernetes_node_name]
    regex: (.+)
    target_label: **metrics_path**
    replacement: /api/v1/nodes/$1/proxy/metrics/cadvisor

# apiserver metrics

- scheme: https
  authorization:
  type: Bearer
  credentials_file: /var/run/secrets/kubernetes.io/serviceaccount/token
  job_name: kubernetes-apiservers
  kubernetes_sd_configs:
  - role: endpoints
    relabel_configs:
  - action: keep
    regex: default;kubernetes;https
    source_labels:
    - \_\_meta_kubernetes_namespace
    - \_\_meta_kubernetes_service_name
    - \_\_meta_kubernetes_endpoint_port_name

# kube proxy metrics

- job_name: kube-proxy
  honor_labels: true
  kubernetes_sd_configs:
  - role: pod
    relabel_configs:
  - action: keep
    source_labels:
    - \_\_meta_kubernetes_namespace
    - \_\_meta_kubernetes_pod_name
      separator: '/'
      regex: 'kube-system/kube-proxy.+'
  - source_labels:
    - **address**
      action: replace
      target_label: **address**
      regex: (.+?)(\:\d+)?
      replacement: $1:10249

# Scheduler metrics

- job_name: 'ksh-metrics'
  kubernetes_sd_configs:
  - role: endpoints
    metrics_path: /apis/metrics.eks.amazonaws.com/v1/ksh/container/metrics
    scheme: https
    bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
    relabel_configs:
  - source_labels:
    - \_\_meta_kubernetes_namespace
    - \_\_meta_kubernetes_service_name
    - \_\_meta_kubernetes_endpoint_port_name
      action: keep
      regex: default;kubernetes;https

# Controller Manager metrics

- job_name: 'kcm-metrics'
  kubernetes_sd_configs:
  - role: endpoints
    metrics_path: /apis/metrics.eks.amazonaws.com/v1/kcm/container/metrics
    scheme: https
    bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
    relabel_configs:
  - source_labels:
    - \_\_meta_kubernetes_namespace
    - \_\_meta_kubernetes_service_name
    - \_\_meta_kubernetes_endpoint_port_name
      action: keep
      regex: default;kubernetes;https

---

http://alb-1639544109.ap-northeast-2.elb.amazonaws.com/article/3/edit

export function readOne(id) {
return () => fetch(`/api/article${id}`).then((res) => res.json());
}
http://alb-1639544109.ap-northeast-2.elb.amazonaws.com/api/article7

Ingress는 문제 없어 보입니다.

```yaml
- path: /
  -> frontend

- path: /api
  -> server
```

이 설정이면 `/article/7/edit`도 **frontend 서비스**로 전달됩니다. 따라서 **Ingress가 아니라 frontend의 nginx가 404를 내는 것**입니다.

## 거의 확실한 원인

지금 Dockerfile은

```dockerfile
FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
```

뿐입니다.

즉, **기본 nginx 설정**을 사용 중입니다. 기본 설정은 SPA(React Router)를 지원하지 않아서

```
GET /article/7/edit
```

를 실제 파일로 찾다가 404를 반환합니다.

---

## 해결 방법

### 1. `nginx.conf` 생성

프로젝트 루트에

```nginx
server {
    listen 80;

    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

를 만드세요.

---

### 2. Dockerfile 수정

```dockerfile
FROM node:18 AS build
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

FROM nginx:alpine

COPY --from=build /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
```

---

### 3. 다시 배포

```bash
docker build -t <이미지> .
docker push <이미지>
kubectl rollout restart deployment frontend
```

---

## 먼저 확인하면 더 빨리 원인을 알 수 있습니다.

frontend Pod 안에서 아래 명령을 실행해 보세요.

```bash
kubectl exec -it <frontend-pod> -- cat /etc/nginx/conf.d/default.conf
```

만약 출력에

```nginx
try_files $uri $uri/ /index.html;
```

가 **없다면**, 지금 설명한 것이 정확한 원인입니다.

**`default.conf`의 내용을 보여주시면 최종 확인해 드리겠습니다.**

SPA는 **Single Page Application(싱글 페이지 애플리케이션)** 입니다.

React, Vue, Angular로 만든 대부분의 웹앱이 SPA입니다.

### 일반 웹사이트(SSR)와 차이

#### 일반 웹사이트

브라우저가

```text
/
```

를 요청하면 서버가 HTML을 보내고,

다시

```text
/article/7/edit
```

를 요청하면 서버가 **`/article/7/edit`에 해당하는 HTML**을 만들어서 보냅니다.

즉, **서버가 페이지를 알고 있습니다.**

---

#### React(SPA)

처음에

```text
/
```

만 요청합니다.

그러면 서버는

```text
index.html
```

하나만 내려줍니다.

그 이후에는

```text
/article/7/edit
```

로 이동해도 **브라우저 안에서 React Router가 화면만 바꿉니다.**

즉,

```
index.html
        │
        ▼
React 실행
        │
        ├── /
        ├── /new
        ├── /article/1
        └── /article/7/edit
```

모든 라우팅은 React가 처리합니다.

---

### 왜 404가 나는가?

브라우저에서

```text
http://.../article/7/edit
```

를 **직접 입력**하면

브라우저는 먼저 서버(nginx)에게

> `/article/7/edit` 파일 주세요.

라고 요청합니다.

그런데 nginx는

```
/usr/share/nginx/html/article/7/edit
```

라는 파일을 찾습니다.

당연히 없습니다.

그래서

```
404 Not Found
```

를 반환합니다.

---

### `try_files`가 하는 일

nginx 설정에

```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

를 넣으면

1. `/article/7/edit` 파일이 있는지 찾음
2. 없으면
3. **무조건 `index.html`을 반환**

그러면 React가 실행되고,

```jsx
<Route path="/article/:id/edit" element={<Write />} />
```

를 보고

> "아, 수정 페이지구나!"

라고 판단해서 `Write` 컴포넌트를 보여줍니다.

---

### 지금 상황

- ✅ React Router 설정 정상
- ✅ Ingress 설정 정상
- ✅ API 정상
- ❌ nginx가 `index.html` 대신 404를 반환

그래서 `nginx.conf`에 `try_files` 설정을 추가하면 해결됩니다.

---

---

- **Karpenter가 노드를 생성하지 않는 경우:**
  - `karpenter-controller` 로그에서 오류 메시지를 확인하세요.
  - `nodepool.yaml`에서 올바른 인스턴스 유형이 정의되었는지 확인하세요.

AWS Load Balancer Controller를 연결해 외부 트래픽을 안정적으로 처리
워크로드 수요에 따라 자동으로 노드를 프로비저닝할 수 있도록 설정합니다.
ALB 컨트롤러를 설치하여 쿠버네티스 서비스와 AWS 로드 밸런서를 통합할 수 있도록 합니다

1.Kubernetes 기반 고가용성 환경 구축,EKS 기반 Kubernetes 운영 환경 구축
2.HPA / Karpenter 기반 Auto Scaling
3.GitHub Actions + Argo CD 기반 CI/CD 구축
4.Prometheus / Grafana 기반 모니터링,EKS 기반 Kubernetes 운영 환경 구축
5.Fluent Bit + Elasticsearch + Kibana 기반 중앙 로그 수집
6.SLO 기반 서비스 상태 관리 7.장애 상황 분석 및 Troubleshooting

8..Karpenter를 이용한 Node 자동 Provisioning
9.AWS Load Balancer Controller를 이용한 ALB 연동
10.Helm을 이용한 Kubernetes 리소스 관리
11.Argo CD를 이용한 GitOps 기반 배포

12.Fluent Bit / Elasticsearch / Kibana를 이용한 Log 수집 및 분석
13.SLO를 정의하고 Metric을 기반으로 서비스 상태를 관찰

동시에 사용자 지정 kubelet 인수가 지원되므로 고급 CPU 및 메모리 관리 정책을 사용할 수 있습니다.  
또한 클러스터별 별도 권한의 필요성을 우회하면서 서비스 계정에 대한 AWS ID 및 액세스 관리(IAM) 역할을 통해 보안을 강화합니다.

EKS는 다양한 오픈소스 도구와의 통합성이 뛰어나 운영 자동화, 서비스 메시, GitOps 기반 배포, 고급 로깅/모니터링 등을 적용할 수 있습니다.  
기능별로 잘게 나뉜 마이크로 서비스 구조를 가진 프로젝트는 시간이 지날수록 운영이 복잡해집니다. 특히 컨테이너 수가 많아지면 리소스 할당, 네트워크, 배포 전략, 장애대응 등에서 고도화가 필요합니다.

db_query_duration_seconds_sum{query="select_article_by_id"} 0.005586857
db_query_duration_seconds_count{query="select_article_by_id"} 2

sum 0.005586857 지금까지 쿼리 수행에 걸린 시간의 합(초)
count 2 지금까지 해당 쿼리를 총 2번 실행함

평균 구하는 법

평균 지연 시간 = sum / count

0.005586857 / 2 = 0.0027934285초

db_query_duration_seconds_bucket{le="+Inf"} 2 는 `(모든 요청이 포함된 누적합)`이에요.
->> le ="+Inf" 가 뭔지 알려라 length??  
sum ->지금까지 쿼리들이 사용한 총 시간
count ->쿼리 실행 횟수
sum / count 평균 실행 시간
bucket{le="0.005"} 해당 구간 이하로 끝난 횟수 (누적)

총 2회 쿼리 실행

총 0.005586초 소요

평균 쿼리당 약 2.8ms 2.8 밀리초(ms) = 0.0028초(s) 입니다.

---

이제 데이터가 다 나왔네. **내가 앞에서 말한 "Memory 56%라서 3개 유지"는 방향은 맞았지만, 숫자를 정확히 계산하면 더 명확해.**

현재 server Pod:

```text
server-1   CPU 8m   Memory 76Mi
server-2   CPU 8m   Memory 73Mi
server-3   CPU 8m   Memory 67Mi
```

평균 메모리:

```text
(76 + 73 + 67) / 3
= 약 72Mi
```

server의 memory request가 이전 설정대로 `128Mi`라면:

```text
72Mi / 128Mi
≈ 56%
```

그래서 HPA 출력과 정확히 일치해:

```text
memory: 56% / 80%
```

## 왜 56%인데 3개 유지하냐?

HPA 계산은 대략:

```text
desiredReplicas =
ceil(currentReplicas × currentUtilization / targetUtilization)
```

현재:

```text
ceil(3 × 56 / 80)
= ceil(2.1)
= 3
```

즉:

```text
현재 3개
Memory 56%
Target 80%

계산 결과 → 3개 필요
```

그래서 scale-in이 안 되는 거야.

### 3 → 2로 줄어들려면

```text
ceil(3 × 현재 메모리% / 80) <= 2
```

대략 메모리 사용률이 **53% 이하**까지 내려가야 해.

예를 들어:

```text
50%
ceil(3 × 50 / 80)
= ceil(1.875)
= 2
```

그런데 지금 Node.js 서버가 요청이 없어도 기본적으로:

```text
67~76Mi
```

정도의 메모리를 계속 사용하고 있으니까, Pod가 idle 상태여도 HPA 입장에서는:

```text
Memory 56%
→ 3개 유지
```

가 되는 거지.

---

## CPU는 scale-in을 원하지만 Memory가 막고 있음

CPU:

```text
16% / 75%
```

계산:

```text
ceil(3 × 16 / 75)
= ceil(0.64)
= 1
```

CPU 기준:

```text
3 → 1
```

Memory 기준:

```text
3 → 3
```

여러 Metric을 사용하는 HPA는 각 metric이 계산한 replica 수 중 **더 큰 값을 선택**하니까:

```text
CPU     → 1
Memory  → 3
             ↑
최종 선택
```

따라서 지금은 **HPA가 이상한 게 아니라 Memory 기반 autoscaling 때문에 3개가 유지되는 것**이야.

---

# 이게 중요한 이유

너처럼 Node.js 애플리케이션에:

```yaml
requests:
  cpu: 250m
  memory: 128Mi
```

를 설정하고 Memory HPA를 같이 쓰면, 애플리케이션의 기본 메모리 사용량이 이미:

```text
약 70Mi
```

니까 아무 요청이 없어도:

```text
70 / 128 × 100
≈ 55%
```

가 돼.

즉 Memory target을:

```yaml
targetMemoryUtilizationPercentage: 80
```

로 설정해도 scale-in이 잘 안 될 수 있어.

## 내 추천

현재 애플리케이션에서는 우선 **CPU 기반 HPA만 사용하는 게 테스트 목적에 더 적합해 보여.**

```yaml
autoscaling:
  enabled: true
  minReplicas: 1
  maxReplicas: 10
  averageUtilization: 75
```

Memory metric은 제거하거나, 정말 필요하면 실제 메모리 사용 패턴을 측정한 후 추가하는 게 좋아.

왜냐하면 지금처럼:

```text
부하 없음
↓
CPU 16%
↓
Memory 56%
↓
Memory 때문에 Pod 3개 유지
```

가 발생하기 때문이야.

특히 네가 지금 하는 테스트 목적이 **"k6 부하 → CPU 증가 → HPA Scale Out → 부하 종료 → Scale In"**을 검증하는 거라면:

```text
CPU HPA
```

만 두는 게 결과를 훨씬 명확하게 볼 수 있어.

추천 테스트:

```yaml
server:
  autoscaling:
    enabled: true
    minReplicas: 1
    maxReplicas: 10
    averageUtilization: 75

  resources:
    requests:
      cpu: 250m
      memory: 128Mi
    limits:
      cpu: 500m
      memory: 512Mi
```

그다음:

```bash
kubectl get hpa -w
```

로 보면서 k6를 실행하면:

```text
idle
1 Pod

↓

k6 부하 증가

↓

CPU > 75%

↓

1 → 2 → 3 ... Scale Out

↓

k6 종료

↓

CPU 감소

↓

stabilization window 이후

↓

3 → 2 → 1 Scale In
```

이 흐름을 명확하게 검증할 수 있어.
