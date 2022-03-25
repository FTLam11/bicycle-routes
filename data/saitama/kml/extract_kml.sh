for file in *.kmz; do
  mv -- "$file" "${file%.kmz}.zip" && unzip $file && mv -- doc.kml "${file%.zip}.kml" && rm $file
done

for file in *.zip; do
  unzip $file && mv -- doc.kml "${file%.zip}.kml" && rm $file
done
