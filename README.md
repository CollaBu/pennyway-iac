## Pennyway iac Repository

## 📌 Architecture

### ☁️ Cloud Architecture

![image](https://gist.github.com/assets/68031450/da034019-5cbd-4f1a-b3ae-6baaeb0b771a)

### 🗂️ Directory Architecture

```plain
pennyway-iac/
├── modules/
│   ├── network/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── compute/
│       ├── bastion
│       │   ├── main.tf
│       │   └── variables.tf
│       └── was
│           ├── main.tf
│           └── variables.tf
├── main.tf
├── terraform.tfvars
└── configurations/
    └── provider.tf
```

- `Modules Directory`
  - 재사용 가능한 Terraform 코드 블록을 모듈로 분리하여 관리
  - 각 모듈은 특정 인프라 구성 요소(예: 네트워크, 컴퓨팅 리소스)를 정의
- `Environments Directory`
  - 개발(dev), 스테이징(staging), 프로덕션(production)과 같은 다양한 환경을 구분하여 관리
  - 각 환경은 독립적인 구성을 가지며, 필요에 따라 변수값을 달리하여 리소스를 분리함
- `Configurations Directory`
  - Terraform 초기화 및 실행에 필요한 설정 파일을 보관
  - 백엔드 설정, 프로바이더 설정 등을 포함할 수 있습니다.

## Setting

### terraform.trvars

```plain
access_key = ""
secret_key = ""
cidr_block = ""
remote_ip = ""
keypair = ""
```

- `access_key`: AWS 계정의 액세스 키 ID
- `secret_key`: AWS 계정의 시크릿 액세스 키 ID
- `cidr_block`: Private Network 환경을 구축하기 위해 사용되는 IP 주소 범위
- `remote_ip`: bastion 서버에 접속하기 위해 사용되는 IP 주소
- `keypair`: AWS EC2 인스턴스에 SSH 접속을 위해 사용되는 키 쌍
