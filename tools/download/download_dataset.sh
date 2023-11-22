SERVER=https://dataverse.iit.it
PERSISTENT_ID=doi:10.48557/L6OWMM
VERSION=:latest

# Download the json file
curl $SERVER/api/datasets/:persistentId/versions/$VERSION/files?persistentId=$PERSISTENT_ID > dataset.json

# Download all files in the dataset
NUM_FILES=`cat dataset.json | jq ".data | length - 1"`
for i in $(seq 0 $NUM_FILES); do
    echo "Downloading file $i/$NUM_FILES..."
    file_id=`cat dataset.json | jq ".data[$i].dataFile.id"`
    file_name=`cat dataset.json | jq ".data[$i].dataFile.filename" | tr -d '"'`
    directory=`cat dataset.json | jq ".data[$i].directoryLabel" | tr -d '"'`
    mkdir -p "$directory"
    cd $directory && { curl -L $SERVER/api/access/datafile/$file_id -o $file_name ; cd -; }
done
