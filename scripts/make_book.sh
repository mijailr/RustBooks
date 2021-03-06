#!/bin/bash
ORIGDIR=$(pwd)
figlet Making Book $1
git clone --depth 1 $2
for file in $(ls scripts)
do
ln -s `pwd`/scripts/$file $3/$4/$file
done
cd $3/$4
LIST=$(cat SUMMARY.md|grep -oe "[^(]*md"|sed ':a;N;$!ba;s/\n/ /g'|sed 's/ ^//')
mkdir tmp
for file in $(find . -type f)
do
mkdir -p tmp/$(dirname $file) && cp $file tmp/$file
done
mv $(echo $LIST|python3 map.py) tmp/dmp.json
cp -r img tmp/
cd tmp
sed -i "s#\.\./#https://doc.rust-lang.org/#g" $LIST
for file in $(echo $LIST)
do
  sed -E -i 's:(('$(echo $LIST|sed 's: :)|(:g'|sed 's:md:html:g')'))#:#:g' $file
  sed -E -i 's:('$(echo $LIST|sed 's: :)|(:g'|sed 's:md:html:g')'):!!REPLACE!!\0!!REPLACE!!:g' $file
  sed -E -i 's:```rust.*:```rust:g' $file
done
python3 ../prep.py
cp ../metadata.txt .
sed -E -i "s/InsertTitleHere/$1/g" metadata.txt
pandoc -o "$1.epub" metadata.txt $(echo $LIST)
cp "$1.epub" $ORIGDIR/Books
cd $ORIGDIR
rm -rf $3
