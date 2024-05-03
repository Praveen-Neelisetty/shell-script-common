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
read -r -p "Enter You MySQL Password: " MySqlPassword
# echo "Enter You MySQL Password: ${MySqlPassword}"
# echo "Enter You MySQL Second Time for Verification Password: $MySqlPassword"


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

#dnf list installed mysql &>>$LOGFILE "MySQL Exists or not"
#VALIDATE $? "MySQL Exists?"

dnf install mysql-server -y &>>$LOGFILE #"MySQL install"
VALIDATE $? "MySql Installation"

systemctl start mysqld &>>$LOGFILE #"MySQL start"
VALIDATE $? "Starting MySQL Server"

systemctl enable mysqld &>>$LOGFILE #"MySql Enable"
VALIDATE $? "Enabling MySQL Server"

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
# VALIDATE $? "Setting up MySql Root Password"

mysql -h db.praveen.store -u root -p${MySqlPassword} -e 'show databases' &>>LOGFILE
echo -e "$? $Y value $N"

if [ $? -ne 0 ]
then    
    mysql_secure_installation --set-root-pass ${MySqlPassword} &>>LOGFILE
    VALIDATE $? "MySQL Password Setup Completed"
else
    echo -e "MySQL Password Setup Already $G Completed $N, Hence $Y SKIPPING $N"
   
fi

echo -e "$G Installation $N and Setting $G Root Password $N completed"