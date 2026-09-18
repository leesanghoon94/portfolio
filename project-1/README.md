# project-1

### 개요 :Terraform 기반 AWS 소규모 웹 서비스 구축 및 CI/CD 자동화

Terraform을 활용하여 AWS 인프라(VPC, Subnet, ALB, EC2, ALB, RDS)를 코드 기반으로 프로비저닝하고, 콘솔에서 Route53 + CloudFront + ACM을 적용하여 HTTPS 기반 서비스 환경을 구성했습니다.

또한 Jenkins + Ansible 기반 CI/CD 파이프라인을 구축하여 Frontend / Backend 배포 자동화를 구현하고 slack 알림 연동을 통해 배포 상태를 확인할 수 있도록 구성했습니다.

---

### 아키텍처

<img width="626" alt="스크린샷 2024-03-01 오후 7 11 39" src="/Users/lee/Desktop/portfolio/project-1/스크린샷 2026-06-05 오후 4.55.44.png">

### 사용법

테라폼을 활용하여 인프라를 생성합니다.

```zsh
terraform init
terraform plan
terraform apply
```

---

### Terraform 기반 Infrastructure as Code 적용

aws provider을 지원하는 Terraform을 활용하여 VPC, Subnet, Route Table, Security Group, EC2, RDS 리소스 구축

```
- 콘솔 수작업 최소화를 통한 휴먼 에러 감소
- 인프라 변경 이력 관리 문서화
- 동일한 인프라 환경 재현 가능
```

---

### Public / Private subnet 분리

EC2와 RDS를 Private 서브넷에 위치하여 외부에서 직접 접근이 불가능하도록하여 외부 접속 최소화하려고 설계했습니다.

```
-  외부 직접 접근 차단
-  Security Group 기반 내부 통신 허용
-  RDS 외부 접근 제한

openvpn
- Private subnet ec2 접근 문제를 해결하기 위해 OpenVPN을 통해 VPN 연결을 통해 로컬 환경이 VPC 내부 네트워크에 접근이 가능하도록 했습니다.

```

---

### Web Server / WAS 역할 분리

하나의 EC2 내부에서 Web Server와 WAS 역할을 논리적으로 분리했습니다.

```
 frontend (nginx,react)
   - react build 정적 리소스 제공
   - csr(client side rendering)
 backend(Node.js Express)
   - API 처리
   - DB 연동
```

---

### 관리형 데이터베이스 서비스(RDS)

aws에서 관리해주는 Engine version MySQL 8.4.8 를 사용하여 운영 부담을 줄였습니다.  
Multi-AZ 환경으로 구성하여 Primary/Standby 구조를 적용했습니다.  
단일 AZ 장애 시 standby replica는 읽기/쓰기 작업을 수행하지 않고 primary 장애에 대응하는역할입니다.  
애플리케이션 중단을 최소화하고 가용성을 높일수있습니다.

```
- 고가용성 확보
- 자동 장애 조치
- 내구성 강화
- 데이터베이스 성능보호
```

_DB Subnet Group = [aws_subnet.my-private-subnet-db-a, aws_subnet.my_private_subnet_db_c]_

---

### Jenkins + Ansible 기반 CI/CD 자동화

github에 commit이 발생하면 빌드되는 트리거를 통해 자동 빌드 배포가 되도록 파이프라인을 구성했습니다.

**Frontend**

GitHub Push
→ Jenkins Trigger
→ React Build
→ Ansible Playbook
→ Nginx 서버 배포
→ Slack 알림

**Backend**

GitHub Push
→ Jenkins Trigger
→ Build
→ Ansible-playbook
→ WAS 서버 배포
→ Slack 알림

수동 배포 과정을 제거하고 Ansible 기반 무중단에 가까운 정적 파일 배포 운영 환경을 구축했습니다.  
빌드 시작 완료 메세지를 slack 알람을 통해 받을수있습니다.

## cloudfront

CloudFront를 통해 사용자 요청을 처리하도록 구성하고, Origin으로 ALB를 연결하여 애플리케이션 서버로 트래픽이 전달되도록 설계했습니다.

서버의 요청이 필요 없기 때문에 서버의 부하를 낮추는 효과

view protocol policy = HTTP and HTTPS  
캐시 정책 = cachingOptimized  
Minimum TTL (seconds) 1  
Maximum TTL (seconds) 31536000  
Default TTL (seconds) 86400

추후 수정이 많을경우 TTL을 60초로 짧게 맞춘다던지 해서 개발을 진행하고, 나중에 안정화 되면 다시 TTL을 늘려 캐싱을 길게 하는 식으로 세팅.

## HTTPS 적용 (Route53 + ACM + CloudFront + ALB)

Route 53과 CloudFront를 연동하여 사용자 도메인으로 서비스에 접근할 수 있도록 구성하고, ACM 인증서를 적용하여 HTTPS 통신을 지원했습니다.

도메인 기반으로 서비스를 제공하여 사용자가 IP 주소 대신 도메인으로 쉽게 접근할 수 있도록 구성했습니다.

- ACM의 인증서의 갱신 및 배포를 관리

- HTTP 요청은 HTTPS로 Redirect되도록 설정하여 암호화되지 않은 접근을 제한했습니다.

- 도메인 기반 서비스 환경 구성 사용자가 접근이 쉬워지도록 만들었습니다.
