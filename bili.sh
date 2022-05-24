#!/bin/sh
you=/usr/local/bin/you-get
#RSS地址自行修改
content=$(wget https://rsshub.app/bilibili/fav/10385631/928435831/0 -q -O -)
#获得时间戳
subpubdate=${content#*<pubDate>}
pubdate=${subpubdate%%</pubDate>*}
#获得封面图下载链接
subcontent=${content#*<img src=\"}
photolink=${subcontent%%\"*}
#如果时间戳记录文本不存在则创建（此处文件地址自行修改）
if [ ! -f "/root/bili/date.txt" ];then
        echo 313340 > /root/bili/date.txt
    fi
    
#获得上一个视频的时间戳（文件地址自行修改）
olddate=$(cat /root/bili/date.txt)
#获得视频下载链接
sublink=${subpubdate#*<link>}
link=${sublink%%</link>*}
av=${link#*video/}
#获得视频标题并记录（文件地址自行修改）
content1=$(wget https://rsshub.app/bilibili/video/reply/$av -q -O -)
subname=${content1#*\[CDATA\[}
name=${subname%% 的 评*}
echo $name > /root/bili/title.txt
    
#此处为视频存储位置，自行修改
filename="/var/www/webdav/Bilibili/"$name""
#判断当前时间戳和上次记录是否相同，不同则代表收藏列表更新
if [ $pubdate != $olddate ];
    then
#判断文件是否存在（防止删除收藏导致的重复下载）
    if [ -d $filename ];then
       echo $pubdate > /root/bili/date.txt
    else
        #下载封面图（图片存储位置应和视频一致）
        nohup wget -P /var/www/webdav/Bilibili/"$name" $photolink &
        #记录时间戳
        echo $pubdate > /root/bili/date.txt
        #获取视频清晰度以及大小信息
        stat=$($you -i -c /root/cookies.txt $link)
        substat=${stat#*quality:}
        data=${substat%%#*}
        quality=${data%%size*}
        size=${data#*size:}
        #发送开始下载邮件（自行修改邮件地址）
        echo "$name<br>Quality: $quality<br>Size: $size" | mail -s "$(echo -e "=?UTF-8?B?$(echo -n '开始下载' | base64)?=\nContent-Type:text/html;charset=UTF-8")" 1379771811@qq.com
        #下载视频到指定位置（视频存储位置自行修改；you-get下载B站经常会出错，所以添加了出错重试代码）
        while true
        do
        $you -k -l -c /root/cookies.txt -o /var/www/webdav/Bilibili/"$name" $link
            if [ $? -eq 0 ]; then
                break;
            else
            sleep 2
              fi
           done
     fi
fi