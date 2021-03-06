defmodule Expublish.TestHelper do
  @moduledoc false

  def with_release_md(fun) do
    if File.exists?("RELEASE.md") do
      fun.()
    else
      File.write!("RELEASE.md", "generated by expublish test")
      fun.()
      File.rm!("RELEASE.md")
    end
  end

  def parts_to_iso(parts, separator \\ "-") do
    parts
    |> Enum.map(&String.pad_leading("#{&1}", 2, "0"))
    |> Enum.join(separator)
  end
end
