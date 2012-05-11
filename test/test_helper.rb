require 'cover_me'
require 'bundler/setup'
require 'test/unit'
require 'turn'

# Load project files
PROJECT_ROOT = File.expand_path("../../", __FILE__)
require_relative File.join(PROJECT_ROOT, 'lib', 'hqmf-parser')

class Hash
  def diff_hash(other, ignore_id=false)
    (self.keys | other.keys).inject({}) do |diff, k|
      left = self[k]
      right = other[k]
      unless left == right
        if left.is_a? Hash
          tmp = left.diff_hash(right,ignore_id)
          diff[k] = tmp unless tmp.empty?
        elsif left.is_a? Array
          tmp = []
          left.each_with_index do |entry,i|
            entry_diff = entry.diff_hash(right[i],ignore_id)
            tmp << entry_diff unless entry_diff.empty?
          end
          diff[k] = tmp unless tmp.empty?
        elsif(!ignore_id || (k != :id && k!="id"))
          diff[k] = "EXPECTED: #{left}, FOUND: #{right}"
        end
      end
      diff
    end
  end
end

