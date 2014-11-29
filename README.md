shrg
====

elixir/plug based url shortener

# url creation
# put item to `__COUNT__` with update expression add 1 and return value updated_new
# use the returned count, base62 encoded as next key
