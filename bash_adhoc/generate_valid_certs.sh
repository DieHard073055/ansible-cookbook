#!/bin/bash

TARGET="localhost"

CERT_DIR=$(pwd)/certs

# create the certs directory
mkdir $CERT_DIR
# generate a private to sign
PRIVATE_KEY=$CERT_DIR/private_key.pem
ansible $TARGET -m openssl_privatekey -a "path=${PRIVATE_KEY}"

# generate a public key from the private key
PUBLIC_KEY=$CERT_DIR/public_key.pem
ansible $TARGET -m openssl_publickey -a "path=${PUBLIC_KEY} privatekey_path=${PRIVATE_KEY}"

# generate certificate signing request
CSR=$CERT_DIR/certificate.csr
CNTRY="AU"
ORG="EshanIndustries-Weapons-Department"
EMAIL="eshanshafeeq073055@gmail.com"
CNAME="weapons.eshanindustries.com"

ARGS="path=${CSR}"
ARGS="${ARGS} privatekey_path=${PRIVATE_KEY}"
ARGS="${ARGS} country_name=${CNTRY}"
ARGS="${ARGS} organization_name=${ORG}"
ARGS="${ARGS} email_address=${EMAIL}"
ARGS="${ARGS} common_name=${CNAME}"

ansible $TARGET -m openssl_csr -a "${ARGS}"

# generate a ca signed openssl certificate
ROOT_DIR=$(pwd)/ca_certs
ROOT_CA_CERT=$ROOT_DIR/certificate.crt
ROOT_CA_PRIVATE_KEY=$ROOT_DIR/private_key.pem
CERTIFICATE=$CERT_DIR/certificate.crt

ARGS="path=${CERTIFICATE}"
ARGS="${ARGS} csr_path=${CSR}"
ARGS="${ARGS} ownca_path=${ROOT_CA_CERT}"
ARGS="${ARGS} ownca_privatekey_path=${ROOT_CA_PRIVATE_KEY}"
ARGS="${ARGS} provider=ownca"

ansible $TARGET -m openssl_certificate -a "$ARGS"

