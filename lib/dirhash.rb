# frozen_string_literal: true

require_relative "dirhash/version"
require "zip"
require "digest"
require "base64"

module Dirhash
  class Error < StandardError; end

  def self.hash_zip(zip_path)
    manifest = manifest(zip_path)
    hash = Digest::SHA256.digest(manifest)
    "h1:" + Base64.strict_encode64(hash)
  end

  def self.manifest(zip_path)
    entries = []

    Zip::File.open(zip_path) do |zip_file|
      zip_file.each do |entry|
        next if entry.directory?
        entries << entry.name
      end
    end

    entries.sort!

    lines = []
    Zip::File.open(zip_path) do |zip_file|
      entries.each do |name|
        entry = zip_file.find_entry(name)
        content = entry.get_input_stream.read
        hash = Digest::SHA256.hexdigest(content)
        lines << "#{hash}  #{name}"
      end
    end

    lines.join("\n") + "\n"
  end
end
