# locust-on-k8s

Locust를 Kubernetes 환경에서 사용하는 방법을 테스트 합니다. 

## 요구사항

* Kubernetes 클러스터
* Git으로 관리하는 Locust 테스트 파일 (저장소 최상단 폴더에 `locustfile.py` 파일로 저장해야 함)
* kubectl, helm이 설치되어 있어야 함

## 스크립트를 만들고 테스트하기

Locustfile을 만드는 방법은, [Writing a locustfile](https://docs.locust.io/en/latest/writing-a-locustfile.html) 문서를 참고하시기 바랍니다. 

S3 버킷을 만들고, Locustfile을 복사해 보겠습니다. 

```shell script
aws s3 mb s3://(Bucket Name)
aws s3 cp ./(Locust file name) s3://(Bucket Name)
```

Docker 이미지를 만드려면 다음과 같이 수행합니다. 

```shell script
cd docker_image
docker build -t locust-on-k8s:git_sync .
docker tag locust-on-k8s hahafree12/locust-on-k8s:git_sync
docker push hahafree12/locust-on-k8s:git_sync
```

로컬에서는 다음과 같이 테스트 할 수 있습니다. 

```shell script
docker run -d -p 8089:8089 locust-on-k8s
```
## Helm Chart로 올리기

```shell script
helm install --set git_sync.repo=(Git repo 주소) --set git_sync.branch=(Git repo의 target branch)\
    --set git_username=(git 서버 사용자명) --set git_password=(git 서버 비밀번호) \
    (your release name) .
```

올린 후에는 master 서비스에 Port forwarding을 적용하면 웹에서 접속 가능합니다.

## Worker 개수 조정하기

values.yaml 파일을 수정합니다. (기본값은 2입니다.) 

```yaml
worker_replicas: 4
```

그리고 Helm Chart를 업그레이드 해 줍니다.

```shell script
helm upgrade --set git_sync.repo=(Git repo 주소) --set git_sync.branch=(Git repo의 target branch)\
    --set git_username=(git 서버 사용자명) --set git_password=(git 서버 비밀번호) \
    (your release name) .
```

## Helm Chart 삭제하기

```shell script
helm uninstall (your release name)
```
