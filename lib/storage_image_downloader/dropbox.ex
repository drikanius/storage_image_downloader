defmodule StorageImageDownloader.DropboxDownloader do
  @moduledoc """
  Struct and protocol implementation for Dropbox image downloading.
  """

  alias StorageImageDownloader.Resource

  @type t :: %__MODULE__{
          resource: Resource.t()
        }

  defstruct [:resource]

  def new(resource), do: struct!(__MODULE__, resource: resource)
end

defimpl StorageImageDownloader.ImageDownloader.Behaviour,
  for: StorageImageDownloader.DropboxDownloader do
  alias StorageImageDownloader.DropboxDownloader

  require Logger

  def download(%DropboxDownloader{} = downloader, url) do
    cond do
      String.contains?(url, "dl=0") ->
        url |> String.replace("dl=0", "dl=1") |> do_download(downloader)

      String.contains?(url, "dl=1") ->
        do_download(url, downloader)

      true ->
        {:error, :dropbox_url_error}
    end
  end

  defp do_download(url, downloader) do
    with {:ok, response} <- Req.get(url) do
      valid_files = validate_files(response.body)

      total = Enum.count(valid_files)

      valid_files
      |> Enum.with_index(1)
      |> Enum.map(fn {{filename_charlist, binary}, index} ->
        filename = to_string(filename_charlist)
        save_location = downloader.resource.save_location

        Logger.info("Saving #{index}/#{total}: #{filename}")

        downloader.resource.save_fn.(filename, binary, save_location)
      end)
    end
  end

  defp validate_files(response_body) do
    response_body
    |> Enum.filter(fn
      {_, binary} when is_binary(binary) -> byte_size(binary) > 0
      _ -> false
    end)
  end
end
