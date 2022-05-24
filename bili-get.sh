#!/bin/sh
export LC_ALL=C
you=/var/services/homes/MyAdmin/.local/bin/you-get
confdir=/volume1/docker/bili-rss-get
downloaddir=/volume3/迅雷/下载B站
myrss=http://192.168.31.3:1200/bilibili/fav/1924937/1622036037

cookiedir=$confdir/cookies.txt
datedir=$confdir/date.txt
logdir=$confdir/sys.log

content=$(wget $myrss -q -O -)

#获得时间戳
subpubdate=${content#*<pubDate>}
pubdatetemp=${subpubdate%%</pubDate>*}
pubdate=$(date -d "$pubdatetemp" "+%s")

#如果时间戳记录文本不存在则创建
if [ ! -f "$datedir" ];then
    echo 313340 > $datedir
fi

#获得上一个视频的时间戳
olddate=$(cat $datedir)
# 当最新一条的时间戳小于上条保存的时间戳，说明是以前的下载过的
if [ $pubdate -le $olddate ];then
    echo $(date '+%Y-%m-%d %H:%M:%S') "exit: already download" >> $logdir
    exit 8
else
    echo $(date '+%Y-%m-%d %H:%M:%S') "find new video, ready to download" >> $logdir    
fi

#获得视频下载链接
sublink=${subpubdate#*<link>}
link=${sublink%%</link>*}
av=${link#*video/}

#获得视频标题并记录
content1=$(wget http://192.168.31.3:1200/bilibili/video/reply/$av -q -O -)
subname=${content1#*\[CDATA\[}
name=${subname%% 的 评*}

echo "---------------------开始下载"
echo "$you -k -l -c $cookiedir -o $downloaddir $link"
$you -k -l -c $cookiedir -o $downloaddir $link
if [ $? -eq 0 ];then
    echo $pubdate > $datedir

fi
echo "---------------------下载成功"
echo $(date '+%Y-%m-%d %H:%M:%S') "success: download video $name" >> $logdir