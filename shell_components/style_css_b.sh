#!/bin/bash
date=`date`

#functions
create_style_css() {
    echo "
.no-record-found {
    width: 97%;
    height: 40px;
    background-color: #f2f1f2;
    padding: 20px;
    text-align: center;
    font-size: 36px;
    color: darkred;
    display: flex;
    flex-direction: column;
    justify-content: center;
    font-family: cursive;
}
    "
}
directory=$1
(umask 077 ; touch "${directory}/style.css")
(create_style_css > "${directory}/style.css")