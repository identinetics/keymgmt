#!/usr/bin/env bash

main() {
    get_commandline_opts $@
    mount_ramdisk
    set_openssl_config
    create_keypair_and_certificate
}


get_commandline_opts() {
    basicConstraintsCA='FALSE'
    keysize=2048
    x509subject='/C=AT/ST=Wien/L=Wien/O=Testfirma/OU=IT/CN=localhost'
    keyname='signer'
    while getopts ":ck:n:s:v" opt; do
      case $opt in
        c) basicConstraintsCA='TRUE';;
        k) keysize=$OPTARG
           re='^[0-9]{3,5}$'
           if ! [[ $OPTARG =~ $re ]] ; then
              echo "error: -k argument is not a number in the range from 1024 .. 16384" >&2; exit 1
           fi;;
        n) keyname=$OPTARG;;
        v) verbose="True";;
        s) x509subject=$OPTARG;;
        :) echo "Option -$OPTARG requires an argument"; exit 1;;
        *) usage; exit 0;;
      esac
    done
    #shift $((OPTIND-1))
}


usage() {
    cat << EOF
        usage: $0 [-k <NNNN>] [-n <key name>] [-v] [-s <X509 subject>]
          -c  Use certificate as CA (basicConstraints:CA=TRUE)
          -h  print this help text
          -k  keysize (default: $keysize)
          -n  file name of key and certificate (default: $keyname)
          -v  print command
          -s  x509 subject DN (default: $x509subject)
EOF
}


mount_ramdisk() {
    mkdir -p /ramdisk
    mount -t tmpfs -o size=10M tmpfs /ramdisk
    cd /ramdisk
    [ $PWD != '/ramdisk' ] && echo "could not make or mount /ramdisk" && exit 1

}


set_openssl_config() {
    cat > /tmp/openssl.cfg <<EOT
[req]
distinguished_name=dn
[ dn ]
[ ext ]
basicConstraints=CA:$basicConstraintsCA
EOT

}


create_keypair_and_certificate() {
    cmd1="openssl req
        -config /tmp/openssl.cfg
        -x509 -newkey rsa:${keysize}
        -keyout /ramdisk/${keyname}_key_pkcs8.pem
        -out /ramdisk/${keyname}_crt.pem
        -sha256 -days 3650 -nodes
        -batch -subj \"$x509subject\"
    "
    cmd2="openssl x509 -inform PEM -in /ramdisk/${keyname}_crt.pem -outform DER -out /ramdisk/${keyname}_crt.der"
    cmd3="openssl rsa -in /ramdisk/${keyname}_key_pkcs8.pem -out /ramdisk/${keyname}_key_pkcs1.pem"
    cmd4="openssl pkcs12 -export -out /ramdisk/${keyname}_crt.p12 -in /ramdisk/${keyname}_crt.pem -inkey /ramdisk/${keyname}_key_pkcs1.pem"

    if [ "$verbose" == "True" ]; then
        echo $cmd1
        echo $cmd2
        echo $cmd3
        echo $cmd4
    fi

    echo $cmd1 > /tmp/$0.tmp   # indirect execution as workaround against "invalid subject not beginning with '/'"
    bash /tmp/$0.tmp
    $cmd2
    $cmd3
    echo "create PKCS#12 certificate file including private key"
    $cmd4
    # provide the old pkcs1 private key format in addition to pkcs8
    chmod 600 /ramdisk/${keyname}_key_*.pem /ramdisk/${keyname}_crt.p12
}


main $@