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

## Master 올리기

먼저 환경변수 설정을 해 봅시다. `kustomization/kustomization.yaml` 파일의 값을 적절히 설정하고 다음 명령을 입력합니다.

```shell script
kubectl --kubeconfig $KUBE_CONFIG apply -k kustomization
configmap/locust-configmap-(Random Value) created
secret/aws-credentials-(Random Value) unchanged
```

master_service.yaml, worker_deployment.yaml 파일에서 다음 값을 변경해 줍니다. `(Random Value)`로 표시된 값은 앞에서 실행한 결과에 따라 바꿔줍니다.

* locust-configmap -> locust-configmap-(Random Value)
* aws-credentials -> aws-credentials-(Random Value)

그리고 master를 올려봅시다. 

```shell script
kubectl --kubeconfig $KUBE_CONFIG apply -f k8s_config/master_service.yaml
```

LoadBalancer를 생성하도록 했기 때문에, 서비스를 확인해 보면 로드 밸런서의 주소를 알 수 있습니다.

```shell script
kubectl --kubeconfig $KUBE_CONFIG get services 
NAME            TYPE           CLUSTER-IP      EXTERNAL-IP                  PORT(S)                                      AGE
kubernetes      ClusterIP      198.19.128.1    <none>                       443/TCP                                      33m
locust-master   LoadBalancer   198.19.134.43   (Address of Load Balancer)   80:32109/TCP,5057:32752/TCP,5058:30039/TCP   76s
```

웹 브라우저에서 Load Balancer의 주소로 들어가보면, Locust의 UI를 볼 수 있습니다.
## Worker 올리기

그리고 이번에는 Worker를 올려보겠습니다. 먼저 master 역할을 하는 pod의 IP를 확인합니다.

```shell script
kubectl --kubeconfig $KUBE_CONFIG get pods -o wide
NAME                             READY   STATUS    RESTARTS   AGE     IP             NODE          NOMINATED NODE   READINESS GATES
locust-master-67f6dc68bb-mmkw2   1/1     Running   0          16m     198.18.0.40    (Node Name)   <none>           <none>
```

IP 주소를 바탕으로 `kustomization_master/kustomization.yaml` 파일의 `locust_master_host` 값을 수정해 줍니다.

그리고 이를 바탕으로 ConfigMap을 생성합니다. 

```shell script
kubectl --kubeconfig $KUBE_CONFIG apply -k kustomization_master                  
configmap/locust-master-configmap-(Random Value) created
```

worker_deployment.yaml 파일에서 다음 값을 변경해 줍니다. `(Random Value)`로 표시된 값은 앞에서 실행한 결과에 따라 바꿔줍니다.

* locust-master-configmap -> locust-master-configmap-(Random Value)

이제 Worker를 deploy 해 보겠습니다. 

```shell script
kubectl --kubeconfig $KUBE_CONFIG apply -f k8s_config/worker_deployment.yaml
```

그리고 master 사이트로 들어가 보면, 우측 상단의 Workers 수가 2로 조정된 것을 볼 수 있습니다. 

## 정리하기

```shell script
kubectl --kubeconfig $KUBE_CONFIG delete -f k8s_config/worker_deployment.yaml
kubectl --kubeconfig $KUBE_CONFIG delete -f k8s_config/master_service.yaml
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
