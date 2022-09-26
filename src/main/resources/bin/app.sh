

ENV=dev
RUNNING_USER=root
ADATE=`date +%Y%m%d%H%M%S`

#TODO 服务名
SERVER_NAME=assembly-demo

#解析参数
#Debug模式
XDEBUG=""

number=65              #定义一个退出值
index=1                    #定义一个计数器
if [ -z "$1" ];then                           #对用户输入的参数做判断，如果未输入参数则返回脚本的用法并退出，退出值65
   echo "Usage:$0 + canshu"
   exit $number
fi
echo "listing args with \$*:"                 #在屏幕输入，在$*中遍历参数
for arg in $*                                          
do
   echo "arg: $index = $arg"
   name=`echo $arg|awk -F'=' '{print $1}'`
   value=`echo $param|awk -F'=' '{print $2}'`
  if [ "$name"x = "debug"x ];then
    XDEBUG="debug"
  fi
   let index+=1
done
echo
index=1                                              #将计数器重新设置为1
echo "listing args with \"\$@\":"       #在"$@"中遍历参数
for arg in "$@"
do
   echo "arg: $index = $arg"
   let index+=1
done



APP_HOME=`pwd`

dirname $0|grep "^/" >/dev/null
if [ $? -eq 0 ];then
   APP_HOME=`dirname $0`
else
    dirname $0|grep "^\." >/dev/null
    retval=$?
    if [ $retval -eq 0 ];then
        APP_HOME=`dirname $0|sed "s#^.#$APP_HOME#"`
    else
        APP_HOME=`dirname $0|sed "s#^#$APP_HOME/#"`
    fi
fi

if [ ! -d "$APP_HOME/../logs" ];then
  mkdir $APP_HOME/../logs
fi

LOG_PATH=$APP_HOME/../logs/$SERVER_NAME.out
GC_LOG_PATH=$APP_HOME/../logs/gc-$SERVER_NAME-$ADATE.log
#JMX监控需用到
JMX="-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=1091 -Dcom.sun.management.jmxremote.ssl=false -Dcom.sun.management.jmxremote.authenticate=false"
#JVM参数
JVM_OPTS="-Dname=$SERVER_NAME -Djeesuite.configcenter.profile=$ENV -Djava.awt.headless=true -Djava.net.preferIPv4Stack=true -Duser.timezone=Asia/Shanghai -Xms512M -Xmx512M -XX:PermSize=256M -XX:MaxPermSize=512M -XX:+HeapDumpOnOutOfMemoryError -XX:NewRatio=1 -XX:SurvivorRatio=30 -XX:+UseParallelGC -XX:+UseParallelOldGC"

if [ ! -z "$XDEBUG" ];then
   JVM_OPTS="$JVM_OPTS  -Xdebug -Xrunjdwp:transport=dt_socket,address=8001,server=y,suspend=n"
fi

JAR_FILE=../lib/$SERVER_NAME.jar


APP_FILE_PATH="../lib,../resources"
APP_PATH="-Dspring.config.location=../resources/application.yml -Dloader.path=$APP_FILE_PATH"

pid=0


start(){
  checkpid
  if [ ! -n "$pid" ]; then
    #JAVA_CMD="nohup java -server -jar $JVM_OPTS $JAR_FILE > $LOG_PATH 2>&1 &"
    #su - $RUNNING_USER -c "$JAVA_CMD"
    nohup java -server $JVM_OPTS $APP_PATH -jar  $JAR_FILE > $LOG_PATH 2>&1 &
	echo "java -server $JVM_OPTS $APP_PATH -jar  $JAR_FILE > $LOG_PATH 2>&1 &"
    echo "---------------------------------"
    echo "启动完成，按CTRL+C退出日志界面即可>>>>>"
    echo "---------------------------------"
    sleep 3s
    tail -f $LOG_PATH
  else
      echo "$SERVER_NAME is runing PID: $pid"   
  fi

}


status(){
   checkpid
   if [ ! -n "$pid" ]; then
     echo "$SERVER_NAME not runing"
   else
     echo "$SERVER_NAME runing PID: $pid"
      sleep 4s
     tail -f $LOG_PATH
   fi 
}

checkpid(){
    pid=`ps -ef |grep $JAR_FILE |grep -v grep |awk '{print $2}'`
}

stop(){
    checkpid
    if [ ! -n "$pid" ]; then
     echo "$SERVER_NAME not runing"
    else
      #dump
      echo "$SERVER_NAME stop..."
      kill $pid
    fi 
}

restart(){
    stop 
    sleep 1s
    start
}
dump(){ 
    LOGS_DIR=$APP_HOME/../logs
    DUMP_DIR=$LOGS_DIR/dump
    if [ ! -d $DUMP_DIR ]; then
        mkdir $DUMP_DIR
    fi
    DUMP_DATE=`date +%Y%m%d%H%M%S`
    DATE_DIR=$DUMP_DIR/$DUMP_DATE
    if [ ! -d $DATE_DIR ]; then
        mkdir $DATE_DIR
    fi
    
    echo  "Dumping the $SERVER_NAME ...\c"
    
    PIDS=`ps -ef | grep java | grep $JAR_FILE |awk '{print $2}'`
    for PID in $PIDS ; do
        jstack $PID > $DATE_DIR/jstack-$PID.dump 2>&1
        echo -e  "PID=$PID .\c"
        jinfo $PID > $DATE_DIR/jinfo-$PID.dump 2>&1
        echo -e  ".\c"
        jstat -gcutil $PID > $DATE_DIR/jstat-gcutil-$PID.dump 2>&1
        echo -e  ".\c"
        jstat -gccapacity $PID > $DATE_DIR/jstat-gccapacity-$PID.dump 2>&1
        echo -e  ".\c"
        jmap $PID > $DATE_DIR/jmap-$PID.dump 2>&1
        echo -e  ".\c"
        jmap -heap $PID > $DATE_DIR/jmap-heap-$PID.dump 2>&1
        echo -e  ".\c"
        jmap -histo $PID > $DATE_DIR/jmap-histo-$PID.dump 2>&1
        echo -e  ".\c"
        if [ -r /usr/sbin/lsof ]; then
        /usr/sbin/lsof -p $PID > $DATE_DIR/lsof-$PID.dump
        echo -e  ".\c"
        fi
    done
    
    if [ -r /bin/netstat ]; then
    /bin/netstat -an > $DATE_DIR/netstat.dump 2>&1
    echo -e  "netstat.dump ..."
    fi
    if [ -r /usr/bin/iostat ]; then
    /usr/bin/iostat > $DATE_DIR/iostat.dump 2>&1
    echo -e  "iostat.dump ..."
    fi
    if [ -r /usr/bin/mpstat ]; then
    /usr/bin/mpstat > $DATE_DIR/mpstat.dump 2>&1
    echo -e  "mpstat.dump ..."
    fi
    if [ -r /usr/bin/vmstat ]; then
    /usr/bin/vmstat > $DATE_DIR/vmstat.dump 2>&1
    echo -e  "vmstat.dump ..."
    fi
    if [ -r /usr/bin/free ]; then
    /usr/bin/free -t > $DATE_DIR/free.dump 2>&1
    echo -e  "free.dump ..."
    fi
    if [ -r /usr/bin/sar ]; then
    /usr/bin/sar > $DATE_DIR/sar.dump 2>&1
    echo -e  ".\c"
    fi
    if [ -r /usr/bin/uptime ]; then
    /usr/bin/uptime > $DATE_DIR/uptime.dump 2>&1
    echo -e  ".\c"
    fi
    
    echo "OK!"
    echo "DUMP: $DATE_DIR"
}

case $1 in  
          start) start;;  
          stop)  stop;; 
          restart)  restart;;  
          status)  status;;   
          dump)  dump;;   
              *)  echo "require start|stop|restart|status|dump"  ;;  
esac 