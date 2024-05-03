#!/bin/bash


source ./common.sh

Check_RootUser

read -r -p "Enter You MySQL Password: " MySqlPassword


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