namespace
kube-system dns kube0proxy kubernetes dashboard

namespace & resource quota yaml 구조

resource request limit
kind: resourceQuota
spec:
hard:
pods: 10
request.cpu
limit.cpu

---

k api-resources --namespace true
k api-resources --namespace false

---

pod
최소단위 쿠버네티스 객체
docker zjsxpdlsjdhksms whrmaekfmrp pod는 하나 이상ㅇ의 커테이너를 포함가능
애플리케이션 컨테이너
pod 의 디자인 패턴
nic - container-container

- sidecar
- adapter
- abmasssador
  toleration이 있는경우
  -tolerations
  nodeaffinity있는경우
  -nodeAffinity
  resource requirement가 있는경우
  resources:
  requests:
  limits:

---

replicaset
pod의레플리카를생성하고 지정한 pod수를 유지하는 리소스
기존의 replicaset controllerdptj replicaset으로 뱐경

api apps/v1
spec:
tmeplate:
metadata:
spec:
selector:
matchLabels:
Name: app

---

deployment rs상위
rs pod를 관리하는 오브젝트
롤링 업네이트

- strate
  배포전략
  recreate
  rollingupdate
  maxUnavailable 업데이트중에 동시에 정지가능한 파드수
  maxsurge 업데이트중에 생성 최대 파드수
  argocd로 배포
  blue green
  canary
  k apply -f deploy.yaml --record
  annotaions 쿠버네티스시스템에서 인식할수있는 정보

k set image deploy my-deploy nginx-container-nginx:1.23 --record
k rollout history deployment --revision something
k rollout und0 deploy --to-revision 1

---

daemonset
클러스터의 각노드에 pod를 하나씩 띄울때 사용하는 오브젝트
flueent-bit로그수집기나 모니터링용

---

service
pod집합과 같은 어플리케이션 접근 경로나 servicediscovery
kubernetes.io/proxy
svc type
clusterip
kube-proxy
nodeport nat를 이용해 클러스터 내 node의 고정된 PORT를 같즌 IP로 SErvice를 노출
와부 트래픽을 서비스에 전달하는 가장 기본적인 방법
port사용범위 30000-32767
loadbalancer
클라우드 공급자의 로드밸런서를 이용햇 Service를 외부로 노출
외부 로드밸런서를 사용하기 때문에 SPOFdp rkdrgk
l4tcp l7http 레이어를 통해 노출ㅊㅊㅊ

---

ingress
svc type은 아니지만 svc가 앞에서 Smart router or entry point 역할을 하는 오브젝트
외부에서 접근 가능한 url load balbancing ssl termination등ㅇㄹ 통해 svc에대한 http기반접근을 제공
클러스터에 하나 이상 실행중인 ingress contorller가 필요 aws lb controller nginx ingress
nodeport를 이용해 서비스를 노출하면 사용자가 30000이상의 포트를 기억하기 힘듬
일반적으로 proxyfmf enrh 80 > nodeport롤 포워딩을하는 layer를 생성\
ingress on aws
트래픽모드
ip > clusterIp
instance> nodeport
ingress yaml structur
annotatiinon
alb.ingress.kubernets.io/scheme
alb.ingress.kubernets.io/targe

---

cluster autoscaler
CA
수요에 따라 node추가
리소스부족으로 pod node 할당ㅇ이 안될때

---

hpa vpa
metric server
리소스사용량데이터를 집계하는역할
리소스메트릭을 수집
horizontal pod autoscaler
hpa의 ㅣㄱ준
cpu memory
ca의 상호작용
컨테이너로드가 증가하면 hpa는 우선 클러스터에 충분한 공간
kind: HorizontalPodAutoscaler
spec:
scaleTagetRef
apiVersion: apps/v1
kind: deployment
minreplicas: 1
maxreplicas
metrics:

- type : resource
  resource:
  name: cpu
  target:
  type: utilization
  averageUtilization: 50

서비스 적용전 pod resource rquest에 어떤 갑이 적정한지 명확하지 않을때 유용
vpa > hpa > ca

vpa yaml structur
apiVerison: autoscaling.k9s.io/v1beta2
kind: verticalpodautuscaler
spec:
targetRef:
apiVersion: "apps/v1"
kind: deployemnt
name: nginx
updatepolicy:
updatemod: auto
resourecpolicy
containerpolicies:
containername: nginx
minAllowed:
cpu: 260m
memory: 100mi
maxallowed:
cpi: 500m'
memory: 500mi

---

environmetn variable
개별컨테이너에 설정해야디ㅚ는 환경변수
pod정의파일에 환경변수를 지정하거나
cm,secret

---

cm
워크로드에 필요한 설정정보를 Ky-value로 저장할수있는 데이터
갇ㄴ단한환경변수
type structur

- data:
  key;value
  cm 전ㅌ테를 injection
- envfrom:
- configmapref:
  key:value
  configmap 일부를 injection
  env:
  -name : db-passwd
  valueFrom:
  configmapkeyref:
  name: something
  key:db-passwd

---

secret
워크로드에 필요한 민감 정보를 key-value형태롤 저장 base64인코딩상태로 저장
저장하면 자동으로 인코딩이됨
k creae nenric --save0config #generic 은 플레인값을 넣겠다는뜻
모든 정보는 ecddp wjwkdehlsek

---

volume
스토리지 ㅗㅂ류륨을 추상화하여 Poddhk smtmsgkrp rufgkqtlzla
dhqmwprxmdml gudxork dksls ㅔㅐㅇsodptj wjddml
볼름플러그임
emptydir
hostpath
nfs
iscsi
cephfs
컨테이너자신만 접근 가능한비영구적 볼륨이기 ㄷ떄문에 컨테이너가 재시작할때 유지 할 수없음
kubernetes클러스터 레벨에서 볼륨을 관리하기 어려움
volume이 변경될때마다 해당 gvolume을 사용하는 모든 pod의 설정 변경 필요
pv
추상화된 가상의 volume오브젝톨 별도로 정의 밑ㅊ 생성하여 Poddhk dusruf
pvc
pv을 ㅇㅛ청하는 오브젝트

---

kubernetes rbac
role binding access control
serviceaccount
사람이 아님 machine이 사용하는 ACcount
pod내프로세스에 IDentity를 제공
모든 namespace는 ㅇDEFautlserivce account가 있으며 기본 kubernetes api를 사용할수있는 제한된권한을 제공
role rolebinding
권한수행되는지
k create sa dev
k create role dev-role --verb
k create rolebinding --role dev-role --serviceaccount dev
k get po --as system:defaul
k auth can-i crate cm --as sysytem:serviceaccoutn:dfeualt:dev
k auth can0i create deploymen --as system:servicaaccount:defualt:dev

serviceaccount adn iadm role
irsa(iam roles for service accounts)
how to access pod to s3?
network policy
pod 내부로 들어오거나 ingress 외부로 나가는 EGRESS트래픽을허용하고 거부
기본적으로 WHItelist
cni 를 사용하는 것이 전제

---

kubectx_kubens
k config get-contexts
k config use-context <my-cluster>

---

helm
kubernetes패키지 관리자
chart라는 패키지들을 관리
Template와 values.yaml파일을 이용해 어플리케이션을 구성
가장 간단한 방법은 YAml형식으로 Manifest정의파일을 작성하여 apply라는 방법
하지만 시스템이 늘어나고 환경이늘어난다면
재사용이나BUlk작업을 위한 효율화가 필요
helm chart structur
char.yaml
values.yaml
templates/
requirement.txt

---

karpenter
aws가 개발한 오프노스 kubernetesdml workernode오토스케일러
cluster autoscaler 와 비슷한 역할을 수행하지만 , aws 리소스에 의존성이 없어 git just in time 배포가 가능 오픈소스이기 때문에 주요 클라우드 공급업체 및 온프레미스 환경을 포함
karpenter 구성
karpenter.tf
iam role
karpenter

---

ecr
amazon elastic container registry
어디서나 애플리케이셔 이미지 밑 아티팩츠 안정적으로 배포할수있는
Ecr 구성요소
레지스트리
각 aws계정마다 제공되어 하나 이상의 레포를 생서하고 이미지를 저장할수있음
repository
사용자 권한 토큰
리포지토리 정책

ecr 기능
수명주기정책 lifecycle policy
image scan 취약성 식별
교차리전밑교차계정복제
풀스루캐시규칙 프라이빗 ecr레지스트리에 원격퍼블릭 레지스트리의 리포지토리를 캐시하는 방법을 제공

ecr public gallery === docker hub
karpenter
karpenter controller
karpenter webhook
