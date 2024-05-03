#!/bin/bash

source ./common.sh

Check_RootUser 

read -r -p "Enter You MySQL Password: " mySql_root_password

dnf module disable nodejs:18 -y &>>$LOGFILE
VALIDATE $? "Nodejs 18 version Disabled"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "NodeJs 20 version enabled"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "NodeJs Installation"

id expense &>>$LOGFILE
if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILE
    VALIDATE $? "Useradded expense"
else
    echo -e "Already that Username exists...$Y SKIPPING $N"
fi

mkdir -p /app >>$LOGFILE
VALIDATE $? "Creating a $Y app $N Directory "

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading Backend code"

cd /app
rm -rf /app/*
unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Extracted backend code"

npm install &>>$LOGFILE
VALIDATE $? "Installing npm packages"

cp /home/ec2-user/shell-script-common/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "Copied backend service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "daemon-reload"

systemctl start backend &>>$LOGFILE
VALIDATE $? "Starting backend"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "Enabling backend"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "MySQL client installlation"

mysql -h db.praveen.store -uroot -p${mySql_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Schema Loading"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "Restarting Backend"


