#!/bin/bash

source ./common.sh

Check_RootUser

dnf install nginx -y &>>LOGFILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>LOGFILE
VALIDATE $? "Enabling nginx"

systemctl start nginx &>>LOGFILE
VALIDATE $? "Start nginx"

rm -rf /usr/share/nginx/html/* &>>LOGFILE
VALIDATE $? "Removing Default HTML Files"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html/ &>>LOGFILE
unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "Extracting frontend code"

cp /home/ec2-user/shell-script-common/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE
VALIDATE $? "Copied expense conf"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "Restarting nginx"