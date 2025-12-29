# frozen_string_literal: true

require "test_helper"

class TestDirhash < Minitest::Test
  FIXTURES_PATH = File.expand_path("fixtures", __dir__)

  def test_that_it_has_a_version_number
    refute_nil ::Dirhash::VERSION
  end

  def test_hash_zip_pkg_errors
    zip_path = File.join(FIXTURES_PATH, "pkg_errors_v0.9.1.zip")
    expected = "h1:FEBLx1zS214owpjy7qsBeixbURkuhQAwrK5UwLGTwt4="

    assert_equal expected, Dirhash.hash_zip(zip_path)
  end

  def test_hash_zip_google_uuid
    zip_path = File.join(FIXTURES_PATH, "google_uuid_v1.3.0.zip")
    expected = "h1:t6JiXgmwXMjEs8VusXIJk2BXHsn+wx8BZdTaoZ5fu7I="

    assert_equal expected, Dirhash.hash_zip(zip_path)
  end

  def test_hash_zip_x_text
    zip_path = File.join(FIXTURES_PATH, "x_text_v0.3.0.zip")
    expected = "h1:g61tztE5qeGQ89tm6NTjjM9VPIm088od1l6aSorWRWg="

    assert_equal expected, Dirhash.hash_zip(zip_path)
  end

  def test_manifest_returns_string
    zip_path = File.join(FIXTURES_PATH, "pkg_errors_v0.9.1.zip")
    manifest = Dirhash.manifest(zip_path)

    assert_kind_of String, manifest
    assert manifest.end_with?("\n")
  end

  def test_manifest_format
    zip_path = File.join(FIXTURES_PATH, "pkg_errors_v0.9.1.zip")
    manifest = Dirhash.manifest(zip_path)

    lines = manifest.split("\n")
    lines.each do |line|
      assert_match(/\A[a-f0-9]{64}  .+\z/, line, "Line should match format: {64 hex chars}  {filename}")
    end
  end

  def test_manifest_files_are_sorted
    zip_path = File.join(FIXTURES_PATH, "pkg_errors_v0.9.1.zip")
    manifest = Dirhash.manifest(zip_path)

    lines = manifest.split("\n")
    filenames = lines.map { |line| line.split("  ", 2).last }

    assert_equal filenames.sort, filenames, "Files should be sorted lexicographically"
  end

  def test_manifest_excludes_directories
    zip_path = File.join(FIXTURES_PATH, "pkg_errors_v0.9.1.zip")
    manifest = Dirhash.manifest(zip_path)

    lines = manifest.split("\n")
    filenames = lines.map { |line| line.split("  ", 2).last }

    filenames.each do |filename|
      refute filename.end_with?("/"), "Manifest should not contain directory entries"
    end
  end

  def test_manifest_contains_expected_files
    zip_path = File.join(FIXTURES_PATH, "pkg_errors_v0.9.1.zip")
    manifest = Dirhash.manifest(zip_path)

    assert_includes manifest, "github.com/pkg/errors@v0.9.1/errors.go"
    assert_includes manifest, "github.com/pkg/errors@v0.9.1/stack.go"
    assert_includes manifest, "github.com/pkg/errors@v0.9.1/LICENSE"
  end

  def test_hash_zip_has_h1_prefix
    zip_path = File.join(FIXTURES_PATH, "pkg_errors_v0.9.1.zip")
    digest = Dirhash.hash_zip(zip_path)

    assert digest.start_with?("h1:"), "Digest should start with h1: prefix"
  end

  def test_hash_zip_base64_is_valid
    zip_path = File.join(FIXTURES_PATH, "pkg_errors_v0.9.1.zip")
    digest = Dirhash.hash_zip(zip_path)

    base64_part = digest.delete_prefix("h1:")
    decoded = Base64.strict_decode64(base64_part)

    assert_equal 32, decoded.bytesize, "SHA256 hash should be 32 bytes"
  end

  def test_raises_on_nonexistent_file
    assert_raises(Zip::Error) do
      Dirhash.hash_zip("/nonexistent/path.zip")
    end
  end

  def test_raises_on_invalid_zip
    temp_file = File.join(FIXTURES_PATH, "invalid.zip")
    File.write(temp_file, "not a zip file")

    assert_raises(Zip::Error) do
      Dirhash.hash_zip(temp_file)
    end
  ensure
    File.delete(temp_file) if File.exist?(temp_file)
  end
end
