aws 에는 iam 이라는 rabac 기반 접근관리 서비스가 있습니다. role역할을통해서 리소스와 리소스간 접근관리도 할 수 있고, user에게 적절한 접근정책을줘서유저의접근관리도 할 수 있습니다.
일반적으로 ec2에 iam role의 권한으로 s3나 secretmanager와 같은 리소스에 접근할 수 있도록 사용 할 수있다.
eks cluster안에서 동작하는 kubernetes pod에는 어떻게 iam role을 줄 수 있을까?
eks cluster 내부에서 pod에게 iam role권한을 주는 방식 irsa
EKS Cluster 내부 Pod에 리소스 접근 권한을 주는 방법은?
EKS Cluster 내부 pod에 리소스 접근을 주는 방법에는 크게 3가지가 있습니다.

첫번재는, EKS Cluster Node인 EC2에 IAM Role을 할당하여 Pod가 Node의 IAM Role을 자동으로 가져갈 수 있게 할 수 있습니다. 단, EC2 내부에 IMDSv1 방식을 사용할 수 있도록 허용이 되어있어야 합니다.
(IMDS관련해서 다음 포스팅을 참고 바랍니다. https://kim-dragon.tistory.com/271 )

두번째는, IAM User의 Accesskey를 pod에서 사용하는 AWS SDK나 AWS CLI에 설정하는 방법입니다. 이 방법은 보안상 매우 취약하며 보안 정책상 Accesskey를 주기적으로 변경해야할 수 있기 때문에 관리도 매우 어렵습니다. 따라서 추천해드리지 않습니다.
마지막이 오늘 주인공 IRSA를 사용하는 방법 입니다. IRSA에 대해서는 아래에 이어서 계속 설명드리겠습니다.
IRSA란?
IRSA는 IAM Role for Service Account의 약자 입니다. 풀네임에서 볼 수 있듯이 kubernetes의 serviceaccount를 사용하여 pod의 권한을 IAM Role로 제어할 수 있도록 하는 기능을 말합니다.

serviceaccount는 AWS의 자원이 아닌데 어떻게 IAM Role을 할당할 수 있는 걸까요? 이걸 해주는게 바로 OIDC라고 부르는 OpenID Connect 입니다.

serviceaccount란?
우선 더 살펴보기전에 위에서 말씀드린 serviceaccount에 대해서 알아보도록 하겠습니다. 서비스 어카운트(Service Account) 는 Kubernetes 의 파드에서 API 서버에 요청을 보냈을 때 이 "파드"를 식별하기 위한 리리소스 입니다.

파드에서 API 서버에 요청을 보내면 이 파드의 정체가 무엇인지 알아야 어떤 권한을 가지고 있는지도 알 수 있고,

이를 기반으로 파드의 요청이 권한에 맞는지를 확인하여 요청을 처리해줄지 말지를 결정할 수 있게 되는데요. 실제로 권한을 정의하고, 설정하는 부분은 Role, ClusterRole, RoleBinding, ClusterRoleBinding의 역할이고, ServiceAccount 는 이러한 권한을 적용할 수 있는 주체 중 한가지로서, Pod에게는 신분증과 같은 인증서역할을 하게 됩니다.

OIDC란?
위에서 셜명 드린 OIDCD는 무엇일까요? OpenID Connect는 Google 등의 IdP(ID 공급자)에 로그인할 수 있도록 지원하는 표준 인증 프로토콜 입니다. 권한허가 프로토콜인 OAuth 2.0 기술을 이용하여 만들어진 인증 레이어로 JSON 포맷을 이용하여 RESTful API 형식을 사용하여 인증을 하게 됩니다. OIDC를 사용하면 손쉽게 외부 서비스를 통해 사용자 인증을 구현할 수 있게 됩니다.

즉, Kunernetes의 리소스와 AWS리소스 처럼 서로다른 리소스간의 인증을이 OIDC를 사용하여 손쉽게(?)할 수 있게 됩니다.

IRSA의 workflow
