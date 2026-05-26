# project-1

### 아키텍처

<img width="626" alt="스크린샷 2024-03-01 오후 7 11 39" src="https://github.com/leesanghoon94/my/assets/127801771/52f21cbf-7ee9-4a64-8a60-10e1e71dc75f">

### 개요

Terraform을 사용하여 AWS 인프라(VPC, Subnet, Route53, ALB, EC2, RDS)를 코드 기반으로 구축하고, Public/Private subnet 분리 및 HTTPS 통신을 적용한 운영 환경 구성 프로젝트

프리티어 활용  
_ami = "ami-04599ab1182cd7961"_  
_instance_type = "t2.micro"_

Terraform을 활용하여 VPC, Subnet, Route Table, Security Group, EC2, ALB, RDS 리소스를 IaC 방식으로 관리하여 재현 가능한 인프라 환경 구성
테라폼을 이용해 인프라를 코드로 문서화
관리형 데이터베이스 서비스(RDS)를 사용하여 백업, 운영 편의성 및 안정성 확보

퍼블릿서브넷에 ELB를 사용하여 트래픽을 분산하고, Route 53과 ACM를 활용하여 SSL 인증서를 관리하여 보안성을 강화합니다. https 통신 구현  
route53으로 도메인 쿼리를 통해 유저에게 쉬운 접근,서비스를 이용할수있게 구현  
RDS를 활용하여 데이터베이스 관리의 편의성과 성능을 동시에 보장합니다.  
Private 서브넷에 위치하여 외부에서 직접 접근이 불가능하도록 보안을 강화합니다.

Private 서브넷 ec2를 하나 올려서.
frontend :React와 Nginx
backend : nodejs express

openVpn ec2를 통해서 로컬에서 프라이빗 서브넷 접근을 편리하게 구현.

좋아요. 데브옵스 신입 기준으로 **“왜 이런 구조를 선택했는지 설명 가능한 포트폴리오”** 느낌으로 다시 써볼게요. 지금 네 프로젝트 수준(AWS + Terraform + Private subnet + VPN + HTTPS)을 살리되, **운영/자동화/보안 관점** 중심으로 바꿨습니다.

지금 포트폴리오에 바로 넣을 수 있는 수준으로 작성해볼게요.

---

## Project 1 — Terraform 기반 AWS 인프라 구축 및 웹 서비스 운영 환경 구성

### 프로젝트 개요

Terraform을 활용하여 AWS 기반의 웹 서비스 운영 환경을 구축한 프로젝트입니다.
Public / Private subnet 구조를 설계하고, HTTPS 통신 환경 및 내부 접근 제어를 구성하여 운영 관점의 인프라 환경을 구현했습니다.

또한 Infrastructure as Code(IaC)를 적용하여 인프라를 코드로 관리하고 재현 가능한 환경 구성을 목표로 하였습니다.

### 인프라 설계 및 기술 선택 이유

#### 1. Terraform 기반 Infrastructure as Code 적용

Terraform을 사용하여 VPC, Subnet, Security Group, EC2, ALB, Route53, RDS 리소스를 코드 기반으로 관리하였습니다.

이를 통해 다음을 고려했습니다.

- 재현 가능한 인프라 환경 구성
- 수동 콘솔 작업 최소화
- 인프라 변경 이력 관리
- 반복 배포 자동화 기반 마련

---

#### 2. Public / Private subnet 분리

보안성과 운영 구조를 고려하여 네트워크를 Public / Private subnet으로 분리했습니다.

설계 이유:

- 외부 트래픽은 ALB를 통해서만 진입
- Backend EC2와 RDS는 외부 Public 접근 차단
- 내부 통신만 허용하여 공격 surface 최소화

구성:

```txt id="ry4m2u"
Public subnet
- ALB
- NAT Gateway
- OpenVPN EC2

Private subnet
- Application EC2
- RDS
```

---

#### 3. HTTPS 통신 구성 (ACM + ALB)

AWS ACM을 활용하여 TLS 인증서를 적용하고 HTTPS 통신을 구성했습니다.

적용 이유:

- 사용자 ↔ 서비스 구간 암호화
- 인증서 자동 갱신 지원
- 운영 비용 최소화

또한 TLS 종료(TLS termination)를 ALB에서 수행하여 애플리케이션 레벨 부담을 줄였습니다.

---

#### 4. Web Server / WAS 역할 분리

하나의 EC2 내부에서 역할을 논리적으로 분리했습니다.

```txt id="pvf53i"
Nginx
→ 정적 리소스 제공
→ Reverse Proxy

Node.js Express
→ API 처리
→ 비즈니스 로직 수행
→ DB 연동
```

이를 통해 Web Server와 WAS 역할을 구분하여 서비스 구조를 설계했습니다.

---

#### 5. VPN 기반 운영 접근 제어

Private subnet 환경에서 직접 SSH 접근이 불가능하므로 OpenVPN 환경을 구축하여 운영 접근성을 확보했습니다.

이를 통해:

- Private EC2 직접 공개 방지
- 운영자 내부 접근 체계 구성
- 보안성 향상

---

### 트러블슈팅

#### 1. Private subnet 접근 문제

**문제**

Private subnet EC2에 직접 접근 불가능

**원인**

Public IP 미부여 구조

**해결**

OpenVPN 서버를 구축하여 내부망 접근 체계 구성

---

#### 2. HTTPS 구성 시 Health Check 실패

**문제**

ALB Target Group 상태 비정상

**원인**

애플리케이션 Health Check endpoint 미구성

**해결**

Application health endpoint 추가 및 Security Group 정책 수정

---

#### 3. Terraform 리소스 삭제 실패

**문제**

Terraform destroy 시 VPC 삭제 실패

**원인**

종속 ENI 및 dependency 문제

**해결**

리소스 의존성 확인 후 제거 순서 조정

---

### 프로젝트를 통해 얻은 경험

- Terraform 기반 IaC 경험
- AWS 네트워크 구조(Public/Private subnet) 설계 경험
- HTTPS 및 TLS 인증서 운영 경험
- 보안 관점의 접근 제어 구성 경험
- Web Server / WAS 구조 이해
- 운영 환경 관점에서의 트러블슈팅 경험
