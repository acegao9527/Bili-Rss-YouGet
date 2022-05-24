#!/bin/sh
#每两秒检测
step=2
for (( i = 0; i < 60; i=(i+step) )); do
#记录进程输出（文件位置自行修改）
ps -f -C you-get > /root/bili/check.txt
#获取视频标题（从上一个脚本存储位置获取，注意）
title=$(cat /root/bili/title.txt)
#根据条件判断进程状态（第二个判断条件是存储视频文件夹的文件名，自行修改）
content=$(cat /root/bili/check.txt)
result=$(echo $content | grep "you-get" | grep "Bilibili")
if [ "$result" != "" ];then
   #自动下载中，标记（文件位置自行修改）
   echo y > /root/bili/check1.txt
else
   #下载完成
   check1=$(cat /root/bili/check1.txt)
   if [ "$check1" = "y" ];then
        #检查文件是否下载完成
        mp4check=$(find /var/www/webdav/Bilibili/"$title" -name "*.download")
        if [ "$mp4check" = "" ];then
        #获取封面图文件名
        content1=$(wget https://rsshub.app/bilibili/fav/10385631/928435831/0 -q -O -)
        subcontent=${content1#*<img src=\"}
        photolink=${subcontent%%\"*}
        pname=${photolink#*archive/}
        #重命名封面图（封面图位置和上一个脚本位置一致）
        result1=$(echo $pname | grep "jpg")
        if [ "$result1" != "" ];then
               mv /var/www/webdav/Bilibili/"$title"/$pname /var/www/webdav/Bilibili/"$title"/poster.jpg
             else
               mv /var/www/webdav/Bilibili/"$title"/$pname /var/www/webdav/Bilibili/"$title"/poster.png
          fi
          #xml转ass（同样是上一个脚本的存储位置）
          filename=$(find /var/www/webdav/Bilibili/"$title" -name "*.xml")
          /usr/bin/python3 /root/bili/danmaku2ass.py /var/www/webdav/Bilibili/"$title"/"$fullfilen"
          echo n > /root/bili/check1.txt
          #获取下载完的视频文件大小
          videoname=$(find /var/www/webdav/Bilibili/"$title" -name "*.mp4")
          videostat=$(du -h "$videoname")
          videosize=${videostat%%\/*}
          #发送下载完成邮件（自行修改邮件地址）
          echo "$title<br>Size: $videosize" | mail -s "$(echo -e "=?UTF-8?B?$(echo -n '下载完成' | base64)?=\nContent-Type:text/html;charset=UTF-8")" 1379771811@qq.com
          #上传至onedrive（自行修改文件位置）
          /usr/bin/rclone copy /var/www/webdav/Bilibili OneDrive:Bilibili
      fi
    fi
fi
sleep $step
done
exit 0