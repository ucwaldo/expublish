defmodule ChangelogTest do
  use ExUnit.Case
  doctest Expublish

  import ExUnit.CaptureLog
  alias Expublish.Changelog
  alias Expublish.Options

  @version %Version{major: 1, minor: 0, patch: 1}

  setup do
    [options: Options.parse(["--dry-run"]), version: @version]
  end

  test "write_entry!/1 logs info message", %{options: options, version: version} do
    fun = fn ->
      if File.exists?("RELEASE.md") do
        Changelog.write_entry!(version, options)
      else
        File.write!("RELEASE.md", "generated by expublish test")
        Changelog.write_entry!(version, options)
        File.rm!("RELEASE.md")
      end
    end

    assert capture_log(fun) =~ "Skipping new entry"
  end

  test "build_title/3 runs without errors", %{version: version} do
    assert Changelog.build_title(version) =~ ~r/#{version} - \d{4}-\d{2}-\d{2}/
  end

  test "build_title/3 formats date-time to ISO 8601 date by default", %{
    options: options,
    version: version
  } do
    dt = DateTime.utc_now()

    date_format = to_iso_format([dt.year, dt.month, dt.day])

    title = Changelog.build_title(version, options, dt)

    assert title == "## #{version} - #{date_format}"
  end

  test "build_title/3 may format date-time to ISO 8601 date-time", %{
    version: version
  } do
    dt = DateTime.utc_now()

    date_format = to_iso_format([dt.year, dt.month, dt.day])
    time_format = to_iso_format([dt.hour, dt.minute, dt.second], ":")

    title = Changelog.build_title(version, %Options{changelog_date_time: true}, dt)

    assert title == "## #{version} - #{date_format} #{time_format}"
  end

  defp to_iso_format(parts, separator \\ "-") do
    parts
    |> Enum.map(&(String.pad_leading("#{&1}", 2, "0")))
    |> Enum.join(separator)
  end
end
