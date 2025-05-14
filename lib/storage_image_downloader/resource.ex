defmodule StorageImageDownloader.Resource do
  @moduledoc """
  Struct implementation for resource storage.
  """

  @type t :: %__MODULE__{
          url: String.t(),
          save_location: String.t(),
          access_token: String.t(),
          try_redirect?: boolean(),
          save_fn: function()
        }

  defstruct [:url, :save_location, :access_token, :try_redirect?, :save_fn]

  def new(url, save_location \\ "", opts \\ []) do
    try_redirect? = Keyword.get(opts, :try_redirect?, true)
    access_token = Keyword.get(opts, :access_token, nil)
    save_fn = Keyword.get(opts, :save_fn) || (&file_write/3)

    struct!(__MODULE__,
      url: url,
      save_location: save_location,
      try_redirect?: try_redirect?,
      access_token: access_token,
      save_fn: save_fn
    )
  end

  defp file_write(filename, binary, location) do
    path = Path.join(location, filename)

    File.write(path, binary)
  end
end
