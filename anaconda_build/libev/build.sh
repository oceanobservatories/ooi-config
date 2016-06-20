VER=4.22
EXPECTED=bf0007e37240103d3c2be80ca9bee3f9
DIRNAME=libev-${VER}
FNAME=${DIRNAME}.tar.gz
URL=http://dist.schmorp.de/libev/Attic/${FNAME}

python -c "import urllib; urllib.urlretrieve('${URL}', '${FNAME}')"
MD5=$(python -c "import hashlib; h=hashlib.md5(); f=open('${FNAME}'); [h.update(x) for x in f]; print h.hexdigest()")

#MD5=$(md5sum ${FNAME} | awk '{print $1}')

if [ ${MD5} = ${EXPECTED} ]
then
  tar xvf ${FNAME}
  cd ${DIRNAME}
  ./configure --prefix="${PREFIX}"
  make
  make install
else
  echo "MD5 mismatch ${MD5} ${EXPECTED}"
  exit 1
fi
