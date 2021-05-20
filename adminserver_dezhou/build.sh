#!/bin/bash

# rm -rf ./out
luajit=/usr/local/openresty/luajit/bin/luajit
if [ ! -d /usr/local/openresty/luajit/ ]; then
    #statements
    # echo "not exist"
    luajit=/usr/local/opt/openresty/luajit/bin/luajit
fi

rm -rf ./adminserver
mkdir -p ./adminserver
mkdir ./adminserver/logs
mkdir ./adminserver/conf
cp ./conf/* ./adminserver/conf/

function compile() {
    for file in $1
    do
        echo $file
        filepath=`dirname $file`
        subpath=${filepath:2}
        filename=`basename $file`

        echo $filepath
        echo $subpath
        echo $filename

        if [ ! -d ../adminserver/$subpath/ ]; then
            #statements
            # echo "not exist"
            mkdir -p ./adminserver/$subpath/
        fi
        if test -f $file
        then
            $luajit -b $file ./adminserver/$subpath/$filename
        fi
    done
}

function copy() {
    for file in $1
    do
        echo $file
        filepath=`dirname $file`
        subpath=${filepath:2}
        filename=`basename $file`

        echo $filepath
        echo $subpath
        echo $filename

        if [ ! -d ../adminserver/$subpath/ ]; then
            #statements
            # echo "not exist"
            mkdir -p ./adminserver/$subpath/
        fi
        if test -f $file
        then
            # $luajit -b $file ./adminserver/$subpath/$filename
            cp $file ./adminserver/$subpath/$filename
        fi
    done
}

copy "./logic/*.lua"
compile "./libs/*.lua"
copy "./script/*.lua"
copy "./script/wxpay/*.lua"

if [ ! -d ./out ]; then
    #statements
    # echo "not exist"
    mkdir -p ./out
fi

a=$1
# echo $a
tar -czvf ./out/$a.tar.gz ./adminserver 
rm -rf adminserver






