# Dirhash

Generate Go module zip digests compatible with sum.golang.org.

This gem computes hashes for Go module zip files using the same algorithm as Go's checksum database. You can verify module integrity or build tooling that works with Go's module ecosystem.

## Installation

```bash
gem install dirhash
```

Or add to your Gemfile:

```ruby
gem "dirhash"
```

## Usage

```ruby
require "dirhash"

# Generate the h1: digest (compatible with go.sum)
digest = Dirhash.hash_zip("/path/to/module.zip")
# => "h1:FEBLx1zS214owpjy7qsBeixbURkuhQAwrK5UwLGTwt4="

# Generate the manifest (list of file hashes)
manifest = Dirhash.manifest("/path/to/module.zip")
```

## Hash Format

Go's sumdb uses a two-level hash scheme defined in [golang.org/x/mod/sumdb/dirhash](https://pkg.go.dev/golang.org/x/mod/sumdb/dirhash).

The manifest is built by:
1. Listing all files in the zip (excluding directories)
2. Sorting file names lexicographically
3. For each file, computing `SHA256(content)` as lowercase hex
4. Formatting each line as: `{hex_hash}  {filename}\n` (two spaces between hash and name)

The final digest is:
1. Concatenate all manifest lines
2. Compute `SHA256(manifest)`
3. Base64 encode the result
4. Prefix with `h1:`

Example manifest:

```
2d7c3e5b...  github.com/example/mod@v1.0.0/LICENSE
8f4a2b1c...  github.com/example/mod@v1.0.0/go.mod
a1b2c3d4...  github.com/example/mod@v1.0.0/mod.go
```

The `h1:` prefix indicates version 1 of the hash algorithm. Go reserves other prefixes for future algorithms.

## Verifying Against sum.golang.org

You can verify a module by downloading it from proxy.golang.org and comparing:

```ruby
require "dirhash"
require "net/http"
require "uri"

module_path = "github.com/pkg/errors"
version = "v0.9.1"

# Download the module zip
zip_url = "https://proxy.golang.org/#{module_path}/@v/#{version}.zip"
zip_data = Net::HTTP.get(URI(zip_url))
File.write("/tmp/module.zip", zip_data)

# Compute digest
digest = Dirhash.hash_zip("/tmp/module.zip")

# Fetch expected hash from sumdb
lookup_url = "https://sum.golang.org/lookup/#{module_path}@#{version}"
# Compare with the h1: hash in the response
```

## References

This implementation is based on:

- [foragepm/zipdigest](https://github.com/foragepm/zipdigest) - JavaScript implementation
- [golang.org/x/mod/sumdb/dirhash](https://pkg.go.dev/golang.org/x/mod/sumdb/dirhash) - Go's official implementation
- [Go Module Mirror and Checksum Database](https://sum.golang.org/) - The official sumdb service

## Development

```bash
bundle install
rake test
```

## License

MIT
