                sudo -i
                yum update
                wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
                rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

                yum install -y jenkins

                잘설치되었는지
                rpm -qa | grep jenkins

                yum install -y git

                amazon-linux-extras install -y ansible2

                curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash

                export NVM_DIR="$HOME/.nvm"
                [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
                [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
                nvm install 16

                yum install -y java

                jenkins java가 없으면 실행이 안됨

                systemctl start jenkins
                ps -ef | grep jenkins

generic-webhook-trigger
var expression
user $.pusher.name
optional filter

^((?!build)) $user

# 포트폴리오

안녕하세요 저는 데브옵스 엔지니어를 꿈꾸는 이상훈입니다.
영상쪽에서 일을 하다 커리어 전환을 결심한 이후 부트캠프에서
지속적인 통합, 지속적인 배포, 모니터링 및 자동화에 대해 공부하고
프로젝트로 구현해 보았습니다.

이메일: leesanghoon.2025@gmail.com

전화번호: 010-3997-6548

Github: https://github.com/leesanghoon94

블로그: https://leesanghoon94.github.io/

## [project1](./aws/project-1/)

## [project2](./aws/project-2/)

## [project3](./aws/project-3/)

---

### 안녕하세요 저는 데브옵스 엔지니어를 꿈꾸는 이상훈입니다.

영상쪽에서 일을 하다 커리어 전환을 결심한 이후 부트캠프에서
지속적인 통합, 지속적인 배포, 모니터링 및 자동화에 대해 공부하고
프로젝트로 구현해 보았습니다.

## 🎮 Projects

---

## project 4

## 마라톤대회 기록 관리 시스템 🏃

## 목차

- 프로젝트 소개
- 아키텍처
- 기술 스택
- 구현 기능

## 프로젝트 소개

마라톤대회 기록 관리 시스템은 마라톤에 관심이 많은 유저들을 타겟으로 한 관리 서비스로, 사용자들이 참여했던 대회와 앞으로 참여할 대회에 대한 참가 신청 및 기록을 관리해 줍니다.

## 아키텍처

![스크린샷 2023-07-04 오후 3.47.18.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/d037966a-e44b-4ff5-9c72-d889f4fc6d6a/%E1%84%89%E1%85%B3%E1%84%8F%E1%85%B3%E1%84%85%E1%85%B5%E1%86%AB%E1%84%89%E1%85%A3%E1%86%BA_2023-07-04_%E1%84%8B%E1%85%A9%E1%84%92%E1%85%AE_3.47.18.png)

### AWS Cognito 기반의 JWT Token 인증 서비스

- Cognito를 사용하여 사용자 인증, 관리에 대한 처리를 위임하여 빠른 개발 가능
- 인증된 사용자에게 JWT Token를 발급하여 유효한 사용자만 요청을 처리하여 보안성을 강화

### S3, CloudFront 를 활용한 정적페이지 서비스

- S3를 사용하여 정적페이지를 효율적으로 저장하고 CloundFront를 사용하여 빠른 컨텐츠를 제공
- 자동화 된 배포파이프라인을 구축하여 빠른 컨텐츠 업데이트 가능

### Github Actions 기반의 ECR/ECS CI/CD 파이프라인

- Github Actions를 활용하여 AWS의 ECR과 ECS에 대한 CI/CD 파이프라인을 구축

### ECS를 활용한 트래픽 대응

- ECS의 오토 스케일링 기능을 활용하여 트래픽 변동에 따른 서비스 규모를 자동화

### Lambda와 SQS, EventBridge를 이용한 느슨한 결합 아키텍처

- AWS Lambda와 SQS를 이용해 각 서비스간의 의존성을 줄이고 독립적으로 사용되도록 느슨한 결합 형태의 아키텍처를 구축
- EventBridge를 사용하여 각 서비스간의 연결된 복잡한 이벤트를 효율적으로 처리

### Cloudwatch와 Grapana를 이용한 시각화 모니터링 시스템

- AWS Cloudwatch와 Grapana를 이용하여 백엔드 서버의 트래픽 모니터링 및 경고 알람 설정

## 구현 기능

---

## project 3

## <자동 재고 확보 시스템>을 위한 MSA

### 프로젝트 소개

---

웹사이트를 통해서 주문 버튼을 누르는 것으로 구매(Sales API)가 가능합니다. 창고에 재고가 있다면 재고가 감소하고 구매가 완료됩니다. 재고가 다 떨어지면 제조 공장에 알려서 다시 창고를 채우는 시스템을 구축

---

## 아키텍처

---

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/0b0104bc-c95e-4b15-88cc-446060061291/Untitled.png)

---

### 개요

- AWS 클라우드 환경을 기반으로 하는 느슨하게 연결된(loosely coupled) 애플리케이션 아키택처 배포
- “재고 없음” 메세지 전달 시스템 구성
- Producer/Consumer 패턴의 차이를 이해
- 가용성을 높이기 위한 리소스 추가

### 기술

- Serverless를 이용한 lambda 함수 메시지 대기열 활용 이해 및 구현
- DB에 재고가 없을 경우 재고가 없다는 정보를 알리기 위한 SNS 토픽(stock_empty) 생성
- 메시지를 Factory API로 전송하는 Lambda 구성 및 DLQ 추가
- SQS에서 처리완료되지 않은 메시지들을 체계적으로 관리할 dead_letter_queue를 생성
- DLQ, Legacy 시스템 성능 문제, SES(Simple Email Service)와 같은 문제 해결을 위한 리소스를 추가

### 결과

- 가용성 향상을 통해 메시지 유실을 최소화
- 재고가 있을 경우, 재고가 감소하고 구매가 완료.
- 재고가 없을 경우, 시스템에서는 공장에 재고를 보충하도록 알림.
- AWS 클라우드 환경을 기반으로 느슨하게 연결된(loosely coupled) 애플리케이션 아키택처를 배포합니다.
- "재고 없음" 메세지 전달 시스템을 구성합니다.

---

## project 2

# AWS 배포 자동화

### WAS를 Docker image로 빌드하여 컨테이너화 (Docker, Yaml,AWS, 지속적통합)

- was를 도커 이미지로 빌드하여 컨테이너 화 합니다.
- 빌드한 이미지를 레지스트리로 푸시 합니다.
- 깃헙 액션을 통해서 레지스트리 푸시를 자동화 합니다.

### 컨테이너화 한 이미지를 AWS에 배포(Docker, AWS)

- was 및 mongoDB 이미지를 AWS ECS를 통해 배포합니다.

### AWS 배포 자동화(AWS, 배포자동화)

- WAS의 이미지 배포 자동화를 구현합니다.
- 프론트엔드의 배포 자동화를 구현합니다.

### CDN을 통한 캐싱 및 HTTPS 적용(네트워크)

- CDN을 통해 프론트엔드를 캐싱하고, HTTPS를 적용해야 합니다.
- 프론트엔드와 WAS를 연결

---

## project 1

# LMS(학습 관리 시스템)

학생들이 강의를 확인, 수강신청하고 교수들이 새로운 강의를 개설하는 앱 기능구현만 해보았습니다.

---

## 아키텍처

- crud, postgresql 구축

## 결과

- 사용자는 모든 수업을 조회할 수 있다
- 사용자는 특정 분류의 수업을 조회할 수 있다(예: 강의자/ 수업명 / 수업코드 등)
- 사용자는 수업을 수강신청 할 수 있다
- 사용자는 모든 수강중인 수업을 조회할 수 있다
- 사용자는 이메일 정보와 같은 개인정보를 변경할 수 있다
- 사용자의 타입이 강의자일 경우 새로운 수업을 생성할 수 있다
- 사용자는 수업에 대한 수강신청을 취소 할 수 있다

https://camo.githubusercontent.com/e7502784dfbfa413b8ca266389476e26bb59f9f6ce33c405c3c2dec95f004971/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f466173746966792d626c75653f7374796c653d726f756e642d737175617265266c6f676f3d66617374696679266c6f676f436f6c6f723d7768697465266c6f676f5376673d31

https://camo.githubusercontent.com/2992a057b702bfb21a8b032a109eef862c6d829ed599f8277bedded9349bd787/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f4e67696e782d677265656e3f7374796c653d726f756e642d737175617265666f722d7468652d6261646765266c6f676f3d6e67696e78266c6f676f436f6c6f723d7768697465266c6f676f5376673d31

https://camo.githubusercontent.com/8c09fad0353da918b1a39c84e935778211046047cb41060f6639624ddafc6baa/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f506f737467726553514c2d6f72616e67653f7374796c653d726f756e642d737175617265666f722d7468652d6261646765266c6f676f3d706f737467726573716c266c6f676f436f6c6f723d7768697465266c6f676f5376673d31

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/55c42073-689e-4fae-9e29-957092b28a27/Untitled.jpeg)

# ERD

!https://user-images.githubusercontent.com/126463472/230093915-9da9d9ea-6323-49e1-934f-e571d68a5f54.png

---

## 핵심기능

---

## Career / Experience

### 영상 프리랜서(촬영) **⎥2020.03 - 2023.01**

- 드라마MV광고

---

## ✅ Skills

### Languages

---

### Backend

---

### DevOps

---

### Tool

- JavaScript

- Nodejs, Express

- Postgresql, MySQL, MongoDB
- AWS : EC2, Lambda, RDS, Route53, CloudFront,  
  EventBridge, ECR, ECS, EKS

                  LoadBalancer, S3, Cloud Watch, Cognito, VPC

- Nginx, fastify
- Docker, Docker-compose
- Linux, Ubuntu
- Git Action,GitHub
- Terraform
- Grafana
- Prometheus
- k8s
- Visual Studio Code

### **코드스테이츠 (Codestates)** ⎥ **2023.03 - 2023.07**

**DevOps Bootcamp**

- CI/CD 파이프라인, Linux, Git, GitHub 등 학습
- AWS(Lambda,RDS 등), Docker, Kubernetes 등 실습
- 프로젝트 4회 진행

- 프로젝트를 진행하다 이슈를 마주치게 됐을 때 포기하지 않고 트러블 슈팅을 해서 해결한 경험이 있습니다. 하지만 실무에선 일정이 촉박해서 시간이 없을때 까지 혼자 트러블 슈팅을 한다면 일정에 차질이 생길수도 있다.  
  이럴때 모르는것을 부끄러워서 숨기지 않고 솔직한 커뮤니케이션을 할 자신이 있다.

### 직무에 대한 이해도

- 데브옵스 직무에 대해 공부하고 있고 지속적 통합, 배포 자동화에 대한 공부와 실제로 구현해보았습니다. 실무에서 다시 배워야 겠지만 배웠던것을 바탕으로 더욱 빠르게 회사에 적응을 할 수 있습니다.

  깊게 공부하는것은 어려운 일이지만 데브옵스 특성상 프론트와 백엔드를 아울러 넓게 지식을 배운다는것이 재밌는 것 같습니다.

  ### 데브옵스 주니어로 입사한 후, 저의 주요한 포부는 다음과 같습니다.
  1. 학습과 지식 확장: 데브옵스 분야는 빠르게 진화하고 변화하는 분야입니다. 저는 지속적으로 새로운 기술과 도구에 대해 학습하고, 업계의 최신 동향을 따라가기 위해 노력할 것입니다. 온라인 코스, 도서, 블로그, 컨퍼런스 등 다양한 학습 자료를 활용하여 기술적으로 성장하고 전문성을 향상시킬 것입니다.
  2. 다양한 프로젝트 경험 쌓기: 입사 후, 다양한 프로젝트에 참여하여 실전 경험을 쌓을 것입니다. 이를 통해 데브옵스 파이프라인의 구축, 자동화 및 배포 프로세스의 개선, 모니터링 및 로깅 시스템의 구축 등 다양한 영역에서 능력을 향상시킬 것입니다. 또한, 다른 팀원들과의 협업을 통해 문제 해결 및 팀워크 능력을 향상시킬 것입니다.
  3. 품질 및 안정성 확보: 제가 담당하는 시스템이 안정적으로 운영되고 높은 품질을 유지할 수 있도록 노력할 것입니다. 지속적인 통합, 지속적인 배포, 자동화된 테스트, 모니터링 등의 기술과 절차를 적용하여 시스템의 안정성과 성능을 개선하고, 사용자 경험을 향상시킬 것입니다.
  4. 커뮤니케이션 및 협업 능력 강화: 효과적인 커뮤니케이션과 팀원들과의 원활한 협업은 데브옵스 역할에서 매우 중요합니다. 저는 적극적으로 의사 소통을 하며 피드백을 주고받고, 문제를 해결하기 위해 다른 팀원들과 협력할 것입니다. 효율적인 커뮤니케이션 스킬과 리더십 능력을 향상시키는데 초점을 둘 것입니다.
  5. 자동화 및 개선: 데브옵스는 프로세스 자동화와 지속적인 개선에 초점을 둡니다. 저는 반복적하고 수동적인 작업을 자동화하고, 프로세스를 지속적으로 개선하는데 주력할 것입니다. 스크립트 작성, 인프라스트럭처 자동화, 코드 자동화 등을 통해 생산성을 향상시키고 시간을 절약할 수 있는 방안을 모색하겠습니다.
  6. 팀원들의 성장과 지원: 데브옵스 역할은 팀의 협업과 조화를 중요시합니다. 저는 팀원들의 성장을 지원하고, 지식 공유와 기술 멘토링을 통해 팀 전체의 역량 향상에 기여할 것입니다. 팀원들이 동기부여를 유지하고 개인적인 성장을 이룰 수 있도록 지원할 것입니다.
  7. 산출물 및 성과 문서화: 프로젝트에서의 경험과 성과를 문서화하여 산출물을 준비하고, 이를 포트폴리오나 블로그 등을 통해 공유할 것입니다. 이를 통해 제 업적을 명확히 보여주고, 데브옵스 역량을 증명할 수 있도록 할 것입니다.

  위의 포부를 실천하여, 데브옵스 주니어로서 성장하고 팀과 조직에 가치를 제공하는 역할을 수행하겠습니다.

---
