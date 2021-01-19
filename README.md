# locust-on-k8s

Locust를 Kubernetes 환경에서 사용하는 방법을 테스트 합니다. 

## 요구사항

* EKS 또는 Kubernetes를 사용할 수 있는 환경
* S3 또는 S3와 호환되는 Object Storage

## EKS 클러스터 생성하기



## 스크립트를 만들고, 필요한 설정 수행하기

Locustfile을 만드는 방법은, [Writing a locustfile](https://docs.locust.io/en/latest/writing-a-locustfile.html) 문서를 참고하시기 바랍니다. 

S3 버킷을 만들고, Locustfile을 복사해 보겠습니다. 

```shell script
aws s3 mb s3://(Bucket Name)
aws s3 cp ./(Locust file name) s3://(Bucket Name)
```

Docker 이미지를 만드려면 다음과 같이 수행합니다. 

```shell script
cd docker_image
docker build -t goni-locust-test .
```

로컬에서는 다음과 같이 테스트 할 수 있습니다. 

```shell script
docker run -d -p 8089:8089 -e AWS_ACCESS_KEY_ID=(AWS Access Key) \
         -e AWS_SECRET_ACCESS_KEY=(AWS Secret Access Key) \
         -e S3_BUCKET=(Bucket Name) -e S3_KEY=(Locust file name) goni-locust-test
```

## Master 올리기


## Worker 올리기



## 테스트 하기

