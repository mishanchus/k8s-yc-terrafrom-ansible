# k8s-yc-terrafrom-ansible
Развертываем кластер Kubernetes в Yandex Cloud с 1 master и 2 worker нодами.  

В корень проекта необходимо добавить открытый и закрытый ключи, назвать их id_rsa.pub и id_rsa.  
Также надо заполнить vars.tf своими значениями.   
После выполнения terraform скриптов создастся 3 ВМ в облаке Yandex Cloud.  

terraform init  
terrafrom plan  
terraform apply  

После выполнения ansible playbook на ранее созданных машинах развернется кластер Kubernetes. Файл Inventory уже автоматически сгенерирован после предыдущего шага.   

ansible-playbook playbook -i inventory  
