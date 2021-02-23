defmodule ChangelogTest do
  use ExUnit.Case
  doctest Expublish

  import ExUnit.CaptureLog
  alias Expublish.Options
  alias Expublish.Changelog

  @version %Version{major: 1, minor: 0, patch: 1}

  setup do
    [options: Options.parse(["--dry-run"]), version: @version]
  end

  test "write_entry!/1 logs info message", %{options: options, version: version} do
    datetime = DateTime.utc_now()

    fun = fn ->
      if File.exists?("RELEASE.md") do
        Changelog.write_entry!(version, datetime, options)
      else
        File.write!("RELEASE.md", "generated by expublish test")
        Changelog.write_entry!(version, datetime, options)
        File.rm!("RELEASE.md")
      end
    end

    assert capture_log(fun) =~ "Skipping new entry"
  end
end