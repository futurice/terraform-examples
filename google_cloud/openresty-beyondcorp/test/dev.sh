while :
do
  # Generate local artifacts
  terraform apply \
    -target=template_dir.swiss \
    -target=local_file.dockerfile \
    -target=local_file.login \
    --auto-approve
  docker-compose build  # Rebuild local image
  docker-compose up     # Run local container
done
