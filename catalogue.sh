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

dnf module disable nodejs -y    &>> $LOGFILE

VALIDATE $? "disable nodejs"

dnf module enable nodejs:18 -y    &>> $LOGFILE

VALIDATE $? "enable nodejs"

dnf install nodejs -y      &>> $LOGFILE

VALIDATE $? "install nodejs"

id roboshop
if [ $? -ne 0 ]
then
    useradd roboshop 
    VALIDATE $? "roboshop user creation"
else
    echo "roboshop user alreay exist ... skipping"
fi     

VALIDATE $? "creating roboshop user"

mkdir -p /app   

VALIDATE $? "creating app directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip   &>> $LOGFILE

VALIDATE $? "downloading catalogue application"

cd /app 

unzip /tmp/catalogue.zip   &>> $LOGFILE

VALIDATE $? "inzip catalogue application"


npm install    &>> $LOGFILE

VALIDATE $? "npm install"

cp /home/centos/roboshop-shellscripting/catalogue.service   /etc/systemd/system/catalogue.service  &>> $LOGFILE

VALIDATE $? "copying catalogue service file"

systemctl daemon-reload  &>> $LOGFILE

VALIDATE $? "catalogue deanom reload"

systemctl enable catalogue  &>> $LOGFILE

VALIDATE $? "enable catalogue"

systemctl start catalogue  &>> $LOGFILE

VALIDATE $? "start catalogue"

cp /home/centos/roboshop-shellscripting/mongo.repo  /etc/yum.repos.d/mongo.repo  &>> $LOGFILE

VALIDATE $? "copying mongo repo"

dnf install mongodb-org-shell -y  &>> $LOGFILE

VALIDATE $? "install mongodb client"

mongo --host 172.31.32.203 </app/schema/catalogue.js

VALIDATE $? "loading catalogue data into mongodb"
