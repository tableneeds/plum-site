require "test_helper"
require "open3"
require "tmpdir"

class OnceBackupHooksTest < ActiveSupport::TestCase
  test "pre-backup and post-restore recover every production SQLite database" do
    Dir.mktmpdir("plum-storage") do |storage_path|
      database_path = File.join(storage_path, "production.sqlite3")
      cache_path = File.join(storage_path, "production_cache.sqlite3")
      create_database(database_path, "original")
      create_database(cache_path, "cached")

      run_hook!("pre-backup", storage_path)
      write_value(database_path, "changed")
      write_value(cache_path, "changed")
      run_hook!("post-restore", storage_path)

      assert_equal "original", read_value(database_path)
      assert_equal "cached", read_value(cache_path)
      refute_path_exists File.join(storage_path, "once-backup")
    end
  end

  private

  def create_database(path, value)
    database = SQLite3::Database.new(path)
    database.execute("CREATE TABLE verification (value TEXT NOT NULL)")
    database.execute("INSERT INTO verification (value) VALUES (?)", value)
  ensure
    database&.close
  end

  def write_value(path, value)
    database = SQLite3::Database.new(path)
    database.execute("UPDATE verification SET value = ?", value)
  ensure
    database&.close
  end

  def read_value(path)
    SQLite3::Database.open(path, readonly: true) do |database|
      database.get_first_value("SELECT value FROM verification")
    end
  end

  def run_hook!(name, storage_path)
    output, status = Open3.capture2e(
      { "PLUM_STORAGE_PATH" => storage_path },
      "bundle", "exec", "ruby",
      Rails.root.join("script/once/#{name}").to_s
    )
    assert status.success?, output
  end
end
