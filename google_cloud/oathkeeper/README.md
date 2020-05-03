I was hoping to add an identity aware proxy to a Google Cloud Run endpoint using oathkeeper.
However, as of 2020/05/02 there is not easy way to fetch a token from the metadata server
and add it to an upstream header, required to make an authenticated call to a protected Cloud Run endpoint