#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "scripted started excuted in $TIMESTAMP" &>> $LOGFILE



VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo "ERROR: $2 ...... $R FAILED $N"
        exit 1
    else
        echo "$2 ... $G SUCCESS  $N"
    fi

}

if [ $ID -ne 0 ]
then
    echo "ERROR: your are not root user"
    exit 1
else
    echo "your root user"
fi

cp mongo.repo /etc/yum.repos.d/mongo.repo  &>> $LOGFILE

VALIDATE $? "copied mongodb repo"

dnf install mongodb-org -y  &>> $LOGFILE

VALIDATE $? "install mongodb"

systemctl enable mongod   &>> $LOGFILE

VALIDATE $? "enable mongodb"

systemctl start mongod    &>> $LOGFILE

VALIDATE $? "stared mongodb"


sed -i 's/127.0.0.1 to 0.0.0.0/g' /etc/mongod.conf   &>> $LOGFILE

VALIDATE  $? "remote access to mongodb"


systemctl restart mongod   &>> $LOGFILE

VALIDATE  $?  "restarted mongodb"