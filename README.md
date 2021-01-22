# locust-on-k8s

Locust를 Kubernetes 환경에서 사용하는 방법을 테스트 합니다. 

## 요구사항

* Kubernetes 클러스터
* S3 또는 S3와 호환되는 Object Storage
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
docker build -t locust-on-k8s .
docker tag locust-on-k8s hahafree12/locust-on-k8s
docker push hahafree12/locust-on-k8s
```

로컬에서는 다음과 같이 테스트 할 수 있습니다. 

```shell script
docker run -d -p 8089:8089 -e AWS_ACCESS_KEY_ID=(AWS Access Key) \
         -e AWS_SECRET_ACCESS_KEY=(AWS Secret Access Key) \
         -e S3_BUCKET=(Bucket Name) -e S3_KEY=(Locust file name) locust-on-k8s
```
## Helm Chart로 올리기

```shell script
helm install --set aws_access_key_id=(Base64 encoded AWS access key) \
--set aws_secret_access_key=(Base64 encoded AWS secret access key) \
--set s3_bucket_name=(S3 Bucket Name) \
--set s3_object_key=(S3 Object Key) \
--set aws_default_region=(AWS Region Name: e.g. - ap-northeast-2)
(your release name) .
```

## Worker 개수 조정하기

values.yaml 파일을 수정합니다. (기본값은 2입니다.) 

```yaml
worker_replicas: 4
```

그리고 Helm Chart를 업그레이드 해 줍니다.

```shell script
helm upgrade --set aws_access_key_id=(Base64 encoded AWS access key) \
--set aws_secret_access_key=(Base64 encoded AWS secret access key) \
--set s3_bucket_name=(S3 Bucket Name) \
--set s3_object_key=(S3 Object Key) \
--set aws_default_region=(AWS Region Name: e.g. - ap-northeast-2)
(your release name) .
```

## Helm Chart 삭제하기

```shell script
helm uninstall (your release name)
```
