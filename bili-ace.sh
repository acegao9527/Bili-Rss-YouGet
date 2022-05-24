#!/bin/sh
you=/var/services/homes/MyAdmin/.local/bin/you-get
confdir=/var/services/homes/MyAdmin/workconfig/bili-conf
downloaddir=/volume3/迅雷/下载B站
myrss=http://192.168.31.3:1200/bilibili/fav/1924937/1622036037
cookiedir=$confdir/cookies.txt

content=$(wget $myrss -q -O -)

#获得时间戳
subpubdate=${content#*<pubDate>}
pubdate=${subpubdate%%</pubDate>*}

#如果时间戳记录文本不存在则创建
if [ ! -f "$confdir/date.txt" ];then
    echo 313340 > $confdir/date.txt
fi

#获得上一个视频的时间戳
olddate=$(cat $confdir/date.txt)

#判断当前时间戳和上次记录是否相同，相同则代表列表未更新
if [ "$pubdate" == "$olddate" ];then
    echo "exit:same as last time"
    exit 8
fi

#获得视频下载链接
sublink=${subpubdate#*<link>}
link=${sublink%%</link>*}

echo "---------------------开始下载"
echo "$you -k -l -c $cookiedir -o $downloaddir $link"
$you -k -l -c $cookiedir -o $downloaddir $link
if [ $? -eq 0 ];then
    echo $pubdate > $confdir/date.txt
fi
echo "---------------------下载成功"

