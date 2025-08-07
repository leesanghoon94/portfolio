# eks 프로젝트

### 개요
aws eks 관리형 kubernetes를 통해서 
### 아키텍처


Karpenter
Karpenter는 유연한 고성능 Kubernetes 클러스터 자동 규모 조정기로 애플리케이션 가용성과 클러스터 효율성 개선에 도움이 됩니다.Karpenter는 변화하는 애플리케이션 로드에 대응하여 적절한 크기의 컴퓨팅 리소스를 시작합니다. 이 옵션은 워크로드의 요구 사항을 충족하는 적시 컴퓨팅 리소스를 프로비저닝할 수 있습니다.

관리형 노드 그룹
관리형 노드 그룹은 Amazon EKS 클러스터 내 Amazon EC2 인스턴스 컬렉션 관리에 대한 자동화와 사용자 지정을 결합합니다. AWS는 노드 패치, 업데이트 및 규모 조정과 같은 작업을 처리하여 운영상의 부담을 덜어줍니다. 동시에 사용자 지정 kubelet 인수가 지원되므로 고급 CPU 및 메모리 관리 정책을 사용할 수 있습니다. 또한 클러스터별 별도 권한의 필요성을 우회하면서 서비스 계정에 대한 AWS ID 및 액세스 관리(IAM) 역할을 통해 보안을 강화합니다.

---

# Terraform을 활용한 EKS 클러스터 구축

## 개요
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

## 설치 및 배포
### 사전 요구 사항
클러스터를 배포하기 위해 아래 도구들이 설치 및 구성되어 있어야 합니다.
- **AWS CLI** (적절한 IAM 자격 증명으로 설정 필요)
- **Terraform** (`>= 1.0` 버전 권장)
- **Kubectl** (쿠버네티스 클러스터와 상호작용하기 위해 필요)
- **Helm** (쿠버네티스 애플리케이션 관리용)

### 배포 단계
다음 단계를 따라 EKS 클러스터 및 관련 컴포넌트를 배포할 수 있습니다.

1. **Terraform 초기화:**
   ```sh
   terraform init
   ```
   Terraform 작업 디렉터리를 초기화하고 필요한 플러그인을 다운로드합니다.

2. **Terraform 구성 적용:**
   ```sh
   terraform apply -auto-approve
   ```
   VPC, 서브넷, IAM 역할, EKS 클러스터 등을 포함한 AWS 리소스를 프로비저닝합니다.

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

- **FluentBit**: 경량 로그 프로세서로, 각 노드에서 실행되는 DaemonSet으로 AWS CloudWatch 또는 기타 로그 집계 시스템으로 로그를 전송합니다.
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

