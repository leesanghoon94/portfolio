# 프로젝트-3(eks)

## 개요
aws 관리형 kubernetes를 통해서 -3(eks)


Karpenter
Karpenter는 유연한 고성능 Kubernetes 클러스터 자동 규모 조정기로 애플리케이션 가용성과 클러스터 효율성 개선에 도움이 됩니다.Karpenter는 변화하는 애플리케이션 로드에 대응하여 적절한 크기의 컴퓨팅 리소스를 시작합니다. 이 옵션은 워크로드의 요구 사항을 충족하는 적시 컴퓨팅 리소스를 프로비저닝할 수 있습니다.

관리형 노드 그룹
관리형 노드 그룹은 Amazon EKS 클러스터 내 Amazon EC2 인스턴스 컬렉션 관리에 대한 자동화와 사용자 지정을 결합합니다. AWS는 노드 패치, 업데이트 및 규모 조정과 같은 작업을 처리하여 운영상의 부담을 덜어줍니다. 동시에 사용자 지정 kubelet 인수가 지원되므로 고급 CPU 및 메모리 관리 정책을 사용할 수 있습니다. 또한 클러스터별 별도 권한의 필요성을 우회하면서 서비스 계정에 대한 AWS ID 및 액세스 관리(IAM) 역할을 통해 보안을 강화합니다.

이 프로젝트는 Terraform을 사용하여 AWS Elastic Kubernetes Service (EKS) 클러스터를 구축하는 환경을 제공합니다. 자동화된 배포, 스케일링, 컨테이너화된 애플리케이션의 관리를 지원하며, 주요 구성 요소로는 Karpenter(자동 스케일링), AWS Load Balancer Controller(트래픽 관리), FluentBit 및 Prometheus(모니터링 및 로깅 도구)가 포함됩니다. 이를 통해 클러스터는 워크로드 수요에 따라 동적으로 노드 용량을 조정하여 비용 효율성과 고가용성을 보장합니다.

## 아키텍처
이 프로젝트는 배포 및 관리를 단순화하기 위해 모듈화된 확장 가능한 아키텍처를 따릅니다. 구성 요소는 다음과 같습니다.

- **Terraform 구성 파일** (`.tf` 파일)
  - `main.tf`, `provider.tf`, `vpc.tf`, `karpenter.tf` 등은 VPC, 서브넷, EKS 클러스터, IAM 역할, Karpenter 설정과 같은 인프라 리소스를 정의합니다.
  - `modules/` 디렉터리는 재사용성과 유지보수를 쉽게 하기 위한 모듈화된 Terraform 설정을 포함합니다.
  
- **쿠버네티스 매니페스트** (`manifest/`)
  - `karpenter/`: Karpenter 리소스를 정의하며, `nodepool.yaml`(동적 노드 프로비저닝) 및 `karpenter-test-pod.yaml`(오토스케일링 테스트)이 포함됩니다.
  - `lb-controller/`: AWS Load Balancer Controller 설정으로, 쿠버네티스 서비스와 AWS ALB 통합을 담당합니다. 여기에는 `cert-manager.yaml`, `v2_8_1_full.yaml`, `v2_8_1_ingclass.yaml` 등이 포함됩니다.

- **아카이브된 리소스** (`archive/`)
  - 과거에 사용되었거나 문서화를 위해 보관된 쿠버네티스 설정을 포함합니다.
  - **app/**: 애플리케이션 배포 및 서비스 관련 설정.
  - **argocd/**: GitOps 기반 배포 관리를 위한 ArgoCD 설치 매니페스트.
  - **fluentbit/**: 로그 수집 및 전송을 위한 DaemonSet 구성.
  - **prometheus/**: Prometheus 및 Alertmanager를 활용한 모니터링 설정.
---
# Terraform을 활용한 EKS 클러스터 구축
## 사용법
- **AWS CLI** (적절한 IAM 자격 증명으로 설정 필요)
- **Terraform** (`>= 1.0` 버전 권장)
- **Kubectl** (쿠버네티스 클러스터와 상호작용하기 위해 필요)
- **Helm** (쿠버네티스 애플리케이션 관리용)
   ```sh
   terraform init
   terraform apply -auto-approve
3. **kubectl을 사용하여 클러스터에 연결:**
   ```sh
   aws eks update-kubeconfig --region <region> --name <cluster-name>
   ```
   로컬 `kubectl`을 통해 EKS 클러스터에 액세스할 수 있도록 구성합니다.

4. **Karpenter 배포 (자동 스케일링 활성화):**
   ```sh
   kubectl apply -f manifest/karpenter/
   ```
   워크로드 수요에 따라 자동으로 노드를 프로비저닝할 수 있도록 설정합니다.

5. **AWS Load Balancer Controller 배포:**
   ```sh
   kubectl apply -f manifest/lb-controller/
   ```
   ALB 컨트롤러를 설치하여 쿠버네티스 서비스와 AWS 로드 밸런서를 통합할 수 있도록 합니다.

## 모니터링 및 로깅
효율적인 모니터링 및 문제 해결을 위해 다음 도구들을 포함합니다.

- **grafana**: 
- **Prometheus**: 클러스터의 CPU/메모리 사용량, 노드 상태, 애플리케이션 성능 등을 모니터링합니다. Alertmanager와 함께 설정하여 문제 발생 시 사전 대응할 수 있도록 구성됩니다.

## 문제 해결
일반적인 문제 및 해결 방법은 `archive/etc/troubleshooting.md` 파일에서 확인할 수 있습니다. 몇 가지 주요 시나리오는 다음과 같습니다.

- **Terraform 프로비저닝 오류:**
  - AWS 자격 증명이 올바르게 설정되었는지 확인하세요.
  - 필요한 IAM 역할 및 정책이 적용되었는지 점검하세요.

- **Karpenter가 노드를 생성하지 않는 경우:**
  - `karpenter-controller` 로그에서 오류 메시지를 확인하세요.
  - `nodepool.yaml`에서 올바른 인스턴스 유형이 정의되었는지 확인하세요.

- **AWS Load Balancer Controller 관련 Ingress 문제:**
  - ALB 컨트롤러에 필요한 IAM 정책이 적용되었는지 확인하세요.
  - `kubectl get ingress` 명령을 실행하여 Ingress 리소스가 올바르게 설정되었는지 확인하세요.

이 가이드를 따르면 확장 가능하고 높은 성능을 제공하는 EKS 클러스터를 효율적으로 구축하고 운영할 수 있습니다.

---
sli ->slo ->sla 순으로 설계
다운타임최소화 -> cloudwatch alert slack
latency
log
error, ok status
observability 모니터링을 통해 왜 현상이 일어났는지 분석하고 해결하는 접근방식

애플리케이션 slo 기준 세우기 
현재 성능을 기준으로 목표치로 설정하지말것
최대한 단순하게 생각할것
현실성있는 목표치를 설정할것
처음부터 완벽하게 하려고 하지말것
시스템의 특성을 잘확인할수있는가능한 적은수의 slo를 설정할것 3~5개

게시판 특성상 읽기,쓰기
응답시간 가용성 에러율

게시판 애플리케이션에서 SLO(서비스 수준 목표)를 설정하려면, 실제 사용자 경험과 비즈니스 목표를 반영하는 것이 중요합니다.  

게시판 특성상, 주로 **읽기**, **쓰기**와 관련된 요청이 많을 텐데, **응답 시간**, **가용성**, **에러율** 등의 지표를 기준으로 설정할 수 있습니다.  
이를 바탕으로 현실적이고 단순한 목표 SLO를 세울 수 있습니다.

### 현실적이고 단순한 게시판 SLO 기준

---

### 1. 가용성 (Availability)

게시판 시스템은 항상 접근 가능해야 하므로 서비스의 가용성을 중요하게 설정합니다.
대부분의 시스템에서는 가용성 목표를 **99.9% 이상**으로 설정합니다.

* **목표**: `99.9%` 이상의 가용성 (연간 최대 다운타임: 약 8시간 45분)

  * `SLO` 예시: **서비스 1년 중 8시간 45분 이하의 다운타임**
  * 이를 Prometheus에서는 `up` 지표로 모니터링할 수 있습니다.

---

### 2. **응답 시간 (Latency)**

게시판에서는 주로 **읽기 요청**(GET)과 **쓰기 요청**(POST)으로 구분할 수 있습니다.
각각의 요청에 대해 **응답 시간**이 중요한 지표입니다.

* **목표**:

  * **읽기 요청** (GET) : `99%`의 요청이 **200ms 이하**로 처리
  * **쓰기 요청** (POST) : `99%`의 요청이 **500ms 이하**로 처리
* **목표 설명**:

  * **읽기 요청**은 주로 데이터베이스에서 데이터를 조회하는 것이므로 **빠른 응답**을 요구합니다.
  * **쓰기 요청**은 데이터베이스 쓰기 작업이 포함되므로 **읽기보다는 조금 느릴 수 있음**.

  이를 Prometheus에서 **histogram**으로 추적할 수 있습니다.

  ```js
  const responseTimeHistogram = new client.Histogram({
    name: 'http_request_duration_seconds',
    help: 'Duration of HTTP requests',
    labelNames: ['method', 'route', 'status_code'],
    buckets: [0.1, 0.3, 0.5, 1, 2, 3, 5] // 나누는 구간
  })
  ```

  예를 들어, GET 요청의 응답 시간이 200ms 이하인 비율을 확인할 수 있습니다.

---

### 3. **에러율 (Error Rate)**

애플리케이션에서 오류가 발생할 경우, 그 비율을 **에러율**로 모니터링합니다.
주로 **4xx** (클라이언트 오류)와 **5xx** (서버 오류) 상태 코드를 기준으로 에러를 판단합니다.

* **목표**: `1% 이하`의 에러율

  * 즉, 전체 요청에서 **에러 응답 비율**이 `1%`를 초과하지 않도록 관리해야 합니다.
  * 이 목표를 초과하면 사용자는 게시판을 사용하면서 오류가 자주 발생한다고 느낄 수 있습니다.

  이를 Prometheus에서는 **Counter**를 사용하여 `4xx`와 `5xx` 응답 수를 추적할 수 있습니다.

  ```js
  const errorCounter = new client.Counter({
    name: 'http_request_errors_total',
    help: 'Total number of failed HTTP requests',
    labelNames: ['method', 'route', 'status_code']
  })
  ```

  예를 들어, **에러율**을 `rate(http_request_errors_total[5m]) / rate(my_request_count[5m])`로 구할 수 있습니다.

---

### 4. **데이터베이스 성능 (Database Performance)**

게시판 애플리케이션은 데이터베이스와 상호작용을 많이 합니다. 데이터베이스 쿼리의 **응답 시간**은 중요한 지표입니다.

* **목표**:

  * `99%`의 DB 쿼리 응답 시간이 **100ms 이하**여야 한다.
  * **최대 200ms**를 넘지 않도록 한다.
  * 이 목표를 달성하려면 데이터베이스 인덱스, 쿼리 최적화 등이 필요합니다.

  이를 Prometheus의 **Histogram**으로 추적할 수 있습니다.

  ```js
  const dbQueryDuration = new client.Histogram({
    name: 'db_query_duration_seconds',
    help: 'DB query latency in seconds',
    labelNames: ['query']
  })
  ```

  이렇게 하면 `db_query_duration_seconds` 메트릭을 통해 DB 쿼리의 평균, P95, P99 등을 모니터링할 수 있습니다.

---

## 종합적인 SLO 예시

| 항목               | 목표 SLO                         | 설명                                 |
| ---------------- | ------------------------------ | ---------------------------------- |
| **가용성**          | 99.9% 이상                       | 서비스가 다운되는 시간은 연간 8시간 45분 이하로 유지.   |
| **응답 시간 (GET)**  | 99% 요청은 200ms 이하               | 게시글 조회 요청 (읽기 요청)은 200ms 이내에 처리    |
| **응답 시간 (POST)** | 99% 요청은 500ms 이하               | 게시글 작성 요청 (쓰기 요청)은 500ms 이내에 처리    |
| **에러율**          | 전체 요청의 1% 이하                   | 4xx, 5xx 상태 코드 비율이 1% 이하로 유지       |
| **DB 쿼리 성능**     | 99%의 DB 쿼리는 100ms 이하, 최대 200ms | DB에서 데이터를 조회/삽입/수정할 때 지연 시간을 모니터링. |

이 기준들은 현실적으로 **게시판** 서비스의 **사용자 경험**을 고려한 것입니다.
운영 환경에서 **과도한 성능 최적화**는 필요 없지만, 적당한 **속도와 안정성**을 유지하는 것이 중요합니다.

---

### Prometheus & Grafana로 모니터링

이러한 SLO 목표를 Prometheus에서 직접 모니터링하고, Grafana 대시보드를 통해 실시간으로 확인할 수 있습니다.
Prometheus에서 수집한 **`http_request_duration_seconds`** (응답 시간), **`http_request_errors_total`** (에러율), **`db_query_duration_seconds`** (DB 성능) 메트릭을 사용하여 대시보드 시각화 및 알림을 설정할 수 있습니다.

이렇게 목표를 세운 후에는 **실제 서비스에서 목표에 도달할 수 있도록** 지속적으로 모니터링하고 개선 작업을 해 나가는 것이 중요합니다!

---
TypeError: responesTimeHistogram is not a function
    Value is not a valid number: undefined

    이 코드 구문은 Express.js 에서 요청에 대한 응답 시간을 추적하기 위해 사용됩니다. 

### 설명:

```javascript
res.on('finish', () => { 
  responseTimeHistogram.observe({ 
    method: req.method, 
    route: req.path, 
    status_code: res.statusCode 
  }, res.responseTime);
});
```

#### 1. _`res.on('finish', ...)`_

* `res.on('finish')`는 응답이 완료된 후에 특정 동작을 수행하는 이벤트 리스너입니다.  
요청이 처리된 후 응답이 클라이언트로 전송되면 `finish` 이벤트가 발생합니다.
* `finish` 이벤트는 응답이 **완료**되었을 때 실행되며, 여기서는 요청의 **응답 시간**을 추적하는 데 사용됩니다.

#### 2. _`responseTimeHistogram.observe(...)`_:

* responseTimeHistogram은 prom-client 라이브러리를 사용하여 정의된 Histogram 메트릭입니다.  
`Histogram`은 값이 특정 범위에 속하는 빈도수를 추적합니다. 여기서는 응답 시간이 일정 구간에 얼마나 많이 발생했는지를 추적하는 데 사용됩니다.

* `observe`는 **응답 시간**을 해당 히스토그램에 기록하는 메서드입니다. 이 메서드는 요청마다 **응답 시간**을 측정하고 이를 히스토그램 메트릭에 기록합니다.

* **`method: req.method`**: HTTP 메서드(예: `GET`, `POST` 등)

* **`route: req.path`**: 요청된 경로 (예: `/api/article` 등)

* **`status_code: res.statusCode`**: HTTP 응답 상태 코드 (예: `200`, `404` 등)

* **`res.responseTime`**: Express에서 제공하는 응답 시간이 얼마나 걸렸는지 측정된 값 (단위: 밀리초)

#### 3. **결과적으로**:

* 이 코드는 매 요청이 처리되고 응답이 완료될 때마다 해당 요청의 **응답 시간**을 **히스토그램**으로 기록합니다. 이렇게 측정된 데이터를 Prometheus와 같은 모니터링 툴로 수집하여 **응답 시간이 얼마나 걸렸는지** 모니터링하고 분석할 수 있습니다.

### 예시:

예를 들어, `/api/article`라는 경로로 요청을 보내고 응답이 300ms 걸렸다면, 이 응답 시간이 `responseTimeHistogram`에 기록됩니다. 이후 이 데이터를 Prometheus가 수집하면, 응답 시간 분포를 시각화하여 얼마나 빠른지, 느린지 등을 알 수 있게 됩니다.

이 코드는 **성능 모니터링**을 위한 중요한 요소입니다. 응답 시간이 얼마나 걸리는지 실시간으로 추적하고 이를 분석하여 **서비스 성능**을 개선할 수 있는 기회를 제공하죠.

### 결론:

요약하자면, 이 코드는 **Express.js**에서 **응답 시간**을 추적하여 Prometheus와 같은 시스템으로 모니터링할 수 있도록 데이터를 기록하는 방식입니다. 이를 통해 실제 서비스의 성능을 파악하고, 필요한 개선점을 찾아내는 데 유용합니다.
요청이 완전히 끝난후 res.finish 이벤트에서 metric을 기록 responseTimeHistogram, errorCount,
requestCounter 요청이들어온순간 실패하든 성공하든 일단 요청발생 카운트

db_query_duration_seconds_sum{query="select_article_by_id"} 0.005586857
db_query_duration_seconds_count{query="select_article_by_id"} 2

여기서 핵심은 sum과 count 입니다.

sum	0.005586857	지금까지 쿼리 수행에 걸린 시간의 합(초)
count	2	지금까지 해당 쿼리를 총 2번 실행함

평균 구하는 법

평균 지연 시간 = sum / count

0.005586857 / 2 = 0.0027934285초


평균 약 0.0028초 (≈ 2.8밀리초) 걸렸다는 뜻이에요.

Prometheus 히스토그램은 “버킷(bucket)”으로도 누적 빈도를 보여줍니다:

db_query_duration_seconds_bucket{le="0.005"} 2


이 뜻은

0.005초(=5ms) 이하로 끝난 쿼리가 2번 있었다라는 의미예요.

그리고 가장 마지막에

db_query_duration_seconds_bucket{le="+Inf"} 2 는 `(모든 요청이 포함된 누적합)`이에요.

sum	->지금까지 쿼리들이 사용한 총 시간
count	->쿼리 실행 횟수
sum / count	평균 실행 시간
bucket{le="0.005"}	해당 구간 이하로 끝난 횟수 (누적)

총 2회 쿼리 실행

총 0.005586초 소요

평균 쿼리당 약 2.8ms  2.8 밀리초(ms) = 0.0028초(s) 입니다.
 
---rate(request_duration_seconds_sum[5m])
/
rate(request_duration_seconds_count[5m])
histogram_quantile(
  0.95,
  sum by (le)(
    rate(request_duration_seconds_bucket[5m])
  )
)


eks