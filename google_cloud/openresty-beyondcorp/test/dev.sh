while :
do
  # Generate local artifacts
  terraform apply \
    -target=local_file.login \
    -target=local_file.config \
    -target=local_file.dockerfile \
    --auto-approve
  docker-compose build
  # Run local container
  docker-compose up
done