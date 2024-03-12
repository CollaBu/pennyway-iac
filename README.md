## Pennyway iac Repository

## 📌 Architecture

### 🗂️ Directory Architecture

```plain
pennyway-iac/
├── modules/
│   ├── network/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── compute/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── terraform.tfvars
│   │   └── outputs.tf
└── configurations/
    ├── backend.tf
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
