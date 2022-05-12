# ref: http://irtfweb.ifa.hawaii.edu/~lockhart/gpg/gpg-cs.html
# https://alexcabal.com/creating-the-perfect-gpg-keypair
# https://incenp.org/notes/2015/using-an-offline-gnupg-master-key.html
# https://riseup.net/en/security/message-security/openpgp/best-practices#generate-a-revocation-certificate
# https://wiki.archlinux.org/index.php/GnuPG
# [sec] - The following is a secret key
# [ssb] - The following is a secret sub key
# The meaning of # after each of these is that the key is not usable, if say, you used the export subkeys option or if the key is otherwise taken "offline".
# The meaning of > is that the key is stored on something like a smart card.
# Setting up & Using GPG with terminal.

# Colors
ESC_SEQ="\x1b["
COL_RESET=$ESC_SEQ"39;49;00m"
COL_RED=$ESC_SEQ"31;01m"
COL_GREEN=$ESC_SEQ"32;01m"
COL_YELLOW=$ESC_SEQ"33;01m"
COL_BLUE=$ESC_SEQ"34;01m"
COL_MAGENTA=$ESC_SEQ"35;01m"
COL_CYAN=$ESC_SEQ"36;01m"

function ok() {
    echo -e "$COL_GREEN[ok]$COL_RESET "$1
}

function bot() {
    echo -e "\n$COL_GREEN\[._.]/$COL_RESET - "$1
}

function running() {
    echo -en "$COL_YELLOW ⇒ $COL_RESET"$1": "
}

function action() {
    echo -e "\n$COL_YELLOW[action]:$COL_RESET\n ⇒ $1..."
}

function warn() {
    echo -e "$COL_YELLOW[warning]$COL_RESET "$1
}

function error() {
    echo -e "$COL_RED[error]$COL_RESET "$1
}

FINGERPRINT="${1}"
SAFE_PATH=./
mkdir -p $SAFE_PATH

action "Create initial keypair"
warn "Do not include a "Comment" in your User ID"
gpg --full-generate-key

# action "Adding a picture"
# gpg --edit-key # type: addphoto and at the end type: save

action "Create revocation key"
warn "Choose: 0 = No reason specified"
gpg --output $SAFE_PATH\<$FINGERPRINT\>.gpg-revocation-certificate --gen-revoke $FINGERPRINT
gpg --output $SAFE_PATH\<$FINGERPRINT\>.gpg-revocation-certificate.asc --gen-revoke $FINGERPRINT

action "Export keys to back it up"
gpg --export-secret-keys --armor $FINGERPRINT > $SAFE_PATH\<$FINGERPRINT\>.private.gpg-key
gpg --export --armor $FINGERPRINT > $SAFE_PATH\<$FINGERPRINT\>.public.gpg-key

action "Adding a new signing subkey"
# Created separate signing key to sign emails without offline key
warn "type: ${COL_YELLOW}addkey${COL_RESET} then choose: ${COL_YELLOW}(4) RSA (sign only)${COL_RESET}"
gpg --edit-key $FINGERPRINT

action "Transforming master keypair into laptop keypair (primary key entirely offline)"
if [[ `uname -s` = "Darwin" ]]; then
	DISKRAM_PATH=/Volumes/ramdisk
	DISKRAM_SIZE_MB=50
	DISKRAM_SECTORS=$((2048 * $DISKRAM_SIZE_MB))
	DISKRAM_ID=$(hdiutil attach -nomount ram://$DISKRAM_SECTORS)
	diskutil erasevolume HFS+ "ramdisk" $(basename $DISKRAM_ID)
else
	DISKRAM_PATH=/tmp/gpg
	mkdir -p $DISKRAM_PATH && sudo mount -t ramfs -o size=1M ramfs $DISKRAM_PATH
	sudo chown $(logname):$(logname) $DISKRAM_PATH
fi

action "extract the primary key"
gpg --export-secret-subkeys $FINGERPRINT > "${DISKRAM_PATH}/subkeys"
action "*delete* the secret keys from the keyring, so only subkeys are left"
gpg --delete-secret-keys $FINGERPRINT
action "reimport the subkeys"
gpg --import "${DISKRAM_PATH}/subkeys"

gpg --list-secret-keys
bot "now verify everything is in order"
read -n 1 -r -p "Press any key to continue"

action "*delete and unmount* ramdisk"
if [[ `uname -s` = "Darwin" ]]; then
	hdiutil detach $(basename $DISKRAM_ID)
else
	sudo umount "${DISKRAM_PATH}/subkeys"
	rm -f "${DISKRAM_PATH}/subkeys"
fi


## Tests
action "Make sure key is OpenPGPv4"
gpg --export-options export-minimal --export "${FINGERPRINT}" | gpg --list-packets |grep version
warn "should be version 4."

action "Make sure key is 3072 bits"
gpg --export-options export-minimal --export "${FINGERPRINT}" | gpg --list-packets | grep -A2 'public key' | grep 'pkey\[0\]:'
warn "primary keys should be RSA, ideally 3072 bits."

action "Make sure key is using RSA"
gpg --export-options export-minimal --export "${FINGERPRINT}" | gpg --list-packets | grep -A2 '^:public key packet:$' | grep algo
warn "If the reported algorithm is 1, you are using RSA."

action "self-signatures should not use MD5 exclusively"
gpg --export-options export-minimal --export "${FINGERPRINT}" | gpg --list-packets | grep -A 2 signature | grep 'digest algo'
warn "should be 'digest algo 10'."

action "self-signatures should not use SHA1"
gpg --export-options export-minimal --export "${FINGERPRINT}" | gpg --list-packets | grep -A 2 signature | grep 'digest algo 2,'
warn "should be blank"

action "Make sure stated digest algorithm preferences include at least one member of the SHA-2 family at a higher priority than both MD5 and SHA1"
gpg --export-options export-minimal --export "${FINGERPRINT}" | gpg --list-packets | grep 'pref-hash-algos'
warn "The preference order is based on which number comes first from left to right.
 If you see the number ‘3’, ‘2’, or ‘1’ before you see ‘11’, ‘10’, ‘9’ or ‘8’, then you have specified your preferences to favor a weakened digest algorithm"

action "Make sure key have a reasonable expiration date"
gpg --export-options export-minimal --export "${FINGERPRINT}" | gpg --list-packets | grep 'key expires after'
warn "should be no more than 2 years in the future"

read -r -p "Do you want to ${COL_YELLOW} upload public key to keyserver${COL_RESET}? (y|N) [default=N] " response
[[ $response =~ ^(yes|y|Y) ]] && \
gpg --send-keys --keyserver hkps://hkps.pool.sks-keyservers.net "${FINGERPRINT}";ok



# action "Import key from keyserver (for recover on deploy)"
# gpg --recv-keys --keyserver hkps://hkps.pool.sks-keyservers.net "${FINGERPRINT}"
# gpg --list-keys 


# List his fingerprint
# gpg --fingerprint he@mail.address

# sign his key
# gpg --sign-key he@mail.address

# list the signed key as ascii ( send it to him so that he can show to others signed by me )
# gpg --export --armor he@mail.address

# encrypt plain with his (he) pub key. This will generate plain.asc which can be send only to recipients
#only those recipients can decrypt the message
# gpg --encrypt --sign --armor -r he@mail.address -r arunkumarv@cdac.in plain

# encrypt files
# gpg --encrypt filename #this will ask recipients. give me@address otherwise I cannot decrypt the message
# gpg --encrypt --sign -r me@myaddress.com filename
# gpg --output filename --decrypt filename.gpg

# decrypt files
# gpg filename
# gpg -d filename # just display
