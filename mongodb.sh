#!/bin/bash

START_TIME=$(date +%s)

# variables
RED="\e[31m"
GREEN="\e[32m"
BLUE="\e[33m"
YEL="\e[34m"
RESET="\e[0m"

ROOT_ID=$(id -u)   #to find ID

LOGS_FOLDER="/var/logs/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

echo -e "$YELLOW $LOG_FILE $RESET"

mkdir -p $LOGS_FOLDER

echo -e "$BLUE Script started and executing at: $(date) $RESET" | tee -a $LOG_FILE

if [ $ROOT_ID -ne 0 ]
then
    echo -e "$RED ERROR:: run the script with root access $RESET" | tee -a $LOG_FILE
else
    echo -e "$GREEN Script is running... no issues $RESET" | tee -a $LOG_FILE
fi

VALIDATE () {
    if [ $1 -eq 0 ]
    then
        echo -e "$2... is $GREEN success $RESET" | tee -a $LOG_FILE
    else
        echo -e "$2... is $RED failure $RESET" | tee -a $LOG_FILE
    fi
}


cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
VALIDATE $? "Copying MONGODB repo"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "installing mongdb"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "enable mongodb"

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "Start MONGODB"

sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf &>>$LOG_FILE
VALIDATE $? "Editing mongoDB file for Remote connection"

systemctl restart mongod
VALIDATE $? "Restart MONGODB"

END_TIME=$(date +%s)

TOTAL_TIME=$(( $END_TIME-$START_TIME ))
echo "Time taken to complete the script $TOTAL_TIME" | tee -a &>>LOG_FILE