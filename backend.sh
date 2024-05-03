#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | awk -F "." '{print $1F}')
#SCRIPT_NAME=$(echo $0 | awk -F "." '{print $1F}')
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
read -p "Please enter mySql Password: " mySql_root_password 

if [ $USERID -ne 0 ]
then
    echo -e "You are not Super User, Hence $R Execution STOPPED $N"
    exit 1
else
    echo "You are super user"
fi

VALIDATE()
{
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ...$R FAILED $N"
        exit 1
    else
        echo -e "$2 ...$G SUCCESS $N"
    fi
}

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

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service &>>$LOGFILE
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


