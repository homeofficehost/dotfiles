# rsync src folder to dest folder
# -r = recursive
# -t = preserves times
# -v = verbose
# -u = Instead of blind copy, check if file already exists, and update it
# -c = Skip files based on checksum, not mod-time & size
# -a = Archive mode, preserves symbolic links (useful).
# -h = human mode
# --progress to show progress and ETA.
#
# trailing slashes are important because with them "src" folder doesn't get
# created inside dst folder, like so -> dst/src. Instead src/* -> dst/*.
rsync -rtvuc --delete src/ dst/

# If sending data over network or between drives, also consider using
# -z option, which would copmress data before transfer.
rsync -rtvucz --delete src/ -e ssh server:/dst/

# Restart them in case of temporary network errors, until they exit
# successfully.
until !!; do :; done