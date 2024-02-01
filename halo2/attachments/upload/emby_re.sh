#!/bin/bash

if [ $1 ]; then
	docker stop xiaoya-emby 2>/dev/null
        docker rm xiaoya-emby 2>/dev/null
	cpu_arch=$(uname -m)
	case $cpu_arch in
                "x86_64" | *"amd64"*)
                        docker pull amilys/embyserver:beta
			;;
                *)
                        echo "目前只支持amd64架构，你的架构是：$cpu_arch"
                        exit 1
                        ;;
        esac
	
	docker_exist=$(docker images |grep amilys/embyserver |grep beta)
	if [ -z "$docker_exist" ]; then
		echo "拉取镜像失败，请检查网络，或者翻墙后再试"
		exit 1
	fi

        if ! grep xiaoya.host /etc/hosts; then
                echo -e "127.0.0.1\txiaoya.host\n" >> /etc/hosts
                xiaoya_host="127.0.0.1"
        else
                xiaoya_host=$(grep xiaoya.host /etc/hosts |awk '{print $1}'|head -n1)
        fi	
	echo "重新安装Emby容器....."
	#wget -q -O /tmp/Emby.Server.Implementations.dll http://docker.xiaoya.pro/Emby.Server.Implementations.dll
	case $cpu_arch in
		"x86_64" | *"amd64"*)
			docker run -d \
			--name xiaoya-emby \
			--runtime nvidia \
			--network host \
			--add-host="xiaoya.host:$xiaoya_host" \
			--user 0:0 \
			-e LANG=C.UTF-8 \
			-e TZ=Asia/Shanghai \
			-e UID=0 \
			-e GID=0 \
			-e GIDLIST=0 \
			-v /mnt/user/appdata/emby/config:/config \
			-v /mnt/user/appdata/xiaoya-emby/xiaoya:/media \
			-v /etc/nsswitch.conf:/etc/nsswitch.conf \
			--device /dev/dri/renderD128:/dev/dri/renderD128 \
			--Variable NVIDIA_VISIBLE_DEVICES=all \
			--Variable NVIDIA_DRIVER_CAPABILITIES=all \ #显卡驱动
			--restart always \
			amilys/embyserver:beta
			#docker cp /tmp/Emby.Server.Implementations.dll emby:/system/
			#docker exec -i emby chmod 644 /system/Emby.Server.Implementations.dll
			#docker restart emby
			echo "一键全家桶全部安装完成"
			;;
		*)
			echo "目前只支持intel64和amd64架构，你的架构是：$cpu_arch"
			exit 1
			;;
	esac		
	sleep 5
	if ! curl -I -s http://$docker0:2345/ | grep -q "302"; then 
		dockername=$(docker ps |grep xiaoyaliu/alist |grep 5678|head -n1|awk '{print $NF}')
	fi       	
else
	echo "请在命令后输入 -s /媒体库目录 再重试"
	exit 1
fi

